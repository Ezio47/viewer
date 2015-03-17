FROM nginx
MAINTAINER mpg@flaxen.com

ENV HOME /root/work
ENV SERVERROOT /usr/share/nginx/html

WORKDIR $HOME

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install apt-transport-https apt-utils && \
    apt-get -y update && \
    apt-get -y upgrade
    
#########################################################
#
# prep
#
#########################################################

RUN apt-get -y install curl git vim 

# needed for apt-getting nodejs
RUN curl -sL https://deb.nodesource.com/setup | bash - && \
    apt-get -y install nodejs ant


#########################################################
#
# cesium build
#
#########################################################

RUN git clone https://github.com/mpgerlek/cesium.git cesium && \
    cd cesium && \
    git checkout 1.5-mpg && \
    ant combine


#########################################################
#
# rialto prep
#
#########################################################

RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' && \
    sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list' && \
    sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list' && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install dart


#########################################################
#
# rialto build
#
#########################################################

RUN git clone https://github.com/radiantbluetechnologies/tuple.git tuple

WORKDIR $HOME/tuple/rialto_viewer
RUN /usr/lib/dart/bin/pub build
WORKDIR $HOME


#########################################################
#
# deploy Rialto to web
#
#########################################################

RUN git clone https://github.com/radiantbluetechnologies/tuple-data.git

COPY ./config1.yaml default.conf tuple-data/

RUN cp -r $HOME/tuple/rialto_viewer/build/web $SERVERROOT/rialto && \
    cp $HOME/tuple-data/config1.yaml $SERVERROOT/ && \
    cp $HOME/tuple-data/default.conf /etc/nginx/conf.d/

CMD /usr/sbin/nginx
