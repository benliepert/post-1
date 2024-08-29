#!/bin/bash

# Build the container required to build the test app
docker build -f Dockerfile.local_build -t build-image .

# Build the test application. Mount the current directory for persistence
docker run -v $(pwd):/build build-image

# Build the final runtime container
docker build -f Dockerfile.local_run -t run-image .

# Run the app locally inside of the runtime container
docker run --rm -it run-image