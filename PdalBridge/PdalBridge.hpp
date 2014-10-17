#include <pdal/pdal.hpp>

#include <pdal/PipelineManager.hpp>
#include <pdal/PipelineReader.hpp>

class PdalBridge
{
public:
    typedef pdal::Dimension::Id::Enum DimId;
    typedef pdal::Dimension::Type::Enum DimType;
    
    PdalBridge(bool debug=false, boost::uint32_t verbosity=0);

    ~PdalBridge();

    // if passing an xml pipeline file, set pipeline to true
    // throws on failure
    void open(const std::string& fname, bool pipeline=false);
    
    void close();

    const std::string getWKT() const;
    
    pdal::point_count_t getNumPoints() const;
    
    void getBounds(double& xmin, double& ymin, double& zmin,
                   double& xmax, double& ymax, double& zmax) const;
    
    std::vector<DimId> getFields() const;
    DimType getFieldType(DimId);
    void setFields(const std::vector<DimId>&);
    
    // Fills up to numPoints points into the buffer, starting at the offset
    // point, and packed according to the order of the list from getFields().
    // Returns the number of points actually put into the buffer.
    pdal::point_count_t readPoints(void* buffer, pdal::point_count_t offset, pdal::point_count_t numPoints);

    // Return a list of the (min,max) pair for each previously specified
    // dimensions.
    struct stats { double min; double max; double mean; };
    std::list<stats> getMinMax();

private:    
    bool readNext();
    double getFieldAsDouble(DimId);
    void updateDimensionTypes();
    void processOnePoint(char* &, pdal::point_count_t pointNum);
    
    bool m_debug;
    boost::uint32_t m_verbosity;
    pdal::PipelineManager* m_manager;
    pdal::PipelineReader* m_reader;
    pdal::BOX3D m_bbox;
    pdal::point_count_t m_numPoints;
    std::vector<DimId> m_dimensionIds;
    std::vector<DimType> m_dimensionTypes;
    pdal::PointBuffer* m_buffer;
};
