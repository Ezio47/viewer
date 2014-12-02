#include <assert.h>

#include "PdalBridge.hpp"

int main(int argc, char *argv[])
{
    PdalBridge pdal;
    
    pdal.open(argv[1], false);
    //pdal.open("./autzen.las", true);
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    fprintf(stderr, "num points: %lld\n", numPoints);
    fflush(stderr);

    std::vector<pdal::Dimension::Id::Enum> dims = pdal.getFields();
    boost::uint32_t numFields = dims.size();
    //printf("Num fields: %d\n", numFields);
    //assert(numFields == 16);
        
    pdal::Dimension::Id::Enum id_x = dims[0];
    assert(id_x == pdal::Dimension::Id::X);
    assert(pdal.getFieldType(id_x) == pdal::Dimension::Type::Double);
    
    pdal::Dimension::Id::Enum id_y = dims[1];
    assert(id_y == pdal::Dimension::Id::Y);
    assert(pdal.getFieldType(id_y) == pdal::Dimension::Type::Double);
    
    pdal::Dimension::Id::Enum id_z = dims[2];
    assert(id_z == pdal::Dimension::Id::Z);
    assert(pdal.getFieldType(id_z) == pdal::Dimension::Type::Double);

    std::vector<PdalBridge::DimId> dimList;
    dimList.push_back(pdal::Dimension::Id::X);
    dimList.push_back(pdal::Dimension::Id::Y);
    dimList.push_back(pdal::Dimension::Id::Z);
    pdal.setFields(dimList);
    
    pdal::point_count_t totNumRead = 0;
    pdal::point_count_t offset = 0;
    const pdal::point_count_t bufferSize = 10650;
    char* buf = new char[bufferSize * 3 * 8];

    while (totNumRead < numPoints)
    {
        if (totNumRead >= 1000000) break;
        
        pdal::point_count_t numRead = pdal.readPoints(buf, offset, bufferSize);
        assert(numRead <= bufferSize);
       
        char* p = buf;
        for (pdal::point_count_t i=0; i<numRead; i++)
        {
            const double x = *(double*)p;
            p += 8;
            const double y = *(double*)p;
            p += 8;
            const double z = *(double*)p;
            p += 8;

            {
                printf("%f %f %f\n", x, y, z);
                if ((totNumRead % 1000) == 0) {
                    fprintf(stderr, ".");
                    fflush(stderr);
                }
                if ((totNumRead % 10000) == 0) {
                    fprintf(stderr, "10K");
                    fflush(stderr);
                }
            }
        }
        
        offset += numRead;
        totNumRead += numRead;
    }
    
    //assert(totNumRead == numPoints);

    pdal.close();
    //printf("pass\n");
    
    return 0;
}
