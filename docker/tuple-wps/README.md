# Tuple WPS

This container installs OSSIM from rpm packages and also GeoServer to create
the WPS bridge for tuple.

## Build it
`docker build --tag=radiantblue/tuple-wps .`

## Run it
`docker run -d --link='TUPLEVIEWERCONTAINER' --name='tuple-wps' -v /ABS/LOCAL/PATH/TO/SCRIPTS:/tomcat/webapps/geoserver/data/scripts/wps radiantblue/tuple-wps:latest` **Subject to change**

