from centos:centos6

MAINTAINER Ben Hosmer <ben.hosmer@gmail.com>

ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk.x86_64/
#ENV OSSIM_INSTALL_PREFIX /usr/bin
#ENV OSSIM_PREFS_FILE 

COPY ossim.repo /etc/yum.repos.d/
 
RUN yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
&& yum -y update \
&& yum -y install ossim tar unzip gdal gdal-devel \
java-1.7.0-openjdk-devel.x86_64 java-1.7.0-openjdk.x86_64 jai-imageio-core \
&& yum clean all \
&& curl -L http://apache.mesi.com.ar/tomcat/tomcat-7/v7.0.59/bin/apache-tomcat-7.0.59.tar.gz -o /tmp/apache-tomcat-7.0.59.tar.gz \
&& tar xf /tmp/apache-tomcat-7.0.59.tar.gz -C /tmp \
&& rm -f /tmp/apache-tomcat-7.0.59.tar.gz \
&& mv /tmp/apache-tomcat-7.0.59 /tomcat \
&& curl -L http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/geoserver-2.6.2-war.zip -o /tmp/geoserver-2.6.2-war.zip \
&& mkdir /tomcat/webapps/geoserver \
&& unzip /tmp/geoserver-2.6.2-war.zip geoserver.war -d /tomcat/webapps/geoserver \ 
&& unzip -o /tomcat/webapps/geoserver/geoserver.war -d /tomcat/webapps/geoserver \
&& rm -f /tomcat/webapps/geoserver/geoserver.war \
&& rm -f /tmp/geoserver-2.6.2-war.zip \
&& curl -L http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/extensions/geoserver-2.6.2-wps-plugin.zip -o /tmp/geoserver-2.6.2-wps-plugin.zip \
&& unzip -o /tmp/geoserver-2.6.2-wps-plugin.zip -d /tomcat/webapps/geoserver/WEB-INF/lib \
&& rm -f /tmp/geoserver-2.6.2-wps-plugin.zip \
&& curl -L http://ares.boundlessgeo.com/geoserver/2.6.x/community-latest/geoserver-2.6-SNAPSHOT-groovy-plugin.zip -o /tmp/geoserver-2.6-SNAPSHOT-groovy-plugin.zip \
&& unzip -o /tmp/geoserver-2.6-SNAPSHOT-groovy-plugin.zip -d /tomcat/webapps/geoserver/WEB-INF/lib \
&& rm -f /tmp/geoserver-2.6-SNAPSHOT-groovy-plugin.zip \
&& rm -rf /tomcat/webapps/{docs,examples,host-manager,manager} \
&& mkdir -p /tomcat/webapps/geoserver/data/scripts/wps \
&& curl -L https://raw.githubusercontent.com/radiantbluetechnologies/tuple/master/docker/tuple-wps/wpsviewshed.groovy -o /tomcat/webapps/geoserver/data/scripts/wps/wpsviewshed.groovy

COPY web.xml /tomcat/webapps/geoserver/WEB-INF/

CMD /bin/bash /tomcat/bin/catalina.sh run

EXPOSE 8080

