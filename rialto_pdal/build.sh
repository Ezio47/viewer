#!/bin/sh

PDAL_INC=/Users/mgerlek/work/dev/pdal/include
PDAL_LIB=/Users/mgerlek/work/dev/pdal/lib

g++ -o info info.cpp PdalBridge.cpp \
  -g -std=c++11 -ferror-limit=3 -isystem /usr/local/include \
  -I $PDAL_INC -I /usr/local/include \
  $PDAL_LIB/libpdalcpp.dylib
