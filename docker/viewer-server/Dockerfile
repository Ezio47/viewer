FROM nginx
MAINTAINER mpg@flaxen.com

ENV HOME /root/work
ENV SERVERROOT /usr/share/nginx/html

WORKDIR $HOME


#########################################################
#
# prep
#
#########################################################

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get -y install apt-transport-https curl apt-utils git vim


#########################################################
#
# cesium prep
#
#########################################################

RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get -y install nodejs

RUN apt-get -y install ant


#########################################################
#
# cesium build
#
#########################################################

RUN rm -fr $HOME/cesium 
WORKDIR $HOME

RUN git clone https://github.com/mpgerlek/cesium.git cesium
#RUN git init
#RUN git remote add origin https://github.com/mpgerlek/cesium
##RUN git config pack.windowMemory 10m
##RUN git config pack.packSizeLimit 20m
#RUN git pull
WORKDIR $HOME/cesium
RUN git checkout 1.5-mpg

RUN ant combine


#########################################################
#
# rialto prep
#
#########################################################

RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list'

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get -y install dart


#########################################################
#
# rialto build
#
#########################################################

WORKDIR $HOME
RUN ls
RUN rm -rf tuple
RUN git clone https://github.com/radiantbluetechnologies/tuple.git tuple

# copy built Cesium into the Rialto project
RUN cp -r cesium/Build tuple/rialto_viewer/web/cesium-build

# use pubcache because "pub get" (via pub build) doesn't work from within docker
#COPY ./pubcache.tgz ./pubcache.tgz
#RUN tar xzf ./pubcache.tgz

WORKDIR $HOME/tuple/rialto_viewer
RUN /usr/lib/dart/bin/pub build


#########################################################
#
# deploy Rialto to web
#
#########################################################

WORKDIR $HOME
RUN ls
RUN cp -r $HOME/tuple/rialto_viewer/build/web $SERVERROOT/rialto

############################################################################
#
# RIA data files
#
############################################################################

WORKDIR $HOME
RUN rm -rf tuple-data
COPY ./tiledserp18.tgz ./config1.yaml tuple-data/

WORKDIR $SERVERROOT

RUN tar xzf $HOME/tuple-data/tiledserp18.tgz

RUN cp $HOME/tuple-data/config1.yaml .
