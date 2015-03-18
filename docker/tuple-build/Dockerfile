# Tuple Builder Container
FROM centos:centos6
MAINTAINER mpg@flaxen.com
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk.x86_64/

RUN yum -y install nodejs ant ant-nodeps && curl -L https://api.github.com/repos/mpgerlek/cesium/tarbal > /tmp/cesium.tar.gz && tar xvf /tmp/cesium.tar.gz && /usr/bin/ant combine /tmp/mpgerlek-cesium-80d79e0 && 


