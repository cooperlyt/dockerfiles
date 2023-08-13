FROM openresty/openresty:1.21.4.2-0-jammy

RUN apt-get update && apt-get install -y \
    libmagickwand-dev \
    libgraphicsmagick1-dev \
    libwebp-dev \
    libpng-dev \
    libtiff-dev \
    libfreetype-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

RUN opm get ledgetech/lua-resty-http \
    && opm get cooperlyt/lua-resty-seaweedfs \
    && luarocks install magick \
    && opm get kwanhur/lua-resty-magick

RUN useradd -d /home/www -s /sbin/nologin www \
    && mkdir -p /home/www/data/images \
    && chown -R www:www /home/www \
    && mkdir -p /usr/local/openresty/nginx/lua


COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY lua/thumbnail.lua /usr/local/openresty/nginx/lua/thumbnail.lua