# docker build -t coopersoft/elasticsearch:8.9.0 .

docker buildx build . --platform  linux/amd64,linux/arm64 --push -t dgsspfdjw.org.cn:443/keycloak:21.1.2