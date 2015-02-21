// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


#include "PdalBridge.hpp"
#include <pdal/StatsFilter.hpp>


const char* epsg4326_wkt = "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433],AUTHORITY[\"EPSG\",\"4326\"]]";


PdalBridge::PdalBridge(bool debug, boost::uint32_t verbosity) :
    m_debug(debug),
    m_verbosity(verbosity),
    m_manager(NULL),
    m_reader(NULL),
    m_numPoints(0),
    m_doReproj(true)
{
}


PdalBridge::~PdalBridge()
{
    close();
}


void PdalBridge::open(const std::string& fname, bool doReproj)
{
    m_doReproj = doReproj;
    
    m_manager = new pdal::PipelineManager();
    if (!m_manager)
    {
        close();
        throw pdal::pdal_error("Failed to create PDAL pipeline manager.");
    }

    pdal::Stage* stage = NULL;
    {
        m_reader = m_manager->addReader("readers.las");
        pdal::Options opts;
        opts.add("filename", fname);
        m_reader->setOptions(opts);
        stage = m_reader;
    }

    if (m_doReproj) {
        m_reprojFilter = m_manager->addFilter("filters.reprojection", m_reader);
        pdal::Options opts;

        const pdal::SpatialReference out_ref(epsg4326_wkt);
        opts.add("out_srs", out_ref.getWKT());
        m_reprojFilter->setOptions(opts);
        
        stage = m_reprojFilter;
    }

    {
        m_statsFilter = m_manager->addFilter("filters.stats", stage);
        pdal::Options opts;
        
        stage = m_statsFilter;
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


void PdalBridge::getRect(double& west, double& south, double& east, double& north) const
{
    double min, mean, max;
    
    getStats(pdal::Dimension::Id::Enum::X, min, mean, max);
    west = min;
    east = max;
    
    getStats(pdal::Dimension::Id::Enum::Y, min, mean, max);
    south = min;
    north = max;
}


const pdal::PointBufferSet& PdalBridge::buffers() const
{
    return m_manager->buffers();
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
    //pdal::MetadataNode m = m_filter2->getMetadata();
    //std::vector<pdal::MetadataNode> children = m.children("statistic");
    //for (auto mi: children)
    //{
    //    dumper(mi, 0);
    //}

    //pdal::PointContextRef context = m_manager->context();
    //dumper(context.metadata());

    const pdal::stats::Summary& summary = ((pdal::StatsFilter*)m_statsFilter)->getStats(id);
    min = summary.minimum();
    mean = summary.average();
    max = summary.maximum();
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
