#!/bin/sh

PDAL_INC=/Users/mgerlek/work/dev/pdal/include
PDAL_LIB=/Users/mgerlek/work/dev/pdal/lib

g++ -o main main.cpp PdalBridge.cpp \
  -std=c++11 -ferror-limit=3 \
  -I $PDAL_INC \
  $PDAL_LIB/libpdalcpp.dylib
