FROM centos:centos7
MAINTAINER ben.hosmer@gmail.com

ENV JAVA_HOME /usr/lib/jvm/jre-1.6.0-openjdk.x86_64/

RUN yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
&& yum -y update \
&& yum -y install unzip gcc-c++ tar nodejs java-1.6.0-openjdk-devel \
&& curl -L http://psg.mtu.edu/pub/apache/ant/binaries/apache-ant-1.9.4-bin.tar.gz -o /tmp/ant.tar.gz \
&& tar xvf /tmp/ant.tar.gz -C /tmp \
&& rm -rf /tmp/ant.tar.gz \
&& curl -L https://api.github.com/repos/mpgerlek/cesium/tarball/v1.5.1-mpg -o /tmp/cesium.tar.gz \
&& tar xvf /tmp/cesium.tar.gz -C /tmp \
&& mv /tmp/mpgerlek-cesium-80d79e0 /tmp/Cesium \
&& rm -rf /tmp/cesium.tar.gz \
&& /tmp/apache-ant-1.9.4/bin/ant combine -buildfile /tmp/Cesium \
&& curl -L https://storage.googleapis.com/dart-archive/channels/stable/release/44672/sdk/dartsdk-linux-x64-release.zip -o /tmp/dartsdk-linux-x64-release.zip \
&& pushd /tmp \
&& unzip /tmp/dartsdk-linux-x64-release.zip \
&& rm -rf /tmp/dartsdk-linux-x64-release.zip \
&& mkdir /rialto-viewer

VOLUME /rialto-viewer

CMD pushd /rialto-viewer \
&& /tmp/dart-sdk/bin/pub build \
&& mkdir /rialto-viewer/web/cesium-build/ \
&& cp -r /tmp/Cesium/Build/Cesium /rialto-viewer/web/cesium-build \
&& popd 

