#!/usr/bin/env bash

docker buildx build . --platform linux/amd64 --push -t dgsspfdjw.org.cn:443/canal-adapter:v1.1.7