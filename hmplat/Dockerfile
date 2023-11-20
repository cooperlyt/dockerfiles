FROM jboss/base-jdk:7

ADD jboss-as-7.1.1.Final/ /opt/jboss/

USER root

RUN chown -R jboss:jboss /opt/jboss

RUN rm -rf /opt/jboss/standalone/configuration/standalone_xml_history/current

USER jboss

CMD ["sh","-c","/opt/jboss/bin/standalone.sh"]