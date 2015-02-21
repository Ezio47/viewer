// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#include <assert.h>

#include "PdalBridge.hpp"
#include "TileWriter.hpp"


static void usage(const char* s)
{
    printf("error: %s\n", s);
    printf("usage: $ las2tiles foo.las {global|local} {reproj|wgs84} 16 /tmp/data    # writes to /tmp/data/foo/\n");
    exit(1);
}
   
   
int main(int argc, char *argv[])
{
    PdalBridge pdal;
    
    if (argc != 6) usage("wrong num args");
    
    bool global;
    if (strcmp(argv[2], "global") == 0)
    {
        global = true;
    }
    else if (strcmp(argv[2], "local") == 0)
    {
        global = false;
    }
    else
    {
        usage("bad scope setting");
    }
        
    bool doReproj;
    if (strcmp(argv[3], "reproj") == 0)
    {
        doReproj = true;
    }
    else if (strcmp(argv[3], "wgs84") == 0)
    {
        doReproj = false;
    }
    else
    {
        usage("bad reproj setting");
    }

    pdal.open(argv[1], doReproj);
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

    const int maxLevel = atoi(argv[4]);
    TileWriter* tileWriter = new TileWriter(pdal, global, maxLevel);
    
    tileWriter->build();
    
    tileWriter->dump();

    char* dir = new char[strlen(argv[5])+1];
    strcpy(dir, argv[5]);
    tileWriter->write(dir);
    delete[] dir;
    
    delete tileWriter;
    
    pdal.close();
    
    return 0;
}
