# Tuple Builder Container
FROM centos:centos6
MAINTAINER mpg@flaxen.com
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk.x86_64/

RUN yum -y install nodejs java-1.7.0-openjdk.x86_64 && curl -L http://psg.mtu.edu/pub/apache/ant/binaries/apache-ant-1.9.4-bin.tar.gz > /tmp/ant.tar.gz && tar xvf /tmp/ant.tar.gz && curl -L https://api.github.com/repos/mpgerlek/cesium/tarball > /tmp/cesium.tar.gz && tar xvf /tmp/cesium.tar.gz && && mv /tmp/mpgerlek-cesium-80d79e0 /tmp/Cesium && /tmp/apache-ant-1.9.4/bin/ant combine /tmp/Cesium 


