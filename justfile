default: run-app-local

# Container names
build_image := "build-image"
run_image := "run-image"

# Build the container required to build the test app
build-build-image:
    docker build -f Dockerfile.local_build -t {{build_image}} .

# Build the final runtime container
build-run-image: build-app
    docker build -f Dockerfile.local_run -t {{run_image}} .

# Build the test application
build-app: build-build-image
    docker run -v $(pwd):/build {{build_image}}

# Run the app locally inside of the runtime container
run-app-local: build-run-image
    docker run --rm -it {{run_image}}

# Run cargo clean on the rust_toy crate
rust-clean:
    cargo clean --manifest-path ./rust_toy/Cargo.toml

# Remove all images created by the build/run commands
docker-clean:
    docker rmi -f {{build_image}} {{run_image}}

cmake-clean:
    cd ./build/ && make clean || true

# Run rust-clean, docker-clean, cmake-clean
clean-all: rust-clean docker-clean cmake-clean