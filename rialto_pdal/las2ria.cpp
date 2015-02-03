#include <assert.h>

#include "PdalBridge.hpp"


void usage() {
    printf("Usage:  $ las2ria in.las out.las numPoints xyzOnly\n");
    exit(1);
}

int main(int argc, char *argv[])
{
    PdalBridge pdal;

    if (argc != 5) usage();

    const char* infile = argv[1];
    const char* outfile = argv[2];
    boost::uint64_t targetPointCount = atoi(argv[3]);
    
    bool xyzOnly;
    if (strcmp(argv[4], "true") == 0) {
        xyzOnly = true;
    } else if  (strcmp(argv[4], "false") == 0) {
        xyzOnly = false;
    } else {
        usage();
    }
    
    pdal.open(infile);

    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

    std::vector<pdal::Dimension::Id::Enum> dimIds = pdal.getDimIds();

    boost::uint32_t numDims = dimIds.size();
    printf("Num dims: %d\n", numDims);


    for (int i=0; i<numDims; i++) {
        pdal::Dimension::Id::Enum id = dimIds[i];
        pdal::Dimension::Type::Enum type = pdal.getDimType(id);

        double min, mean, max;
        pdal.getStats(id, min, mean, max);

        printf("Dim %d: %s (%s)\n",
            i,
            pdal::Dimension::name(id).c_str(),
            pdal::Dimension::interpretationName(type).c_str());

        printf("  (%f,%f,%f)\n",
            min, mean, max);
    }

    boost::uint32_t numWritten = pdal.writeRia(argv[2], targetPointCount, xyzOnly);

    pdal.close();

    printf("Wrote %u points\n", numWritten);

    return 0;
}
