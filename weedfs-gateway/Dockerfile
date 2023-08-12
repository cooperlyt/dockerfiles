FROM openresty/openresty:1.21.4.2-0-jammy

RUN opm get ledgetech/lua-resty-http

RUN apt-get update && apt-get install -y \
    graphicsmagick \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -d /home/www -s /sbin/nologin www \
    && mkdir -p /home/www/data/images \
    && chown -R www:www /home/www \
    && mkdir -p /usr/local/openresty/nginx/lua


COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY lua/weedfs.lua /usr/local/openresty/lualib/weedfs.lua
COPY lua/media.lua /usr/local/openresty/nginx/lua/media.lua