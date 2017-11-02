FROM openjdk:8

MAINTAINER Erik Jacobs <erikmjacobs@gmail.com>
MAINTAINER Siamak Sadeghianfar <siamaksade@gmail.com>
MAINTAINER Andy Hakala <andyhakala@gmail.com>

ENV SONAR_VERSION=6.5 \
    SONARQUBE_HOME=/opt/sonarqube \
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

USER root
EXPOSE 9000
ADD root /

RUN set -x \

    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE \

    && cd /opt \
    && curl -o sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && curl -o sonarqube.zip.asc -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
    && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*] \
    && curl -o sonar-dependency-check-plugin-1.1.0.jar https://dl.bintray.com/stevespringett/owasp/org/sonarsource/owasp/sonar-dependency-check-plugin/1.1.0/sonar-dependency-check-plugin-1.1.0.jar \
    && mv sonar-dependency-check-plugin-1.1.0.jar sonarqube/extensions/plugins/

WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/

RUN useradd -r sonar
RUN /usr/bin/fix-permissions $SONARQUBE_HOME \
    && chmod 775 $SONARQUBE_HOME/bin/run.sh \ 
    && chmod +x $SONARQUBE_HOME/extensions/plugins/sonar-dependency-check-plugin-1.1.0.jar

USER sonar
ENTRYPOINT ["./bin/run.sh"]
