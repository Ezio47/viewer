# Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
# This file may only be used under the MIT-style
# license found in the accompanying LICENSE.txt file.

PDAL_INC=/Users/$(USER)/work/dev/build/pdal/include
PDAL_LIB=/Users/$(USER)/work/dev/build/pdal/lib

CC=g++
LD=g++

CFLAGS=-g -std=c++11 -ferror-limit=2 \
-isystem $(PDAL_INC) -I $(PDAL_INC) \
-isystem /usr/local/include \
-I /usr/local/include

LIBS=$(PDAL_LIB)/libpdalcpp.dylib -lz

%.o: %.cpp $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY: all clean

all: las2tiles las2info

clean:
	rm -f las2tiles las2info *.o

OBJS=TileWriter.o Tile.o PdalBridge.o Rectangle.o

las2tiles : las2tiles.o $(OBJS)
	g++ -o $@ $^ $(CFLAGS) $(LIBS)

las2info : las2info.o $(OBJS)
	g++ -o $@ $^ $(CFLAGS) $(LIBS)
