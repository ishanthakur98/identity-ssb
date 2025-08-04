#!/bin/bash
set -e

# Build base image
echo "Building base image..."
docker build -t ishanthakur1998/iiq-base:actions -f Dockerfile.base .

# Build application image
echo "Building application image..."
docker build -t ishanthakur1998/identity-iq:actions -f Dockerfile .

# Push the image
docker image push docker.io/ishanthakur1998/identity-iq:actions

echo "Images built successfully"
