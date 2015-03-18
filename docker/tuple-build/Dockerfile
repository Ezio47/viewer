# Tuple Builder Container
FROM centos:centos6
MAINTAINER ben.hosmer@gmail.com
ENV JAVA_HOME /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/

RUN yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm tar nodejs java-1.6.0-openjdk-devel && curl -L http://psg.mtu.edu/pub/apache/ant/binaries/apache-ant-1.9.4-bin.tar.gz -o /tmp/ant.tar.gz && tar xvf /tmp/ant.tar.gz -C /tmp && curl -L https://api.github.com/repos/mpgerlek/cesium/tarball -o /tmp/cesium.tar.gz && tar xvf /tmp/cesium.tar.gz -C /tmp  && mv /tmp/mpgerlek-cesium-80d79e0 /tmp/Cesium && /tmp/apache-ant-1.9.4/bin/ant combine /tmp/CesiumRUN yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm tar nodejs java-1.6.0-openjdk-devel && curl -L http://psg.mtu.edu/pub/apache/ant/binaries/apache-ant-1.9.4-bin.tar.gz -o /tmp/ant.tar.gz && tar xvf /tmp/ant.tar.gz -C /tmp && curl -L https://api.github.com/repos/mpgerlek/cesium/tarball -o /tmp/cesium.tar.gz && tar xvf /tmp/cesium.tar.gz -C /tmp  && mv /tmp/mpgerlek-cesium-80d79e0 /tmp/Cesium && /tmp/apache-ant-1.9.4/bin/ant combine -buildfile /tmp/Cesium/build.xml


