# vim:set ft=dockerfile:
FROM ibm-semeru-runtimes:open-11-jre-jammy

ENV TZ=Asia/Shanghai 

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r canal && useradd -r -g canal canal


# add gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
# gosu key is B42F6819007F00F88E364FD4036A9C25BF357DD4
ENV GOSU_VERSION 1.14

# 1.1.7 has bug https://github.com/alibaba/canal/issues/4796


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
	# wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	# wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	# GNUPGHOME="$(mktemp -d)"; \
	# export GNUPGHOME; \
	# gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	# for key in $GPG_KEYS; do \
	# 	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	# done; \
	# gpg --batch --export "$GPG_KEYS" > /etc/apt/trusted.gpg.d/mariadb.gpg; \
	# if command -v gpgconf >/dev/null; then \
	# 	gpgconf --kill all; \
	# fi; \
	# gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	# gpgconf --kill all; \
	# rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	# apt-mark auto '.*' > /dev/null; \
	# [ -z "$savedAptMark" ] ||	apt-mark manual $savedAptMark >/dev/null; \
	# apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	# chmod +x /usr/local/bin/gosu; \
	# gosu --version; \
	# gosu nobody true

# RUN mkdir /docker-entrypoint-initdb.d



# Ensure the container exec commands handle range of utf8 characters based of
# default locales in base image (https://github.com/docker-library/docs/blob/135b79cc8093ab02e55debb61fdb079ab2dbce87/ubuntu/README.md#locales)
ENV LANG C.UTF-8


ENV CANAL_VERSION 1.1.7-SNAPSHOT

ENV CANAL_ADAPTER_TAG 1.1.7-alpha-3

ENV CANAL_DEPLOYER_TAG 1.1.7-alpha-3


# from local build
COPY canal-adapter-alpha-3  /home/canal/canal-adapter


RUN mkdir -p /home/canal/canal-server; \
	mkdir -p /home/canal/canal-adapter; \
  wget -q -O /home/canal/canal-server.tar.gz "https://github.com/alibaba/canal/releases/download/canal-$CANAL_DEPLOYER_TAG/canal.deployer-$CANAL_VERSION.tar.gz"; \ 
	tar zxvf /home/canal/canal-server.tar.gz -C /home/canal/canal-server/; \
	rm -rf /home/canal/canal-server.tar.gz; \
	# wget -q -O /home/canal/canal-adapter.tar.gz "https://github.com/alibaba/canal/releases/download/canal-$CANAL_ADAPTER_TAG/canal.adapter-$CANAL_VERSION.tar.gz"; \
	# tar zxvf /home/canal/canal-adapter.tar.gz -C /home/canal/canal-adapter/; \
	# rm -rf /home/canal/canal-adapter.tar.gz; \
	rm -rf /home/canal/canal-adapter/conf/es6/*.yml; \
	rm -rf /home/canal/canal-adapter/conf/es7/*.yml; \
	rm -rf /home/canal/canal-adapter/conf/es8/*.yml; \
	rm -rf /home/canal/canal-adapter/conf/hbase/*.yml; \
	rm -rf /home/canal/canal-adapter/conf/kudu/*.yml; \
	rm -rf /home/canal/canal-adapter/conf/rdb/*.yml; \
	rm -rf /home/canal/canal-adapter/conf/tablestore/*.yml; 



# VOLUME /var/lib/mysql

COPY app_standalone.sh /home/canal/app.sh


RUN chown canal: /home/canal/app.sh && \
	chmod a+x /home/canal/app.sh && \
	chown -R canal: /home/canal/canal-server && \
	chown -R canal: /home/canal/canal-adapter 



USER canal

ENTRYPOINT ["/home/canal/app.sh"]

EXPOSE 11110 11111 11112 8081
CMD []