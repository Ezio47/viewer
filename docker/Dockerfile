FROM ubuntu
MAINTAINER mpg@flaxen.com

ENV HOME /root/work



############################################################################
#
# initial setup
#
############################################################################

WORKDIR $HOME

ENV BASE_PKGS subversion software-properties-common cmake git g++ wget unzip
ENV DEV_PKGS libgeos-dev libproj-dev libgdal-dev libtiff-dev libexpat-dev \
              libgeotiff-dev libopenthreads-dev libfreetype6-dev libzip-dev \
              libboost-all-dev libgeos++-dev libgdal-dev

RUN apt-get upgrade
RUN apt-get update

RUN apt-get -y install $BASE_PKGS
RUN apt-get -y install $DEV_PKGS

RUN apt-get upgrade
RUN apt-get update



############################################################################
#
# LASZIP build
#
############################################################################

WORKDIR $HOME
RUN git clone https://github.com/LASzip/LASzip.git laszip
WORKDIR $HOME/laszip
RUN cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make
RUN make install



############################################################################
#
# PDAL build
#
############################################################################

WORKDIR $HOME
RUN git clone https://github.com/PDAL/PDAL.git pdal
WORKDIR $HOME/pdal
RUN cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j 3
RUN make install



############################################################################
#
# OSSIM build
#
############################################################################

WORKDIR $HOME
ENV OSSIM_SRC_DIR $HOME/ossim
ENV OSSIM_BUILD_DIR $HOME/ossim-build
    
RUN svn checkout https://svn.osgeo.org/ossim/trunk ossim

WORKDIR $OSSIM_SRC_DIR
ADD ossim.patch .
RYB patch -p0 < ./ossim.patch 

RUN cp -f $OSSIM_SRC_DIR/ossim_package_support/cmake/CMakeLists.txt $OSSIM_SRC_DIR/

WORKDIR $OSSIM_BUILD_DIR
RUN rm -f CMakeCache.txt

RUN cmake -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DGEOS_INCLUDE_DIR=/usr/include/geos \
        -DGEOS_LIBRARY=/usr/lib/libgeos.so \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DBUILD_CSMAPI=OFF \
        -DBUILD_LIBRARY_DIR=lib \
        -DBUILD_OMS=ON \
        -DBUILD_OSSIM=ON \
        -DBUILD_OSSIM_PLUGIN=OFF  \
        -DBUILD_OSSIM_TEST_APPS=ON \
        -DBUILD_OSSIMCONTRIB_PLUGIN=OFF \
        -DBUILD_OSSIMCSM_PLUGIN=OFF \
        -DBUILD_OSSIMGDAL_PLUGIN=ON \
        -DBUILD_OSSIMGEOPDF_PLUGIN=OFF \
        -DBUILD_OSSIMHDF4_PLUGIN=OFF \
        -DBUILD_OSSIMHDF5_PLUGIN=ON \
        -DBUILD_OSSIMJNI=ON \
        -DBUILD_OSSIMKAKADU_PLUGIN=OFF \
        -DBUILD_OSSIMKMLSUPEROVERLAY_PLUGIN=OFF \
        -DBUILD_OSSIMLAS_PLUGIN=ON \
        -DBUILD_OSSIMLIBRAW_PLUGIN=OFF \
        -DBUILD_OSSIMMRSID_PLUGIN=OFF \
        -DBUILD_OSSIMNDF_PLUGIN=OFF \
        -DBUILD_OSSIMPDAL_PLUGIN=ON \
        -DBUILD_OSSIMPNG_PLUGIN=ON \
        -DBUILD_OSSIMREGISTRATION_PLUGIN=OFF \
        -DBUILD_OSSIMQT4=OFF \
        -DBUILD_OSSIMGUI=OFF \
        -DBUILD_OSSIM_MPI_SUPPORT=OFF \
        -DBUILD_OSSIMPLANET=OFF \
        -DBUILD_OSSIMPLANETQT=OFF \
        -DBUILD_OSSIMPREDATOR=OFF \
        -DBUILD_RUNTIME_DIR=bin \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_WMS=ON \
        -DCMAKE_INCLUDE_PATH=${OSSIM_SRC_DIR}/ossim/include \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_LIBRARY_PATH=${OSSIM_BUILD_DIR}/lib \
        -DCMAKE_MODULE_PATH=${OSSIM_SRC_DIR}/ossim_package_support/cmake/CMakeModules \
        -DOSSIM_COMPILE_WITH_FULL_WARNING=ON \
        -DOSSIM_DEV_HOME=${OSSIM_SRC_DIR} \
        ${OSSIM_SRC_DIR}
        
RUN make -j 3
RUN make install



############################################################################
#
# tomcat
#
############################################################################

ENV GEOSERVER_DIR $HOME/geoserver
    
WORKDIR $GEOSERVER_DIR

RUN apt-get -y install default-jdk
    
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
ENV JRE_HOME $JAVA_HOME/jre

RUN echo "exit 0" > /usr/sbin/policy-rc.d
RUN mkdir -p /var/lib/tomcat7/temp
ENV CATALINA_HOME /usr/share/tomcat7
ENV CATALINA_BASE /var/lib/tomcat7
RUN apt-get -y install wget tomcat7 tomcat7-admin # tomcat7-docs tomcat7-examples 
    
    # verify!
    # ** reload env vars **
    # $CATALINA_HOME/bin/startup.sh
    # wget http://localhost:8080/index.html    

#    export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
#    export JRE_HOME=$JAVA_HOME/jre
#    export CATALINA_HOME=/usr/share/tomcat7
#    export CATALINA_BASE=/var/lib/tomcat7

RUN    $CATALINA_HOME/bin/startup.sh
RUN    sleep 5
RUN    wget http://localhost:8080/index.html
RUN    if [ ! -e index.html ] ; then echo SERVER FAIL && exit 1 ; else echo SERVER OK ; fi


############################################################################
#
# geoserver
#
############################################################################

ENV GEOSERVER_DIR $HOME/geoserver
WORKDIR $GEOSERVER_DIR
    
RUN    wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/geoserver-2.6.2-war.zip
RUN    unzip geoserver-2.6.2-war.zip

RUN    cp geoserver.war /var/lib/tomcat7/webapps/
    
ENV    PLUGIN_DIR /var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/
    
    # WPS
RUN    wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/extensions/geoserver-2.6.2-wps-plugin.zip
RUN    unzip -o -d $PLUGIN_DIR geoserver-2.6.2-wps-plugin.zip

    # Groovy scripting
RUN    wget http://ares.boundlessgeo.com/geoserver/2.6.x/community-latest/geoserver-2.6-SNAPSHOT-groovy-plugin.zip
RUN    unzip -o -d $PLUGIN_DIR geoserver-2.6-SNAPSHOT-groovy-plugin.zip
