#!/usr/bin/env bash

docker buildx build . --platform linux/amd64,linux/arm64 --push -t coopersoft/canal-server:standalone_10.10.6_1.1.6