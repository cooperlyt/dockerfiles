FROM consul:1.14.8

RUN apk add --no-cache \
    gcompat \
    libc6-compat  && \
    ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2