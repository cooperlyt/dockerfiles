# docker build -t coopersoft/elasticsearch:8.9.0 .

docker buildx build . --platform linux/amd64,linux/arm64 --push -t dgsspfdjw.org.cn:443/elasticsearch:8.10.4 