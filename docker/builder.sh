#!/bin/bash


############################################################################
#
# initial setup
#
############################################################################

function base_setup {
    BASE_PKGS="subversion software-properties-common cmake git g++"
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
    git clone https://github.com/LASzip/LASzip.git
    cd $WORKDIR/pdal
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
    git clone https://github.com/PDAL/PDAL.git pdal
    cd $WORKDIR/pdal
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/
    make
    make install
}


############################################################################
#
# OSSIM build
#
############################################################################

function ossim_setup {
    cd $WORKDIR
#    svn checkout https://svn.osgeo.org/ossim/trunk ossim

    OSSIM_SRC_DIR=$WORKDIR/ossim

    OSSIM_BUILD_DIR=$WORKDIR/ossim-build
    if [ ! -e $OSSIM_BUILD_DIR ]; then
        mkdir $OSSIM_BUILD_DIR
    fi

    cp -f $OSSIM_SRC_DIR/ossim_package_support/cmake/CMakeLists.txt $OSSIM_SRC_DIR/

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
        -DPDAL_INCLUDE_DIR=/usr/local/include \
        -DPDAL_LIBRARY=/usr/local/lib/libpdalcpp.so \
        -DCMAKE_INCLUDE_PATH=${OSSIM_SRC_DIR}/ossim/include \
        -DCMAKE_INSTALL_PREFIX=${OSSIM_BUILD_DIR} \
        -DCMAKE_LIBRARY_PATH=${OSSIM_BUILD_DIR}/lib \
        -DCMAKE_MODULE_PATH=${OSSIM_SRC_DIR}/ossim_package_support/cmake/CMakeModules \
        -DOSSIM_COMPILE_WITH_FULL_WARNING=ON \
        -DOSSIM_DEV_HOME=${OSSIM_SRC_DIR} \
        ${OSSIM_SRC_DIR}
}


WORKDIR=$HOME/work
if [ ! -e $WORKDIR ] ; then
  mkdir $WORKDIR
fi

#base_setup
#laszip_setup
#pdal_setup
ossim_setup
