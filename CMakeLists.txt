cmake_minimum_required(VERSION 3.16)

# Cross compilation setup ---------------------------------
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armhf)

# which compilers to use for C++ cross-compilation
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

# where is the target environment located?
set(CMAKE_FIND_ROOT_PATH /usr/lib/arm-linux-gnueabihf/)
# ---------------------------------------------------------

# Build artifacts will go in these locations
# Not necessary for this simple project, but useful when you have more
# artifacts and want to copy them all to a runtime dockerfile easily
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

PROJECT(tester)

# The name of the C++ file we're building
SET(SOURCES test.cpp)

# Rust specific setup -------------------------------------
# Where is the crate we're building?
set(RUST_PROJECT_DIR "${CMAKE_SOURCE_DIR}/rust_toy")
# The profile to use when building the crate
set(RUST_BUILD_MODE "release")
# The shared object (so) we're creating
set(RUST_SO_NAME "librust_toy.so")
# Where is the object initially created?
set(RUST_SO "${RUST_PROJECT_DIR}/target/armv7-unknown-linux-gnueabihf/${RUST_BUILD_MODE}/${RUST_SO_NAME}")
# The common location it will live
set(RUST_SO_COMMON "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${RUST_SO_NAME}")

add_custom_command(
    OUTPUT ${RUST_SO_COMMON}
    # Build the rust code
    COMMAND ${CMAKE_COMMAND} -E env cargo build --${RUST_BUILD_MODE}
             --manifest-path ${RUST_PROJECT_DIR}/Cargo.toml
             --target armv7-unknown-linux-gnueabihf
    # Copy the library to a common location
    COMMAND ${CMAKE_COMMAND} -E copy ${RUST_SO}
            ${RUST_SO_COMMON}
    WORKING_DIRECTORY ${RUST_PROJECT_DIR}
    COMMENT "Building Rust project with cargo"
    VERBATIM
)

# Add a target for the Rust library (this will ensure the Rust build happens)
add_custom_target(rust_build ALL
    DEPENDS ${RUST_SO_COMMON}
)

# so we can seamlessly link against this lib, we tell cmake to find it where we copied it (where the other libs live)
add_library(rust_toy SHARED IMPORTED)
set_target_properties(rust_toy PROPERTIES
    IMPORTED_LOCATION ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${RUST_SO_NAME}
)
# ---------------------------------------------------------

ADD_EXECUTABLE(test ${SOURCES})
# Our exe depends on the rust_build custom target, which will build the .so we need
add_dependencies(test rust_build)

TARGET_LINK_LIBRARIES(test rust_toy)

TARGET_INCLUDE_DIRECTORIES(test PRIVATE ${RUST_PROJECT_DIR}/include)