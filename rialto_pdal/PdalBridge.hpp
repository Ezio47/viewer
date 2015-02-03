#include <pdal/PipelineManager.hpp>
#include "TileWriter.hpp"

class PdalBridge
{
public:
    PdalBridge(bool debug=false, boost::uint32_t verbosity=0);

    ~PdalBridge();

    void open(const std::string& fname);

    void close();

    int getMetadataCount();
    std::vector<char*> getMetadataKeys();
    std::vector<char*> getMetadataValues();
    
    boost::uint64_t getNumPoints() const;

    const pdal::Dimension::IdList& getDimIds() const;
    pdal::Dimension::Type::Enum getDimType(pdal::Dimension::Id::Enum) const;

    void getStats(pdal::Dimension::Id::Enum id, double& min, double& mean, double& max) const;

    std::string getWkt() const;

    void writeTiles();

    boost::uint64_t writeRia(const char* name, boost::uint64_t targetPointCount, bool xyzOnly);

private:
    void writeRiaHeader(FILE* fp, bool xyzOnly, boost::uint64_t numWritten);
    boost::uint64_t writeRia(FILE* fp, const pdal::PointBufferPtr& buf, boost::uint64_t skip, bool xyzOnly);

    std::vector<char*> m_keys;
    std::vector<char*> m_values;

    bool m_debug;
    boost::uint32_t m_verbosity;
    pdal::PipelineManager* m_manager;
    pdal::Reader* m_reader;
    pdal::Filter* m_filter1;
    pdal::Filter* m_filter2;
    pdal::Writer* m_writer;
    boost::uint64_t m_numPoints;

    pdal::Dimension::IdList m_dimensionIds;
};
