# radiantbluetechnolgoies/rialto-viewer

FROM radiantbluetechnologies/rialto-cesium
MAINTAINER mpg@flaxen.com

RUN git clone https://github.com/radiantbluetechnologies/rialto-viewer.git /tmp/rialto-viewer
 
#COPY ./build.sh /tmp/rialto-viewer/build.sh
RUN /tmp/rialto-viewer/docker/build.sh

CMD /bin/bash

