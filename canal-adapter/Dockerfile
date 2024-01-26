FROM ibm-semeru-runtimes:open-11-jre-jammy

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive


ENV CANAL_VERSION 1.1.7

ENV CANAL_ADAPTER_TAG 1.1.7

RUN set -eux; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		netcat \
		perl \
		file \
		procps \
    # ca-certificates \
    # gpg \
		# gpgv \
    # pwgen \
    tzdata ;\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get install -y --no-install-recommends \
  	# dirmngr \
    # gpg-agent \
		wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; 



RUN mkdir -p /opt/canal-adapter \
        && wget -q -O /opt/canal-adapter/canal-adapter.tar.gz "https://github.com/alibaba/canal/releases/download/canal-$CANAL_ADAPTER_TAG/canal.adapter-$CANAL_VERSION.tar.gz" \
	    && tar zxvf /opt/canal-adapter/canal-adapter.tar.gz -C /opt/canal-adapter/ \
	    && rm -rf /opt/canal-adapter/canal-adapter.tar.gz \
        && mkdir -p /opt/canal-adapter/logs/adapter/ \
        && touch /opt/canal-adapter/logs/adapter/adapter.log \
        && rm -rf /opt/canal-adapter/conf/es6/*.yml \
	    && rm -rf /opt/canal-adapter/conf/es7/*.yml \
	    && rm -rf /opt/canal-adapter/conf/es8/*.yml \
	    && rm -rf /opt/canal-adapter/conf/hbase/*.yml \
	    && rm -rf /opt/canal-adapter/conf/kudu/*.yml \
	    && rm -rf /opt/canal-adapter/conf/rdb/*.yml \
	    && rm -rf /opt/canal-adapter/conf/tablestore/*.yml \
        && rm -rf /opt/canal-adapter/bin/startup.sh 

COPY startup.sh /opt/canal-adapter/bin/startup.sh
COPY wait-for-it.sh /opt/canal-adapter/bin/wait-for-it.sh

WORKDIR /opt/canal-adapter

CMD ["sh","-c","/opt/canal-adapter/bin/restart.sh"]