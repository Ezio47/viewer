// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


#include "TileWriter.hpp"
#include <pdal/Algorithm.hpp>
#include <pdal/PointBuffer.hpp>
#include <pdal/pdal_internal.hpp>

#include <iostream>
#include <algorithm>
#include <map>

#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/erase.hpp>
#include <boost/tokenizer.hpp>

#include <zlib.h>

#include <sys/stat.h>
#include "Tile.hpp"




TileWriter::TileWriter(const PdalBridge& pdal, bool global, int maxLevel) :
    m_pdal(pdal),
    m_maxLevel(maxLevel),
    m_global(global)
{    
    if (global) {
        m_numTilesX = 2;
        m_numTilesY = 1;
    
        m_rectangle = Rectangle(-180, -90, 180, 90);

        Rectangle r00(-180, -90, 0, 90);
        Rectangle r10(0, -90, 180, 90);
        m_roots = new Tile*[2];
        m_roots[0] = new Tile(0, 0, 0, r00, m_maxLevel, m_pdal);
        m_roots[1] = new Tile(0, 1, 0, r10, m_maxLevel, m_pdal);   
    } else {
        m_numTilesX = 1;
        m_numTilesY = 1;

        double west, south, east, north;
        pdal.getRect(west, south, east, north);
        m_rectangle = Rectangle(west, south, east, north);
        
        m_roots = new Tile*[1];
        m_roots[0] = new Tile(0, 0, 0, m_rectangle, m_maxLevel, m_pdal);        
    }
        
    m_bytesPerPoint = 0;
    std::vector<pdal::Dimension::Id::Enum> dimIds = m_pdal.getDimIds();
    for (int i=0; i<dimIds.size(); i++) {
        const pdal::Dimension::Id::Enum id = dimIds[i];
        pdal::Dimension::Type::Enum type = m_pdal.getDimType(id);
        size_t size = pdal::Dimension::size(type);
        m_bytesPerPoint += size;
    }
    
    return;
}


TileWriter::~TileWriter()
{
    if (m_global) {
        delete m_roots[0];
        delete m_roots[1];
    } else {
        delete m_roots[0];
    }
    delete[] m_roots;
}


void TileWriter::build()
{
    const pdal::PointBufferSet& pointBuffers = m_pdal.buffers();
    
    int pointNumber = 0;
    
    assert(pointBuffers.size() == 1);
    for (auto pi = pointBuffers.begin(); pi != pointBuffers.end(); ++pi)
    {
        const pdal::PointBufferPtr pointBuffer = *pi;
        build(pointBuffer, pointNumber);
    }
}


char* TileWriter::getPointData(const pdal::PointBufferPtr& buf, int& pointNumber)
{
    char* p = new char[m_bytesPerPoint];
    char* q = p;
    
    std::vector<pdal::Dimension::Id::Enum> dimIds = m_pdal.getDimIds();
    boost::uint32_t numDims = dimIds.size();

    for (int i=0; i<numDims; i++) {

        const pdal::Dimension::Id::Enum id = dimIds[i];
        
        pdal::Dimension::Type::Enum type = m_pdal.getDimType(id);
        size_t size = pdal::Dimension::size(type);
        
        buf->getRawField(id, pointNumber, q);
        
        q += size;
    }

    return p;
}


void TileWriter::build(const pdal::PointBufferPtr& buf, int& pointNumber)
{        
    for (pdal::PointId idx = 0; idx < buf->size(); ++idx)
    {
        char* p = getPointData(buf, pointNumber);
    
        pdal::Dimension::Id::Enum xdim = pdal::Dimension::Id::Enum::X;
        pdal::Dimension::Id::Enum ydim = pdal::Dimension::Id::Enum::Y;        
        double lon = buf->getFieldAs<double>(xdim, idx);
        double lat = buf->getFieldAs<double>(ydim, idx);
    
        if (m_global) {
            if (lon < 0) {
                m_roots[0]->add(pointNumber, p, lon, lat);
            } else {
                m_roots[1]->add(pointNumber, p, lon, lat);
            }
        } else {
            m_roots[0]->add(pointNumber, p, lon, lat);
        }
                
        ++pointNumber;
    }
}


