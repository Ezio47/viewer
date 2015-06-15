This is the repo for the Tuple project and the Rialto point cloud viewer.

To build and run:

* build Cesium
  * `cd .../cesium`
  * `./Tools/apache-ant-1.8.2/bin/ant combine runServer`
  * `ln -s  .../cesium/Build/ .../tuple/rialto_viewer/web/cesium-build`
* start geopackage server
   * `.../rialto-geopackage/server/geopackage_server.py localhost 12346 .../tuple-other/data/`
* start file server
   * `../rialto-geopackage/server/file_server.py localhost 12345 .../tuple-other/data/`
* open Dart IDE, run rialto_viewer
