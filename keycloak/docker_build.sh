# docker build -t coopersoft/elasticsearch:8.9.0 .
docker buildx build . --platform  linux/amd64 --push -t coopersoft/keycloak:22.0.5-openj9

# docker buildx build . --platform  linux/amd64,linux/arm64 --push -t dgsspfdjw.org.cn:443/keycloak:22.0.5