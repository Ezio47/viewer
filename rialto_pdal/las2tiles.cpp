// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#include <assert.h>

#include "PdalBridge.hpp"
#include "TileWriter.hpp"

int main(int argc, char *argv[])
{
    PdalBridge pdal;
    
    if (argc != 4) {
        printf("usage: $ las2tiles foo.las 16 /tmp/data    # writes to /tmp/data/foo/\n");
        exit(1);
    }
    
    pdal.open(argv[1]);
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

    const int maxLevel = atoi(argv[2]);
    TileWriter* tileWriter = new TileWriter(pdal, maxLevel);
    
    tileWriter->build();
    
    tileWriter->dump();

    char* dir = new char[strlen(argv[3])+1];
    strcpy(dir, argv[3]);
    tileWriter->write(dir);
    delete[] dir;
    
    delete tileWriter;
    
    pdal.close();
    
    return 0;
}
