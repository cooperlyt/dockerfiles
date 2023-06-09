FROM openjdk:11-jre-slim

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade \
        && apt-get -y install --no-install-recommends \
        bash \
        tzdata \
        procps \
        file \
        && /bin/bash \
        && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
        && echo ${TZ} > /etc/timezone \
        && dpkg-reconfigure --frontend noninteractive tzdata \
        && rm -rf /var/lib/apt/lists/* \
        && mkdir -p /opt/canal-adapter

COPY ./canal.adapter-1.1.6/ /opt/canal-adapter/

WORKDIR /opt/canal-adapter

CMD ["sh","-c","sh /opt/canal-adapter/bin/restart.sh && tail -f /opt/canal-adapter/logs/adapter/adapter.log"]