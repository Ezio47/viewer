#include <assert.h>

#include "PdalBridge.hpp"

int main(int argc, char *argv[])
{
    PdalBridge pdal;
    
    pdal.open(argv[1]);
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

    boost::uint64_t targetPointCount = 0;
    if (argc == 4)
        targetPointCount = atoi(argv[3]);
        
    pdal.writeRia(argv[2], targetPointCount);
    
    pdal.close();
    
    return 0;
}
