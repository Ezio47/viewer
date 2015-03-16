FROM nginx
MAINTAINER mpg@flaxen.com
ENV HOME /root/work
WORKDIR $HOME


#########################################################
#
# prep
#
#########################################################

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get -y install apt-transport-https curl apt-utils git


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

RUN git clone https://github.com/mpgerlek/cesium.git cesium
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
RUN git clone https://github.com/radiantbluetechnologies/tuple.git tuple

RUN cp -r cesium/Build tuple/rialto_viewer/web/cesium-build

COPY ./pubcache.tgz ./pubcache.tgz
RUN tar xvzf ./pubcache.tgz

WORKDIR $HOME/tuple/rialto_viewer
RUN /usr/lib/dart/bin/pub build


#########################################################
#
# nginx server
#
#########################################################

WORKDIR $HOME
RUN cp -r $HOME/tuple/rialto_viewer/build/web /usr/share/nginx/html/rialto
