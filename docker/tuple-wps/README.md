# Tuple WPS

This container installs OSSIM from rpm packages and also GeoServer to create
the WPS bridge for tuple.

## Build it
`docker build --tag=radiantblue/tuple-wps .`

## Run it
`docker run -d --link='rialto.dev' --name='tuple-wps.dev' radiantblue/tuple-wps:latest` **Subject to change**

