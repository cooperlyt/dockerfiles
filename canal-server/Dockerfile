FROM ibm-semeru-runtimes:open-8-jdk-centos7

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

ADD download_node_exporter.sh /tmp/

RUN \
    /bin/cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'root:Hello1234' | chpasswd && \
    groupadd -r admin && useradd -g admin admin && \
    yum install -y man && \
    yum install -y dstat && \
    yum install -y unzip && \
    yum install -y nc && \
    yum install -y openssh-server && \
    yum install -y tar && \
    yum install -y which && \
    yum install -y wget && \
    yum install -y perl && \
    yum install -y file && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key && \
    sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd && \
    sed -i -e 's/^#Port 22$/Port 2222/' /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh && \
    yum install -y cronie && \
    sed -i '/session required pam_loginuid.so/d' /etc/pam.d/crond && \
    true

RUN \
    touch /var/lib/rpm/* && \ 
    chmod +x /tmp/download_node_exporter.sh && \
    sh /tmp/download_node_exporter.sh && \
    yum clean all && \
    true


COPY image/ /tmp/docker/

RUN mkdir -p /home/admin/canal-server

COPY ./canal.deployer-1.1.6/ /home/admin/canal-server/

RUN \
    cp -R /tmp/docker/alidata /alidata && \
    chmod +x /alidata/bin/* && \
    mkdir -p /home/admin && \
    cp -R /tmp/docker/app.sh /home/admin/  && \
    cp -R /tmp/docker/admin/* /home/admin/  && \
    /bin/cp -f alidata/bin/lark-wait /usr/bin/lark-wait && \
    mkdir /home/admin/node_exporter &&\ 
    tar zxvf /tmp/node_exporter.tar.gz -C /home/admin/node_exporter --strip-components 1 && \
    ln -s /home/admin/node_exporter-0.18.1.linux-arm64 /home/admin/node_exporter && \
    rm -rf /tmp/node_exporter.tar.gz && \
    mkdir -p home/admin/canal-server/logs  && \
    chmod +x /home/admin/*.sh  && \
    chmod +x /home/admin/bin/*.sh  && \
    chown admin: -R /home/admin && \
    yum clean all && \
    true

# 11110 admin , 11111 canal , 11112 metrics, 9100 exporter
EXPOSE 11110 11111 11112 9100

WORKDIR /home/admin

ENTRYPOINT [ "/alidata/bin/main.sh" ]
CMD [ "/home/admin/app.sh" ]