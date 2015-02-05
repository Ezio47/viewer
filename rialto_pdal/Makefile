PDAL_INC=/Users/$(USER)/work/dev/build/pdal/include
PDAL_LIB=/Users/$(USER)/work/dev/build/pdal/lib

CC=g++
LD=g++

CFLAGS=-g -std=c++11 -ferror-limit=3 \
-isystem $(PDAL_INC) -I $(PDAL_INC) \
-isystem /usr/local/include \
-I /usr/local/include

LIBS=$(PDAL_LIB)/libpdalcpp.dylib -lz

%.o: %.cpp $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY: all clean

all: las2tiles las2info las2ria

clean:
	rm -f las2tiles las2info las2ria *.o

OBJS=TileWriter.o Tile.o PdalBridge.o TilingScheme.o

las2tiles : las2tiles.o $(OBJS)
	g++ -o $@ $^ $(CFLAGS) $(LIBS)

las2info : las2info.o $(OBJS)
	g++ -o $@ $^ $(CFLAGS) $(LIBS)

las2ria : las2ria.o $(OBJS)
	g++ -o $@ $^ $(CFLAGS) $(LIBS)
