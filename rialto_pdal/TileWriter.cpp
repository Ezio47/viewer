
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
    Rectangle rect(90.0, -90.0, 180.0, -180.0);
    m_scheme = new TilingScheme(rect, 2, 1);
    
    const int xMax = m_scheme->getNumberOfXTilesAtLevel(maxLevel);
    const int yMax = m_scheme->getNumberOfXTilesAtLevel(maxLevel);
    m_storage = new CloudBuffer(maxLevel, xMax, yMax);
    
    return;
}


TileWriter::~TileWriter()
{
    delete m_scheme;
    delete m_storage;
}


void TileWriter::build(const pdal::PointBufferSet& pointBuffers)
{
    seed(pointBuffers);
    
    for (int parentLevel = m_maxLevel-1; parentLevel != 0; parentLevel--)
    {
        generateLevel(parentLevel);
    }
}


void TileWriter::seed(const pdal::PointBufferSet& pointBuffers)
{
    for (auto pi = pointBuffers.begin(); pi != pointBuffers.end(); ++pi)
    {
        const pdal::PointBufferPtr pointBuffer = *pi;
        seed(pointBuffer);
    }
}

    
void TileWriter::seed(const pdal::PointBufferPtr& buf)
{
    const int xMax = m_scheme->getNumberOfXTilesAtLevel(m_maxLevel);
    const int yMax = m_scheme->getNumberOfXTilesAtLevel(m_maxLevel);
        
    for (pdal::PointId idx = 0; idx < buf->size(); ++idx)
    {
        pdal::Dimension::Id::Enum xdim = pdal::Dimension::Id::Enum::X;
        pdal::Dimension::Id::Enum ydim = pdal::Dimension::Id::Enum::Y;
        pdal::Dimension::Id::Enum zdim = pdal::Dimension::Id::Enum::Z;
        
        double lon = buf->getFieldAs<double>(xdim, idx);
        double lat = buf->getFieldAs<double>(ydim, idx);
        double h = buf->getFieldAs<double>(zdim, idx);
    
        int tx, ty;
        bool ok = m_scheme->positionToTileXY(lon, lat, m_maxLevel, tx, ty);
        assert(ok);
        
        Tile* tile = m_storage->add(m_maxLevel, tx, ty);
        tile->add(lon, lat, h);
    }
}


void TileWriter::generateLevel(int level, int tx, int ty, Tile& srcTile)
{
    std::vector<Point>& vec = srcTile.vec();
    const int len = vec.size();
        
    for (int i = 0; i < len; i++) { 
    
        const double lon = vec[i].x;
        const double lat = vec[i].y;
        const double height = vec[i].z;
        
        int tx, ty;
        bool ok = m_scheme->positionToTileXY(lon, lat, level, tx, ty);
        assert(ok);
        
        Tile* dstTile = m_storage->add(level, tx, ty);
        dstTile->add(lon, lat, height);
    }
}


void TileWriter::generateLevel(int parentLevel)
{
    const int childLevel = parentLevel - 1;
    
    const int xMax = m_scheme->getNumberOfXTilesAtLevel(childLevel);
    const int yMax = m_scheme->getNumberOfXTilesAtLevel(childLevel);
    
    for (int x = 0; x < xMax; x++) {
        for (int y = 0; y < yMax; y++) {
        
            Tile* srcTile = m_storage->get(childLevel, x, y);
            if (!srcTile) continue;
         
            generateLevel(parentLevel, x, y, *srcTile);
        }
    }
}




#if 0

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
    
    double xmin = DBL_MAX, ymin = DBL_MAX;
    double xmax = -DBL_MAX, ymax = -DBL_MAX;
    m_root0->getMinMax(xmin, ymin, xmax, ymax);
    m_root1->getMinMax(xmin, ymin, xmax, ymax);
    printf("%f %f = %f %f\n", xmin, ymin, xmax, ymax);
    double xdelta = xmax - xmin;
    double ydelta = ymax - ymin;
    double delta = (xdelta < ydelta) ? xdelta : ydelta;
    delta = delta / 2.0;
    printf("%f %f %f\n", xdelta, ydelta, delta);
    printf("%f %f = %f\n", xmin + delta, ymin + delta, delta);
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
    
    if (!Tile::exists(prefix.c_str())) {
        mkdir(prefix.c_str(), 0777);
    }
    
    char buf[1024];
    sprintf(buf, "%s/%s", prefix.c_str(), "layer.json");
    if (!Tile::exists(buf)) {
        FILE* fp = fopen(buf, "w");
        fprintf(fp, "{\n");
        fprintf(fp, "  \"tilejson\": \"2.1.0\",\n");
        fprintf(fp, "  \"format\": \"heightmap-1.0\",\n");
        fprintf(fp, "  \"version\": \"1.0.0\",\n");
        fprintf(fp, "  \"scheme\": \"tms\",\n");
        fprintf(fp, "  \"tiles\": [\"{z}/{x}/{y}.terrain?v={version}\"]\n");
        fprintf(fp, "}\n");
        fclose(fp);
    }

    m_root0->write(prefix);
    m_root1->write(prefix);
}
#endif
