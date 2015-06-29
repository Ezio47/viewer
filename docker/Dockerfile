FROM quay.io/radiantbluetechnologies/rialto-cesium
MAINTAINER mpg@flaxen.com

EXPOSE 8080

COPY ./build.sh /tmp/
RUN /tmp/build.sh

CMD nginx
