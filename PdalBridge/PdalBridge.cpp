#include "PdalBridge.hpp"


PdalBridge::PdalBridge(bool debug, boost::uint32_t verbosity) :
    m_debug(debug),
    m_verbosity(verbosity),
    m_manager(NULL),
    m_reader(NULL),
    m_statsStage(NULL),
    m_numPoints(0),
    m_buffer(NULL)
{
}

PdalBridge::~PdalBridge()
{
    close();
}


void PdalBridge::open(const std::string& fname, bool pipeline)
{
    m_manager = new pdal::PipelineManager();
    if (!m_manager)
    {
        close();
        throw pdal::pdal_error("Failed to create PDAL pipeline manager.");
    }

    if (pipeline)
    {
        // fname is an XML file
        m_reader = new pdal::PipelineReader(*m_manager, m_debug, m_verbosity);
        if (!m_reader)
        {
            close();
            throw pdal::pdal_error("Failed to create PDAL pipeline reader.");
        }

        const bool isWriter = m_reader->readPipeline(fname);
        if (isWriter)
        {
            close();
            throw pdal::pdal_error("PdalBridge doesn't support writing");
        }
        
    }
    else
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

    // for deeply technical reasons, PDAL now requires we read the whole file to
    // find the proper bounds (although this may be fixed again in the future)
    m_numPoints = m_manager->execute();

    const pdal::PointContextRef& context = m_manager->context();
    
    m_dimensionIds = context.dims();
    updateDimensionTypes();
    
    // merge all the buffers in the point buffer set into just one buffer,
    // so that life is easier for us
    m_buffer = new pdal::PointBuffer(context);
    const pdal::PointBufferSet& pbSet = m_manager->buffers();
    pdal::PointBufferSet::const_iterator iter = pbSet.begin();
    while (iter != pbSet.end())
    {
        const pdal::PointBufferPtr& data = *iter;
        const pdal::PointBuffer& t = *data;
        pdal::PointBuffer& tt = (pdal::PointBuffer&)t;

        m_buffer->append(tt);   // BUG: this should take a const PointBuffer
        
        ++iter;
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
    
    m_statsStage = NULL;
    
    return;
}


const std::string PdalBridge::getWKT(bool pretty) const
{
    const pdal::PointContextRef& context = m_manager->context();
    const pdal::SpatialReference& srs = context.spatialRef();
    
    const std::string wkt = srs.getWKT(pdal::SpatialReference::eCompoundOK, pretty);
    return wkt;
}


pdal::point_count_t PdalBridge::getNumPoints() const
{
    return m_numPoints;
}


void PdalBridge::setFields(const std::vector<DimId>& dimIds)
{
    m_dimensionIds = dimIds;
    updateDimensionTypes();
}


void PdalBridge::updateDimensionTypes()
{
    const pdal::PointContextRef& context = m_manager->context();

    m_dimensionTypes.clear();
    std::vector<DimId>::const_iterator iter = m_dimensionIds.begin();
    while (iter != m_dimensionIds.end())
    {
        DimId id = *iter;
        DimType type = context.dimType(id);
        m_dimensionTypes.push_back(type);
        ++iter;
    }
}


std::vector<pdal::Dimension::Id::Enum> PdalBridge::getFields() const
{
    return m_dimensionIds;
}


pdal::Dimension::Type::Enum PdalBridge::getFieldType(pdal::Dimension::Id::Enum id)
{
    const pdal::PointContextRef& context = m_manager->context();
    return context.dimType(id);
}


template<typename T>
static void doTheData(char* &p, const pdal::PointBuffer& data, pdal::point_count_t pointIndex, PdalBridge::DimId dimensionIndex)
{
    const T value = data.getFieldAs<T>(dimensionIndex, pointIndex);    
    *(T*)p = value;    
    p += sizeof(T);
}


void PdalBridge::processOnePoint(char* &p, pdal::point_count_t pointNum)
{
    const pdal::PointBuffer& data = *m_buffer;
    
    const int numDims = m_dimensionIds.size();

    for (int dimIndex=0; dimIndex<numDims; dimIndex++)
    {
        const DimId id = m_dimensionIds[dimIndex];
        const DimType type = m_dimensionTypes[dimIndex];
        
        switch (type)
        {
            case pdal::Dimension::Type::Unsigned8:
                doTheData<boost::uint8_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Signed8:
                doTheData<boost::int8_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Unsigned16:
                doTheData<boost::uint16_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Signed16:
                doTheData<boost::int16_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Unsigned32:
                doTheData<boost::uint32_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Signed32:
                doTheData<boost::int32_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Unsigned64:
                doTheData<boost::uint64_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Signed64:
                doTheData<boost::int64_t>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Float:
                doTheData<float>(p, data, pointNum, id);
                break;
            case pdal::Dimension::Type::Double:
                doTheData<double>(p, data, pointNum, id);
                break;
            default:
            assert(false);
        }
    }
    
    return;
}


pdal::point_count_t PdalBridge::readPoints(void* buffer, pdal::point_count_t offset, pdal::point_count_t numPoints)
{
    char* p = (char*)buffer;
    
    // don't allow the user to ask for more points than we actually have
    if (offset+numPoints > m_numPoints)
    {
        numPoints = m_numPoints - offset;
    }
    
    pdal::point_count_t numRead;
    for (numRead=0; numRead<numPoints; numRead++)
    {        
        processOnePoint(p, offset+numRead);
    }

    return numRead;
}


void PdalBridge::getStats(DimId id, double& min, double& mean, double& max) const
{
    const pdal::filters::stats::Summary& summary = m_statsStage->getStats(id);
    min = summary.minimum();
    mean = summary.average();
    max = summary.maximum();
}
