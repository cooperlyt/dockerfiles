#!/usr/bin/env bash

docker buildx build . --platform linux/amd64,linux/arm64 --push -t coopersoft/canal-adapter:v1.1.6