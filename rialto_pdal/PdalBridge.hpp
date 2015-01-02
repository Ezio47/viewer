#include <pdal/pdal.hpp>

#include <pdal/PipelineManager.hpp>
#include <pdal/PipelineReader.hpp>
#include <pdal/filters/Stats.hpp>

class PdalBridge
{
public:
    typedef pdal::Dimension::Id::Enum DimId;
    typedef pdal::Dimension::Type::Enum DimType;
    
    PdalBridge(bool debug=false, boost::uint32_t verbosity=0);

    ~PdalBridge();

    void open(const std::string& fname);
    
    void close();
    
    int getMetadataCount();
    std::vector<char*> getMetadataKeys();
    std::vector<char*> getMetadataValues();
    
    pdal::point_count_t getNumPoints() const;
    
    std::vector<pdal::Dimension::Id::Enum> getDimIds() const;
    std::vector<pdal::Dimension::Type::Enum> getDimTypes() const;
    
    void getStats(pdal::Dimension::Id::Enum id, double& min, double& mean, double& max) const;
    
private:    
    pdal::filters::Stats* m_statsStage;
    
    std::vector<char*> m_keys;
    std::vector<char*> m_values;
    
    bool m_debug;
    boost::uint32_t m_verbosity;
    pdal::PipelineManager* m_manager;
    pdal::PipelineReader* m_reader;
    pdal::point_count_t m_numPoints;

    std::vector<DimId> m_dimensionIds;
    std::vector<DimType> m_dimensionTypes;
};
