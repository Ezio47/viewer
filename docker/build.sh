#!/bin/bash

set -e

#
# Dart
#
curl -L https://storage.googleapis.com/dart-archive/channels/stable/release/44672/sdk/dartsdk-linux-x64-release.zip -o /tmp/dartsdk-linux-x64-release.zip
cd /tmp
unzip /tmp/dartsdk-linux-x64-release.zip
rm -rf /tmp/dartsdk-linux-x64-release.zip

#
# download Rialto viewer
#
curl -L https://github.com/radiantbluetechnologies/rialto-viewer/archive/master.zip -o /tmp/viewer.zip
unzip -o -d /tmp /tmp/viewer.zip
mv /tmp/rialto-viewer-master /tmp/viewer

#
# build & install Rialto viewer
#
mkdir -p /tmp/viewer/web/cesium-build
cp -r /opt/cesium-build/* /tmp/viewer/web/cesium-build/
cd /tmp/viewer
/tmp/dart-sdk/bin/pub build
mkdir -p /opt/viewer
cp -r /tmp/viewer/* /opt/viewer/

#
# deploy
#
rm -rf /opt/www/*
cp -r /opt/viewer/build/web/* /opt/www/

#
# cleanup
#
rm -rf \
    /tmp/viewer/ \
    /tmp/viewer.zip \
    /tmp/dart-sdk