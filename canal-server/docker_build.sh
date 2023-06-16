#!/usr/bin/env bash

docker buildx build . --platform linux/amd64,linux/arm64 --push -t coopersoft/canal-server:stanlone_10.9.7_1.1.7