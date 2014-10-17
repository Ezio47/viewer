#include "PdalBridge.hpp"


PdalBridge::PdalBridge(bool debug, boost::uint32_t verbosity) :
    m_debug(debug),
    m_verbosity(verbosity),
    m_manager(NULL),
    m_reader(NULL),
    m_numPoints(0),
    m_readStarted(false)
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
    
    // for deeply technical reasons, PDAL now requires we read the whole file to
    // find the proper bounds (although this may be fixed again in the future)
    m_numPoints = m_manager->execute();

    // compute the bounds
    const pdal::PointBufferSet& pbSet = m_manager->buffers();
    m_bbox = pdal::PointBuffer::calculateBounds(pbSet);

    return;
}


void PdalBridge::close()
{
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


const std::string PdalBridge::getWKT() const
{
    pdal::Stage* stage = m_manager->getStage();
    assert(stage);
    const pdal::SpatialReference& srs = stage->getSpatialReference();
    
    const bool pretty = false;
    const std::string wkt = srs.getWKT(pdal::SpatialReference::eCompoundOK, pretty);
    return wkt;
}


uint64_t PdalBridge::getNumPoints() const
{
    return m_numPoints;
}


void PdalBridge::getBounds(double& xmin, double& ymin, double& zmin,
                           double& xmax, double& ymax, double& zmax) const
{
     xmin = m_bbox.minx;
     ymin = m_bbox.miny;
     zmin = m_bbox.minz;
     xmax = m_bbox.maxx;
     ymax = m_bbox.maxy;
     zmax = m_bbox.maxz;
}


std::vector<pdal::Dimension::Id::Enum> PdalBridge::getFields() const
{
    const pdal::PointContextRef& context = m_manager->context();
    return context.dims();
}


pdal::Dimension::Type::Enum PdalBridge::getFieldType(pdal::Dimension::Id::Enum id)
{
    const pdal::PointContextRef& context = m_manager->context();
    return context.dimType(id);
}


void PdalBridge::readBegin()
{
    m_readStarted = false;
}


bool PdalBridge::readNext()
{
    const pdal::PointBufferSet& pbSet = m_manager->buffers();
    
    if (m_readStarted == false)
    {
        m_bufIter = pbSet.begin();
        m_pointIndex = 0;        
        m_readStarted = true;
        return true;
    }
    
    const pdal::PointBufferPtr& data = *m_bufIter;
    
    ++m_pointIndex;
    if (m_pointIndex < data->size())
    {
        return true;
    }
    
    m_pointIndex = 0;
    ++m_bufIter;
    if (m_bufIter != pbSet.end())
    {
        return true;
    }
    
    return false;
}


double PdalBridge::getFieldAsDouble(pdal::Dimension::Id::Enum dimensionIndex)
{
    const pdal::PointBufferPtr& data = *m_bufIter;

    double value = data->getFieldAs<double>(dimensionIndex, m_pointIndex);
            
    return value;

}
