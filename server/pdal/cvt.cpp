#include <assert.h>

#include "PdalBridge.hpp"

int main(int argc, char *argv[])
{
    PdalBridge pdal;
    
    pdal.open(argv[1]);
    
    FILE* fp = fopen(argv[2], "wb");

    pdal::point_count_t maxPoints = (argc == 4) ? atoi(argv[3]) : 1000*1000*1000;
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

    std::vector<pdal::Dimension::Id::Enum> dims = pdal.getFields();
    boost::uint32_t numFields = dims.size();
    printf("Num fields: %d\n", numFields);
        
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
    
    pdal::point_count_t numWritten = 0;
    pdal::point_count_t totNumRead = 0;
    pdal::point_count_t offset = 0;
    const pdal::point_count_t bufferSize = 10650;
    char* buf = new char[bufferSize * 3 * 8];

    while (totNumRead < numPoints)
    {        
        pdal::point_count_t numRead = pdal.readPoints(buf, offset, bufferSize);
        assert(numRead <= bufferSize);
       
        char* p = buf;
        for (pdal::point_count_t i=0; i<numRead; i++)
        {
            if (numWritten >= maxPoints) break;

            const double x = *(double*)p;
            p += 8;
            const double y = *(double*)p;
            p += 8;
            const double z = *(double*)p;
            p += 8;

            fwrite(&x, 8, 1, fp);
            fwrite(&y, 8, 1, fp);
            fwrite(&z, 8, 1, fp);
            
            ++numWritten;
        }
        
        offset += numRead;
        totNumRead += numRead;

        if (numWritten >= maxPoints) break;
    }

    printf("Points written: %ld\n", numWritten);
    
    pdal.close();
    fclose(fp);
    
    return 0;
}
