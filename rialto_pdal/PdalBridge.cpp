#include "PdalBridge.hpp"


const char* epsg4326_wkt = "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433],AUTHORITY[\"EPSG\",\"4326\"]]";


PdalBridge::PdalBridge(bool debug, boost::uint32_t verbosity) :
    m_debug(debug),
    m_verbosity(verbosity),
    m_manager(NULL),
    m_reader(NULL),
    m_numPoints(0)
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
        m_reader = m_manager->addReader("readers.las");
        pdal::Options opts;
        opts.add("filename", fname);
        m_reader->setOptions(opts);
    }

    {
        m_filter1 = m_manager->addFilter("filters.reprojection", m_reader);
        pdal::Options opts;
        
        const pdal::SpatialReference out_ref(epsg4326_wkt);
        opts.add("out_srs", out_ref.getWKT());
        m_filter1->setOptions(opts);
    }

    {
        m_filter2 = m_manager->addFilter("filters.stats", m_filter1);
        pdal::Options opts;
    }

    pdal::PointContextRef context = m_manager->context();
    
    m_manager->prepare();
    m_numPoints = m_manager->execute();
    m_dimensionIds = context.dims();
    
    /*const pdal::PointBufferSet& bufs = m_manager->buffers();
    for (auto pi = bufs.begin(); pi != bufs.end(); ++pi)
    {
        pdal::PointBufferPtr buf = *pi;
        printf("buf: %ld\n", buf->size());
    }*/
    
    return;
}


void PdalBridge::close()
{
    if (m_manager)
    {
        delete m_manager;
        m_manager = NULL;
    }
    
    return;
}


void PdalBridge::writeRia(const char* name, boost::uint64_t targetPointCount) {
    
    boost::uint64_t skip = 0;
    if (targetPointCount != 0) {
        skip = m_numPoints / targetPointCount;
    }
    
    FILE* fp = fopen(name, "wb");
    
    const pdal::PointBufferSet& bufs = m_manager->buffers();
    for (auto pi = bufs.begin(); pi != bufs.end(); ++pi)
    {
        const pdal::PointBufferPtr buf = *pi;
        writeRia(fp, buf, skip);
    }
    
    fclose(fp);
}


void PdalBridge::writeRia(FILE* fp, const pdal::PointBufferPtr& buf, boost::uint64_t skip)
{
    uint32_t pointIndex(0);
    
    for (pdal::PointId idx = 0; idx < buf->size(); ++idx)
    {
        if (idx % 10000 == 0) {
            printf("%f complete\n", ((double)idx/(double)buf->size()) * 100.0);
        }

        if (skip != 0) {
            if (idx % skip != 0) continue;
        }
        
        pdal::Dimension::Id::Enum xdim = pdal::Dimension::Id::Enum::X;
        pdal::Dimension::Id::Enum ydim = pdal::Dimension::Id::Enum::Y;
        pdal::Dimension::Id::Enum zdim = pdal::Dimension::Id::Enum::Z;
        
        double x = buf->getFieldAs<double>(xdim, idx);
        double y = buf->getFieldAs<double>(ydim, idx);
        double z = buf->getFieldAs<double>(zdim, idx);
        
        float xf = (float)x;
        float yf = (float)y;
        float zf = (float)z;

        fwrite(&xf, 4, 1, fp);
        fwrite(&yf, 4, 1, fp);
        fwrite(&zf, 4, 1, fp);        
    }
}


void PdalBridge::writeTiles() {
    const pdal::PointBufferSet& bufs = m_manager->buffers();
    TileWriter* tw = new TileWriter();
    tw->goBuffers(bufs);
    
    tw->write("./tmp");
}


boost::uint64_t PdalBridge::getNumPoints() const
{
    return m_numPoints;
}


static void dumper(pdal::MetadataNode m, int indent=0)
{
    for (int i=0; i<indent*4; i++)
        printf(" ");
        
    printf("%s  --  %s\n", m.name().c_str(), m.value().c_str());
        
    std::vector<pdal::MetadataNode> ms = m.children();
    for (auto mi: ms)
    {    
        dumper(mi, indent+1);
    }
}
    
    
void PdalBridge::getStats(pdal::Dimension::Id::Enum id, double& min, double& mean, double& max) const
{
    pdal::MetadataNode m = m_filter2->getMetadata();
    std::vector<pdal::MetadataNode> children = m.children("statistic");
    for (auto mi: children)
    {    
        dumper(mi, 0);
    }
    
    //pdal::PointContextRef context = m_manager->context();
    //dumper(context.metadata());
    
//    const pdal::filters::stats::Summary& summary = m_statsStage->getStats(id);
//    min = summary.minimum();
//    mean = summary.average();
//    max = summary.maximum();
}


const pdal::Dimension::IdList& PdalBridge::getDimIds() const
{
    return m_dimensionIds;
}


pdal::Dimension::Type::Enum PdalBridge::getDimType(pdal::Dimension::Id::Enum id) const
{
    pdal::PointContextRef context = m_manager->context();
    pdal::Dimension::Type::Enum type = context.dimType(id);
    return type;
}


std::string PdalBridge::getWkt() const
{
    
    pdal::PointContextRef context = m_manager->context();
    
    const pdal::SpatialReference& srs = context.spatialRef();
    std::string s = srs.getWKT();
    return s;
}
