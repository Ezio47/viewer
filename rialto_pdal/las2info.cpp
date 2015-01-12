#include <assert.h>

#include "PdalBridge.hpp"

int main(int argc, char *argv[])
{
    PdalBridge pdal;
    
    pdal.open(argv[1]);
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

    std::vector<pdal::Dimension::Id::Enum> dimIds = pdal.getDimIds();
    
    boost::uint32_t numDims = dimIds.size();
    printf("Num dims: %d\n", numDims);

    for (int i=0; i<numDims; i++) {
        pdal::Dimension::Id::Enum id = dimIds[i];
        pdal::Dimension::Type::Enum type = pdal.getDimType(id);
        
        /*double min, mean, max;
        pdal.getStats(id, min, mean, max);*/
        
        printf("Dim %d: %s (%s)\n",
            i,
            pdal::Dimension::name(id).c_str(),
            pdal::Dimension::interpretationName(type).c_str());
        
        /*printf("  (%f,%f,%f)\n",
            min, mean, max);*/
    }
    
    double min, mean, max;
    pdal.getStats((pdal::Dimension::Id::Enum)0, min, mean, max);
    
    const std::string wkt = pdal.getWkt();
    printf("WKT: %s\n", wkt.c_str());

    pdal.close();
    
    return 0;
}
