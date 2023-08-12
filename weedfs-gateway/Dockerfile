FROM openresty/openresty:1.21.4.2-0-jammy

RUN apt-get update && apt-get install -y \
    graphicsmagick \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY lua/weedfs.lua /usr/local/openresty/lualib/weedfs.lua
COPY lua/media.lua /usr/local/openresty/lualib/media.lua