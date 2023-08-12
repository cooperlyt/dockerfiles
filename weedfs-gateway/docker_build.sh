#!/usr/bin/env bash

docker buildx build . --platform linux/amd64 --push -t coopersoft/weedfs-gateway:1.0.0