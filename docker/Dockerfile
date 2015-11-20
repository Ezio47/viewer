# rialto/viewer

FROM rialto/cesium
MAINTAINER mpg@flaxen.com

RUN git clone https://github.com/rb-rialto/viewer.git /tmp/viewer \
  && sh /tmp/viewer/docker/build.sh \
  && rm -fr /tmp/*

CMD /bin/bash
