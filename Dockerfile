FROM openjdk:11.0.2-jre-stretch
MAINTAINER craftperson/kequandian.net
## Limitation ##
## openjdk 11 do not support webservice
## #

## sources.list
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources.list /etc/apt/


ENV LANG=C.UTF-8 \
    TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y curl vim wget net-tools \
    && rm -rf /var/lib/apt/lists/*


## app config
WORKDIR   /webapps

COPY ./config/logback-spring.xml /tmp
COPY ./config/produce.yml /tmp
COPY ./config/greenfield.yml /tmp
COPY ./script/run.sh /usr/local/bin
##COPY ./script/service.sh /usr/local/bin
#COPY ./script/deploy-lib.sh /tmp
#COPY ./script/predeploy.sh /tmp
#COPY ./script/deploy.sh /tmp
COPY ./script/fix_url.sh /usr/local/bin

## run app and start up nginx in run.sh
CMD sh /usr/local/bin/run.sh
