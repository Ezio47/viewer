
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

#include "Tile.hpp"

const int MAXLEVEL = 14;
const int SIZ = 64;

static int tileCount = 0;




TileWriter::TileWriter()
{
    m_root0 = new Tile(0, 0, 0, NULL);
    m_root1 = new Tile(0, 1, 0, NULL);
}


void TileWriter::goBuffers(const pdal::PointBufferSet& bufs) {
    for (auto pi = bufs.begin(); pi != bufs.end(); ++pi)
    {
        const pdal::PointBufferPtr buf = *pi;
        goBuffer(buf);
    }

    printf("made %d tiles\n", tileCount);
    
    // now fill in the upper levels: use max of children
    m_root0->fillInCells();
    m_root1->fillInCells();
    
    m_root0->dump();
    m_root1->dump();
}
    

void TileWriter::goBuffer(const pdal::PointBufferPtr& buf)
{
    uint32_t pointIndex(0);
    
    for (pdal::PointId idx = 0; idx < buf->size(); ++idx)
    {
        pdal::Dimension::Id::Enum xdim = pdal::Dimension::Id::Enum::X;
        pdal::Dimension::Id::Enum ydim = pdal::Dimension::Id::Enum::Y;
        pdal::Dimension::Id::Enum zdim = pdal::Dimension::Id::Enum::Z;
        
        double x = buf->getFieldAs<double>(xdim, idx);
        double y = buf->getFieldAs<double>(ydim, idx);
        double z = buf->getFieldAs<double>(zdim, idx);
    
        if (x <= 0.0 && m_root0->containsPoint(x,y)) {
            m_root0->setPoint(x, y, z);
        } else {
            m_root1->setPoint(x, y, z);
        }
        
        if (idx % 10000 == 0) {
            printf("%f complete\n", ((double)idx/(double)buf->size()) * 100.0);
        }
    }
}


void TileWriter::write(const std::string& prefix) const {
    m_root0->write(prefix);
    m_root1->write(prefix);
}
