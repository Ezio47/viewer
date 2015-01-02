#include "PdalBridge.hpp"


PdalBridge::PdalBridge(bool debug, boost::uint32_t verbosity) :
    m_debug(debug),
    m_verbosity(verbosity),
    m_manager(NULL),
    m_reader(NULL),
    m_numPoints(0),
    m_statsStage(NULL)
{
}


PdalBridge::~PdalBridge()
{
    close();
}


void PdalBridge::open(const std::string& fname)
{
    m_manager = new pdal::PipelineManager();
    if (!m_manager)
    {
        close();
        throw pdal::pdal_error("Failed to create PDAL pipeline manager.");
    }

    {
        pdal::StageFactory factory;
        const std::string driver = factory.inferReaderDriver(fname);
        if (driver == "")
            throw pdal::pdal_error("File type not supported by PDAL");
        pdal::Reader* reader = m_manager->addReader(driver);
        pdal::Options opts;
        opts.add("filename", fname);
        reader->setOptions(opts);
    }

    pdal::Stage* stage = m_manager->addFilter("filters.stats", m_manager->getStage());
    m_statsStage = (pdal::filters::Stats*)stage;
    
    m_numPoints = m_manager->execute();

    const pdal::PointContextRef& context = m_manager->context();
    
    // set lists of default ids and types
    {
        m_dimensionIds.clear();
        m_dimensionTypes.clear();
        
        m_dimensionIds = context.dims();
        std::vector<DimId>::const_iterator iter = m_dimensionIds.begin();
        while (iter != m_dimensionIds.end())
        {
            DimId id = *iter;
            DimType type = context.dimType(id);
            m_dimensionTypes.push_back(type);
            ++iter;
        }
    }

    return;
}


void PdalBridge::close()
{
    if (m_buffer)
    {
        delete m_buffer;    
        m_buffer = NULL;
    }
    
    if (m_reader)
    {
        delete m_reader;
        m_reader = NULL;
    }
    
    if (m_manager)
    {
        delete m_manager;
        m_manager = NULL;
    }
    
    return;
}


pdal::point_count_t PdalBridge::getNumPoints() const
{
    return m_numPoints;
}


void PdalBridge::getStats(pdal::Dimension::Id::Enum id, double& min, double& mean, double& max) const
{
    const pdal::filters::stats::Summary& summary = m_statsStage->getStats(id);
    min = summary.minimum();
    mean = summary.average();
    max = summary.maximum();
}


std::vector<pdal::Dimension::Id::Enum> PdalBridge::getDimIds() const
{
    return m_dimensionIds;
}


std::vector<pdal::Dimension::Type::Enum> PdalBridge::getDimTypes() const
{
    return m_dimensionTypes;
}
