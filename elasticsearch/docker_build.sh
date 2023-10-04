# docker build -t coopersoft/elasticsearch:8.9.0 .

docker buildx build . --platform linux/amd64,linux/arm64 --push -t coopersoft/elasticsearch:8.9.0 