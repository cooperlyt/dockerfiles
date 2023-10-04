FROM elasticsearch:8.9.0

# RUN cd /usr/share/elasticsearch/plugins &&\
#   mkdir ik &&\
#   sed -i '$a ingest.geoip.downloader.enabled: false'  /usr/share/elasticsearch/config/elasticsearch.yml

# COPY elasticsearch-analysis-ik-7/ /usr/share/elasticsearch/plugins/ik/

RUN cd /usr/share/elasticsearch/bin &&\
 ./elasticsearch-plugin install --batch https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v8.9.0/elasticsearch-analysis-ik-8.9.0.zip