void TileWriter::dump() const
{
    boost::uint32_t numTilesPerLevel[32];
    boost::uint64_t numPointsPerLevel[32];
    
    for (int i=0; i<=m_maxLevel; i++) {
        numTilesPerLevel[i] = 0;
        numPointsPerLevel[i] = 0;
    }
    
    if (m_global) {
        m_roots[0]->collectStats(numTilesPerLevel, numPointsPerLevel);
        m_roots[1]->collectStats(numTilesPerLevel, numPointsPerLevel);
    } else {
        m_roots[0]->collectStats(numTilesPerLevel, numPointsPerLevel);
    }
    
    for (int i=0; i<=m_maxLevel; i++) {
        printf("L%d: %d tiles, %llu points\n", i, numTilesPerLevel[i], numPointsPerLevel[i]);
    }
}


void TileWriter::write(const char* dir) const
{
    if (m_global) {
        m_roots[0]->write(dir);
        m_roots[1]->write(dir);
    } else {
        m_roots[0]->write(dir);
    }
    
    writeHeader(dir);                 
}


void TileWriter::writeHeader(const char* dir) const
{
    char* filename = new char[strlen(dir) + 64];
    filename[0] = 0;
    strcat(filename, dir);
    strcat(filename, "/");
    strcat(filename, "header.json");
    
    printf("Writing header to %s\n", filename);
    
    FILE* fp = fopen(filename, "wt"); 

    double xminBbox, xmeanBbox, xmaxBbox;
    double yminBbox, ymeanBbox, ymaxBbox;
    double zminBbox, zmeanBbox, zmaxBbox;
    m_pdal.getStats(pdal::Dimension::Id::Enum::X, xminBbox, xmeanBbox, xmaxBbox);
    m_pdal.getStats(pdal::Dimension::Id::Enum::Y, yminBbox, ymeanBbox, ymaxBbox);
    m_pdal.getStats(pdal::Dimension::Id::Enum::Z, zminBbox, zmeanBbox, zmaxBbox);

    fprintf(fp, "{\n");
    fprintf(fp, "    \"version\": 3,\n");
   
    fprintf(fp, "    \"tilebbox\": [%f, %f, %f, %f],\n",
            m_rectangle.west,
            m_rectangle.south,
            m_rectangle.east,
            m_rectangle.north);

    fprintf(fp, "    \"numTilesX\": %d,\n", m_numTilesX);
    fprintf(fp, "    \"numTilesY\": %d,\n", m_numTilesY);
    
    fprintf(fp, "    \"databbox\": [%f, %f, %f, %f],\n",
            xminBbox, yminBbox, xmaxBbox, ymaxBbox);

    fprintf(fp, "    \"numPoints\": %llu,\n", m_pdal.getNumPoints());
        
    std::vector<pdal::Dimension::Id::Enum> dimIds = m_pdal.getDimIds();
    const size_t numDims = dimIds.size();
    fprintf(fp, "    \"dimensions\": [\n");

    for (int i=0; i<numDims; i++) {
        const pdal::Dimension::Id::Enum id = dimIds[i];
        
        const pdal::Dimension::Type::Enum dataType = m_pdal.getDimType(id);
        const char *dataTypeName = pdal::Dimension::interpretationName(dataType).c_str();
        const char *name = pdal::Dimension::name(id).c_str();
        double min, mean, max;
        m_pdal.getStats(id, min, mean, max);

        fprintf(fp, "        {\n");
        fprintf(fp, "            \"datatype\": \"%s\",\n", dataTypeName);
        fprintf(fp, "            \"name\": \"%s\",\n", name);
        fprintf(fp, "            \"min\": %f,\n", min);
        fprintf(fp, "            \"mean\": %f,\n", mean);
        fprintf(fp, "            \"max\": %f\n", max);
        fprintf(fp, "        }%s\n", i==numDims-1 ? "" : ",");
    }
    fprintf(fp, "    ]\n");
    fprintf(fp, "}\n");
    
    fclose(fp);
    
    delete[] filename;
}
