#!/bin/sh

PDAL_INC=/Users/mgerlek/work/dev/PDAL/include
PDAL_LIB=/Users/mgerlek/work/dev/PDAL/lib

g++ -c PdalBridge.cpp \
  -g -std=c++11 -ferror-limit=3 \
  -isystem $PDAL_INC \
  -I $PDAL_INC \
  -isystem /usr/local/include \
  -I /usr/local/include 
  
  #exit

  g++ -c Tile.cpp \
  -g -std=c++11 -ferror-limit=3 -isystem /usr/local/include \
  -I $PDAL_INC -I /usr/local/include 
  
  
 g++ -c TileWriter.cpp \
 -g -std=c++11 -ferror-limit=3 -isystem /usr/local/include \
 -I $PDAL_INC -I /usr/local/include 
 
 g++ -o las2info las2info.cpp PdalBridge.o TileWriter.o Tile.o \
 -g -std=c++11 -ferror-limit=3 -isystem /usr/local/include \
 -I $PDAL_INC -I /usr/local/include \
 $PDAL_LIB/libpdalcpp.dylib -lz
 
  g++ -o las2ria las2ria.cpp PdalBridge.o TileWriter.o Tile.o \
  -g -std=c++11 -ferror-limit=3 -isystem /usr/local/include \
  -I $PDAL_INC -I /usr/local/include \
  $PDAL_LIB/libpdalcpp.dylib -lz
  
  g++ -o las2tiles las2tiles.cpp PdalBridge.o TileWriter.o Tile.o \
  -g -std=c++11 -ferror-limit=3 -isystem /usr/local/include \
  -I $PDAL_INC -I /usr/local/include \
  $PDAL_LIB/libpdalcpp.dylib -lz
  
  
