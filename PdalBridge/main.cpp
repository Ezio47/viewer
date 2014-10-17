#include <assert.h>

#include "PdalBridge.hpp"

int main()
{
    PdalBridge pdal;
    
    pdal.open("./autzen.las", false);
    //pdal.open("./autzen.las", true);
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

    double xmin, ymin, zmin, xmax, ymax, zmax;
    pdal.getBounds(xmin, ymin, zmin, xmax, ymax, zmax);
    printf("Bounds: (%f,%f,%f) to (%f,%f,%f)\n",
           xmin, ymin, zmin, xmax, ymax, zmax);

    std::string wkt = pdal.getWKT();
    wkt[30] = 0;
    printf("WKT: %s ...\n", wkt.c_str());

    std::vector<pdal::Dimension::Id::Enum> dims = pdal.getFields();
    boost::uint32_t numFields = dims.size();
    printf("Num fields: %d\n", numFields);
    assert(numFields == 16);
    
    pdal::Dimension::Id::Enum id_x = dims[0];
    assert(id_x == pdal::Dimension::Id::X);
    assert(pdal.getFieldType(id_x) == pdal::Dimension::Type::Double);
    
    pdal::Dimension::Id::Enum id_y = dims[1];
    assert(id_y == pdal::Dimension::Id::Y);
    assert(pdal.getFieldType(id_y) == pdal::Dimension::Type::Double);
    
    pdal::Dimension::Id::Enum id_z = dims[2];
    assert(id_z == pdal::Dimension::Id::Z);
    assert(pdal.getFieldType(id_z) == pdal::Dimension::Type::Double);

    pdal.readBegin();
    boost::uint64_t count = 0;
    while (pdal.readNext())
    {
        const double x = pdal.getFieldAsDouble(id_x);
        const double y = pdal.getFieldAsDouble(id_y);
        const double z = pdal.getFieldAsDouble(id_z);
        if (count < 5)
        {
            printf("point %lld: %f, %f, %f\n", count, x, y, z);
        }
        ++count;
    }
    assert(count == numPoints);
    
    pdal.close();
    printf("pass\n");
    
    return 0;
}
