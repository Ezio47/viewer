# TUPLE WPS
from centos:centos6

MAINTAINER Ben Hosmer <ben.hosmer@gmail.com>

ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk.x86_64/
#ENV GEOSERVER_DATA_DIR /geoserver-data
ADD ossim.repo /etc/yum.repos.d/
 
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
&& yum -y update \
&& yum -y install ossim tar unzip \
java-1.7.0-openjdk-devel.x86_64 java-1.7.0-openjdk.x86_64 jai-imageio-core \
&& yum clean all \
&& curl -L http://www.gtlib.gatech.edu/pub/apache/tomcat/tomcat-7/v7.0.57/bin/apache-tomcat-7.0.57.tar.gz -o /tmp/apache-tomcat-7.0.57.tar.gz \
&& pushd /tmp \
&& tar xvf apache-tomcat-7.0.57.tar.gz \
&& rm -rf apache-tomcat-7.0.57.tar.gz \
&& mv apache-tomcat-7.0.57 /tomcat 

#VOLUME /geoserver-data
CMD /bin/bash /tomcat/bin/catalina.sh run

EXPOSE 8080

