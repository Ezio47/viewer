#include <pdal/pdal.hpp>

#include <pdal/PipelineManager.hpp>
#include <pdal/PipelineReader.hpp>

class PdalBridge
{
public:
    PdalBridge(bool debug=false, boost::uint32_t verbosity=0);

    ~PdalBridge();

    // if passing an xml pipeline file, set pipeline to true
    // throws on failure
    void open(const std::string& fname, bool pipeline=false);
    
    void close();

    const std::string getWKT() const;
    
    boost::uint64_t getNumPoints() const;
    
    void getBounds(double& xmin, double& ymin, double& zmin,
                   double& xmax, double& ymax, double& zmax) const;
    
    std::vector<pdal::Dimension::Id::Enum> getFields() const;
    pdal::Dimension::Type::Enum getFieldType(pdal::Dimension::Id::Enum);
    
    void readBegin();
    bool readNext();
    double getFieldAsDouble(pdal::Dimension::Id::Enum dimensionIndex);

private:    
    bool m_debug;
    boost::uint32_t m_verbosity;
    pdal::PipelineManager* m_manager;
    pdal::PipelineReader* m_reader;
    pdal::BOX3D m_bbox;
    boost::uint64_t m_numPoints;
    pdal::PointBufferSet::const_iterator m_bufIter;
    boost::uint64_t m_pointIndex;
    bool m_readStarted;
};
