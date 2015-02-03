#include <assert.h>

#include "PdalBridge.hpp"

// las2ria file.las file.ria 1000

int main(int argc, char *argv[])
{
    PdalBridge pdal;

    if (argc != 5) {
        printf("Usage:  $ las2ria in.las out.las 1000 [xyz|all]\n");
        exit(1);
    }

    const char* infile = argv[1];
    const char* outfile = argv[2];
    boost::uint64_t targetPointCount = atoi(argv[3]);
    const char* dimMode = argv[4];

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

    boost::uint32_t numWritten = pdal.writeRia(argv[2], targetPointCount, dimMode);

    pdal.close();

    printf("Wrote %u points (approx %u bytes)\n", numWritten, numWritten * numDims * 4);

    return 0;
}
