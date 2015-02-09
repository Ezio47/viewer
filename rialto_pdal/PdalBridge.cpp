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


const pdal::PointBufferSet& PdalBridge::buffers() const
{
    return m_manager->buffers();
}


boost::uint64_t PdalBridge::writeRia(const char* name, boost::uint64_t targetPointCount, bool xyzOnly) {

    boost::uint64_t skip = 0;
    if (targetPointCount != 0) {
        skip = m_numPoints / targetPointCount;
    }
    
    char* headerName = new char[strlen(name) + 3 + 1];
    strcat(headerName, name);
    strcat(headerName + strlen(name), "hdr");
    
    printf("Files: %s, %s\n", name, headerName);
    
    std::vector<pdal::Dimension::Id::Enum> dimIds = getDimIds();
    boost::uint32_t numDims = dimIds.size();

    printf("Writing %lld points with %d dimensions\n", targetPointCount, numDims);

    boost::uint64_t numWritten = 0;

    FILE* fpPoints = fopen(name, "wb");
    
    const pdal::PointBufferSet& bufs = m_manager->buffers();
    for (auto pi = bufs.begin(); pi != bufs.end(); ++pi)
    {
        const pdal::PointBufferPtr buf = *pi;
        numWritten += writeRia(fpPoints, buf, skip, xyzOnly);
    }

    fclose(fpPoints);

    FILE* fpHeader = fopen(headerName, "wb");
    writeRiaHeader(fpHeader, xyzOnly, numWritten);
    fclose(fpHeader);

    return numWritten;
}


void PdalBridge::writeRiaHeader(FILE* fp, bool xyzOnly, boost::uint64_t numWritten)
{
    // RIA header file format:
    //
    //   version: uint8 (currently set to 1)
    //   numPoints: uint64 (set to 0 if unknown)
    //   numDims: uint8
    //   foreach dim {
    //       datatype: uint16 (pdal::Dimension::Type::Enum)
    //       nameLen: uint8
    //       name: nameLen bytes
    //       min: double (set to -DBL_MAX if unknown)
    //       max: double (set to DBL_MAX if unknown)
    //   }
    //
    // RIA data file format:
    //
    //   foreach point {
    //       foreach dim {
    //           data: dimSize bytes, stored as datatype
    //       }
    //   }

    const boost::uint8_t version = 1;
    fwrite(&version, 1, 1, fp);
   
    fwrite(&numWritten, 8, 1, fp);
        
    std::vector<pdal::Dimension::Id::Enum> dimIds = getDimIds();
    size_t numDims_ = dimIds.size();
    const boost::uint8_t numDims = (boost::uint8_t)numDims_;
    fwrite(&numDims, 1, 1, fp);

    for (int i=0; i<numDims; i++) {
        const pdal::Dimension::Id::Enum id = dimIds[i];
        
        if (xyzOnly &&
              id != pdal::Dimension::Id::Enum::X &&
              id != pdal::Dimension::Id::Enum::Y &&
              id != pdal::Dimension::Id::Enum::Z)
        {
            continue;
        }

        const pdal::Dimension::Type::Enum dataType_ = getDimType(id);
        boost::uint16_t dataType = (boost::uint16_t)dataType_;
        fwrite(&dataType, 2, 1, fp);

        const size_t dimSize = pdal::Dimension::size(dataType_);

        const char *name = pdal::Dimension::name(id).c_str();
        const size_t nameLen_ = strlen(name);
        assert(nameLen_ < 256);
        const boost::uint8_t nameLen = (boost::uint8_t)nameLen_;
        fwrite(&nameLen, 1, 1, fp);
        fwrite(name, nameLen, 1, fp);

        double min, mean, max;
        getStats(id, min, mean, max);

        fwrite(&min, 8, 1, fp);
        fwrite(&max, 8, 1, fp);
    }
}


boost::uint64_t PdalBridge::writeRia(FILE* fp, const pdal::PointBufferPtr& buf, boost::uint64_t skip, bool xyzOnly)
{
    uint32_t pointIndex(0);
    std::vector<pdal::Dimension::Id::Enum> dimIds = getDimIds();
    boost::uint32_t numDims = dimIds.size();
    boost::uint32_t numWritten = 0;

    for (pdal::PointId idx = 0; idx < buf->size(); ++idx)
    {
        if (idx % 100000 == 0) {
            printf("%f complete\n", ((double)idx/(double)buf->size()) * 100.0);
        }

        if (skip != 0) {
            if (idx % skip != 0) continue;
        }

        char tmp[8];

        for (int i=0; i<numDims; i++) {

            const pdal::Dimension::Id::Enum id = dimIds[i];
        
            if (xyzOnly &&
                id != pdal::Dimension::Id::Enum::X &&
                id != pdal::Dimension::Id::Enum::Y &&
                id != pdal::Dimension::Id::Enum::Z)
            {
                continue;
            }
        
            pdal::Dimension::Type::Enum type = getDimType(id);
            size_t size = pdal::Dimension::size(type);
        
            buf->getRawField(id, idx, tmp);
         
            fwrite(tmp, size, 1, fp);
        }

        ++numWritten;
    }

    return numWritten;
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

    const pdal::stats::Summary& summary = ((pdal::StatsFilter*)m_filter2)->getStats(id);
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
