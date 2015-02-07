
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




TileWriter::TileWriter(int maxLevel) :
    m_maxLevel(maxLevel)
{    
    Rectangle r00(-180, -90, 0, 90);
    Rectangle r10(0, -90, 180, 90);
    m_root0 = new Tile(0, 0, 0, r00, m_maxLevel);
    m_root1 = new Tile(0, 0, 1, r10, m_maxLevel);
    
    return;
}


TileWriter::~TileWriter()
{
    delete m_root0;
    delete m_root1;
}


void TileWriter::seed(const pdal::PointBufferSet& pointBuffers)
{

    for (auto pi = pointBuffers.begin(); pi != pointBuffers.end(); ++pi)
    {
        const pdal::PointBufferPtr pointBuffer = *pi;
        seed(pointBuffer);
    }
    
    int numTilesPerLevel[32];
    int numPointsPerLevel[32];
    
    for (int i=0; i<32; i++) {
        numTilesPerLevel[i] = 0;
        numPointsPerLevel[i] = 0;
    }
    
    m_root0->stats(numPointsPerLevel,numTilesPerLevel);
    m_root1->stats(numPointsPerLevel, numTilesPerLevel);

    for (int i=0; i<=m_maxLevel; i++) {
        printf("L%d: tiles=%d points=%d\n", i, numTilesPerLevel[i], numPointsPerLevel[i]);
    }
}

    
void TileWriter::seed(const pdal::PointBufferPtr& buf)
{        
    for (pdal::PointId idx = 0; idx < buf->size(); ++idx)
    {
        pdal::Dimension::Id::Enum xdim = pdal::Dimension::Id::Enum::X;
        pdal::Dimension::Id::Enum ydim = pdal::Dimension::Id::Enum::Y;
        pdal::Dimension::Id::Enum zdim = pdal::Dimension::Id::Enum::Z;
        
        double lon = buf->getFieldAs<double>(xdim, idx);
        double lat = buf->getFieldAs<double>(ydim, idx);
        double h = buf->getFieldAs<double>(zdim, idx);
    
        if (lon < 0) {
            m_root0->add(lon, lat, h);
        } else {
            m_root1->add(lon, lat, h);
        }
    }
}
