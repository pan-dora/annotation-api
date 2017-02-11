FROM tomcat:7-alpine

ENV version v0.5.12
ENV CATALINA_OPTS -Xms512m -Xmx512m -XX:MaxPermSize=256m

RUN  mkdir -p /root/.grails
COPY cfg/catch-config.properties /root/.grails

# Copy server.xml
COPY conf/* conf/

RUN  rm -rf ${CATALINA_HOME}/webapps/ROOT \
 && apk add --update curl \
 && rm -rf /var/cache/apk/* \
 && curl -L  https://github.com/annotationsatharvard/catcha/releases/download/${version}/catch.war \
    > ${CATALINA_HOME}/webapps/ROOT.war \
 && mkdir -p /usr/local/tomcat/webapps/ROOT \
 && unzip /usr/local/tomcat/webapps/ROOT.war -d /usr/local/tomcat/webapps/ROOT \

    # replace db host for docker-compose. This can be deprecated once the db parameters can be passed through environment variables
 && sed -i -e 's/mysql:\/\/localhost:3306/mysql:\/\/db:3306/' \
    -e 's/catch_test/catch/' \
    /root/.grails/catch-config.properties

VOLUME ['/usr/local/tomcat/webapps/ROOT/uploads']

EXPOSE 7070

COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh

EXPOSE 3000

ENTRYPOINT [ "/entrypoint.sh" ]