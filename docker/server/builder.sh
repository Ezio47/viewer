#!/bin/bash


############################################################################
#
# initial setup
#
############################################################################

function base_setup {
    BASE_PKGS="subversion software-properties-common cmake git g++ wget unzip"
    DEV_PKGS="libgeos-dev libproj-dev libgdal-dev libtiff-dev libexpat-dev \
    libgeotiff-dev libopenthreads-dev libfreetype6-dev libzip-dev \
    libboost-all-dev libgeos++-dev libgdal-dev"

    apt-get upgrade
    apt-get update

    apt-get -y install $BASE_PKGS
    apt-get -y install $DEV_PKGS

    apt-get upgrade
    apt-get update
}


############################################################################
#
# LASZIP build
#
############################################################################

function laszip_setup {
    cd $WORKDIR
    rm -fr laszip
    git clone https://github.com/LASzip/LASzip.git laszip
    cd $WORKDIR/laszip
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/
    make
    make install
}


############################################################################
#
# PDAL build
#
############################################################################

function pdal_setup {
    cd $WORKDIR
    rm -fr pdal
    git clone https://github.com/PDAL/PDAL.git pdal
    cd $WORKDIR/pdal
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/
    make -j 3
    make install
}


############################################################################
#
# OSSIM build
#
############################################################################

function ossim_setup {
    cd $WORKDIR
    OSSIM_SRC_DIR=$WORKDIR/ossim
    OSSIM_BUILD_DIR=$WORKDIR/ossim-build
    
    rm -fr $OSSIM_SRC_DIR $OSSIM_BUILD_DIR
    svn checkout https://svn.osgeo.org/ossim/trunk ossim

    cd $OSSIM_SRC_DIR
    patch -p0 < /opt/rialto/ossim.patch 
    cd $WORKDIR
    
    cp -f $OSSIM_SRC_DIR/ossim_package_support/cmake/CMakeLists.txt $OSSIM_SRC_DIR/

    mkdir $OSSIM_BUILD_DIR
    cd $OSSIM_BUILD_DIR
    rm -f CMakeCache.txt

    cmake -G "Unix Makefiles" \
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
        
        make -j 3
        make install
}


############################################################################
#
# tomcat
#
############################################################################

function tomcat_setup {
    GEOSERVER_DIR=$WORKDIR-geoserver
    
    rm -fr $GEOSERVER_DIR
    mkdir $GEOSERVER_DIR
    cd $GEOSERVER_DIR

    apt-get -y install default-jdk    
    export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
    export JRE_HOME=$JAVA_HOME/jre

    echo "exit 0" > /usr/sbin/policy-rc.d
    mkdir -p /var/lib/tomcat7/temp
    export CATALINA_HOME=/usr/share/tomcat7
    export CATALINA_BASE=/var/lib/tomcat7
    apt-get -y install wget tomcat7 tomcat7-admin # tomcat7-docs tomcat7-examples 
    
    # verify!
    # ** reload env vars **
    # $CATALINA_HOME/bin/startup.sh
    # wget http://localhost:8080/index.html    
}

function tomcat_start
{
    export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
    export JRE_HOME=$JAVA_HOME/jre
    export CATALINA_HOME=/usr/share/tomcat7
    export CATALINA_BASE=/var/lib/tomcat7

    $CATALINA_HOME/bin/startup.sh
    sleep 5
    rm index.html
    wget http://localhost:8080/index.html
    if [ ! -e index.html ] ; then
        echo SERVER FAIL, NOT RUNNING
        exit 1
    else
        echo SERVER OKAY
    fi
}


############################################################################
#
# geoserver
#
############################################################################

function geoserver_setup {
    GEOSERVER_DIR=$WORKDIR-geoserver
    cd $GEOSERVER_DIR
    
    wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/geoserver-2.6.2-war.zip
    unzip geoserver-2.6.2-war.zip

    cp geoserver.war /var/lib/tomcat7/webapps/
    
    export PLUGIN_DIR=/var/lib/tomcat7/webapps/geoserver/WEB-INF/lib/
    
    # WPS
    wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/extensions/geoserver-2.6.2-wps-plugin.zip
    unzip -o -d $PLUGIN_DIR geoserver-2.6.2-wps-plugin.zip

    # Groovy scripting
    wget http://ares.boundlessgeo.com/geoserver/2.6.x/community-latest/geoserver-2.6-SNAPSHOT-groovy-plugin.zip
    unzip -o -d $PLUGIN_DIR geoserver-2.6-SNAPSHOT-groovy-plugin.zip
}


WORKDIR=$HOME/work
if [ ! -e $WORKDIR ] ; then
  mkdir $WORKDIR
fi

base_setup
laszip_setup
pdal_setup
ossim_setup
tomcat_setup
tomcat_start
geoserver_setup
