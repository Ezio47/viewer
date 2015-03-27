# Tuple WPS

This container installs OSSIM from rpm packages and also GeoServer to create
the WPS bridge for tuple.

## Build it
`docker build --tag=radiantblue/tuple-wps .`

## Run it
```
    docker run -d --link='TUPLEVIEWERCONTAINER' --name='tuple-wps' \
    -v /PATH1:/tomcat/webapps/geoserver/data/scripts/wps \
    -v /PATH2:/tomcat/webapps/ROOT/ossim_data \
    -e TUPLE_INPUT_PATH=/tomcat/webapps/ROOT/ossim_data \
    -e TUPLE_OUTPUT_PATH=/tomcat/webapps/ROOT/ossim_data \
    -e TUPLE_OUTPUT_URL=http://EXAMPLE.COM:PORT/ossim_data \
    radiantblue/tuple-wps:latest` 
```

Explanations:

* `PATH1` is the absolute path to where your WPS groovy scripts on your local
host. If you omit this `-v` line, you'll get whatever scripts were built into
the container.

* `PATH2` is the absolute path to where your "data directory" is on your local
host. If you omit this `-v` line, you won't have local access to the files. The
path on the remote box should be the same as your `TUPLE_INPUT_PATH` (below).

* `TUPLE_INPUT_PATH` is the directory where the WPS scripts will expect to
find their input files. For now, you must set this exactly as shown.

* `TUPLE_OUTPUT_PATH` is the directory where the WPS scripts will expect to
put their output files. For now, you must set this exactly as shown.

* `TUPLE_OUTPUT_URL` is the URL which points to where the WPS output files will
live. For now, you must set this to be the same server name and port number as
the WPS server itself (but the path portion will remain `ossim_data`, since
that's where tomcat exposes the `TUPLE_OUTPUT_PATH` directory).

Of course, this is all **subject to change**.
