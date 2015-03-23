from centos:centos6

MAINTAINER Ben Hosmer <ben.hosmer@gmail.com>

ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk.x86_64/
ADD ossim.repo /etc/yum.repos.d/
 
RUN yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
&& yum -y update \
&& yum -y install ossim tar unzip \
java-1.7.0-openjdk-devel.x86_64 java-1.7.0-openjdk.x86_64 jai-imageio-core \
&& yum clean all \
&& curl -L http://apache.mesi.com.ar/tomcat/tomcat-7/v7.0.59/bin/apache-tomcat-7.0.59.tar.gz -o /tmp/apache-tomcat-7.0.59.tar.gz \
&& pushd /tmp \
&& tar xvf apache-tomcat-7.0.59.tar.gz \
&& rm -rf apache-tomcat-7.0.597.tar.gz \
&& mv apache-tomcat-7.0.59 /tomcat \
&& popd \
&& mkdir /tmp/geoserver \
&& curl -L http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/geoserver-2.6.2-war.zip -o /tmp/geoserver/geoserver-2.6.2-war.zip \
&& pushd /tmp/geoserver \
&& unzip geoserver-2.6.2-war.zip \
&& mkdir /tmp/geoserver/geoserver-war \
&& mv /tmp/geoserver/geoserver.war /tmp/geoserver/geoserver-war \
&& popd \
&& pushd /tmp/geoserver/geoserver-war \
&& /usr/bin/jar xvf geoserver.war \
&& rm -f /tmp/geoserver/geoserver-war/geoserver.war \
&& cp -pr /tmp/geoserver/geoserver-war /tomcat/webapps/geoserver \
&& rm -rf /tmp/geoserver \
&& popd \
&& mkdir /tmp/geoserver-wps \
&& curl -L http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/extensions/geoserver-2.6.2-wps-plugin.zip -o /tmp/geoserver-wps/geoserver-2.6.2-wps-plugin.zip \
&& pushd /tmp/geoserver-wps \
&& unzip /tmp/geoserver-wps/geoserver-2.6.2-wps-plugin.zip \
&& popd \
&& cp -pr /tmp/geoserver-wps/*.jar /tomcat/webapps/geoserver/WEB-INF/lib/ \
&& rm -rf /tmp/geoserver-wps 

CMD /bin/bash /tomcat/bin/catalina.sh run

EXPOSE 8080

