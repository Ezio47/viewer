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
# build & install Rialto viewer
#
mkdir -p /tmp/viewer/web/cesium-build
cp -r /opt/cesium-build/Build/* /tmp/viewer/web/cesium-build/
cd /tmp/viewer
/tmp/dart-sdk/bin/pub build
mkdir -p /opt/viewer-build
cp -r /tmp/viewer/* /opt/viewer-build/

# cleanup
#
rm -rf \
    /tmp/viewer/ \
    /tmp/viewer.zip \
    /tmp/dart-sdk
