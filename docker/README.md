# Tuple Rialto

This repo contains three docker directories, one for building, one for serving, and one for creating the WPS bridge between the viewer and OSSIM. See the README contained within each directory for information on building and running each container.

1. tuple-build
        - Is the build container
2. tuple-rialto
        - Is the HTML/APP container
3. tuple-wps
        - Is the WPS Bridge with GeoServer and OSSIM

You can use [docker-compose](https://docs.docker.com/compose/) to build, and start
the stack:
        - `$ docker-compose --file compose-build.yml  build`
        - `$ docker-compose --file compose-run.yml up -d`

This launches the tuple-wps and tuple-rialto containers and links them together.

Access the application at http://somehost.com/rialto/ 

