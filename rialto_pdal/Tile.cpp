
#include "Tile.hpp"
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


Tile::Tile(boost::uint32_t level, boost::uint32_t tx, boost::uint32_t ty, Rectangle r, boost::uint32_t maxLevel, const PdalBridge& pdal) :
    m_level(level),
    m_tileX(tx),
    m_tileY(ty),
    rect(r),
    m_maxLevel(maxLevel),
    m_skip(0),
    m_pdal(pdal)
{    
    //printf("created tb (l=%d, tx=%d, ty=%d) (slip%d)  --  w%f s%f e%f n%f\n",
      //  m_level, m_tileX, m_tileY, m_skip,
        //rect.west, rect.south, rect.east, rect.north);
    
    m_children = new Tile*[4];
    m_children[0] = NULL;
    m_children[1] = NULL;
    m_children[2] = NULL;
    m_children[3] = NULL;
    
    // level N+1 has 1/4 the points of level N
    //
    // level 3: skip 1
    // level 2: skip 4
    // level 1: skip 16
    // level 0: skip 256
    
    // max=3, max-level=u
    // 3-3=0  skip 1   4^0
    // 3-2=1  skip 4    4^1
    // 3-1=2  skip 16    4^2
    // 3-0=3  skip 64    4^3
    // 
    m_skip = pow(4, (m_maxLevel - m_level));
    //printf("level=%d  skip=%d\n", m_level, m_skip);
}


Tile::~Tile()
{
    for (int i=0; i<m_points.size(); i++) {
        char* p = m_points[i];
        delete[] p;
    }

    for (int i=0; i<4; i++) {
        if (m_children[i]) {
            delete m_children[i];
         }
     }
}


void Tile::add(boost::uint64_t pointNumber, char* p, double lon, double lat)
{
    assert(rect.contains(lon, lat));
    
    //printf("-- -- %d %d %d\n", pointNumber, m_skip, pointNumber % m_skip == 0);
    if (pointNumber % m_skip == 0) {
        m_points.push_back(p);
    }
        
    if (m_level == m_maxLevel) return;

    Quad q = rect.getQuadrantOf(lon, lat);
   // printf("which=%d\n", q);
    
    Tile* t = m_children[q];
    if (t == NULL)
    {
        Rectangle r = rect.getQuadrantRect(q);
        switch (q) {
        case QuadSW:
            t = new Tile(m_level+1, m_tileX*2, m_tileY*2, r, m_maxLevel, m_pdal);
            break;
        case QuadNW:
            t = new Tile(m_level+1, m_tileX*2+1, m_tileY*2, r, m_maxLevel, m_pdal);
            break;
        case QuadSE:
            t = new Tile(m_level+1, m_tileX*2, m_tileY*2+1, r, m_maxLevel, m_pdal);
            break;
        case QuadNE:
            t = new Tile(m_level+1, m_tileX*2+1, m_tileY*2+1, r, m_maxLevel, m_pdal);
            break;
        default:
            assert(0);
        }
        m_children[q] = t;
    }

    t->add(pointNumber, p, lon, lat);
}


void Tile::dump(int indent) const
{
    for (int i=0; i<indent; i++) printf("  ");
    
    printf("> (l=%d, tx=%d, ty=%d): %lu\n", m_level, m_tileX, m_tileY, m_points.size());
    
    m_children[QuadSW]->dump(indent+1);
    m_children[QuadNW]->dump(indent+1);
    m_children[QuadSE]->dump(indent+1);
    m_children[QuadNE]->dump(indent+1);
}


void Tile::collectStats(boost::uint32_t* numTilesPerLevel, boost::uint64_t* numPointsPerLevel) const {

    numPointsPerLevel[m_level] += m_points.size();
    ++numTilesPerLevel[m_level];
    
    for (int i=0; i<4; i++) {
        if (m_children[i]) {
            m_children[i]->collectStats(numTilesPerLevel, numPointsPerLevel);
        }
    }
}


static bool exists(const char* path) {
    struct stat st;
    if(stat(path,&st) == 0)
        return true;
    return false;
}


void Tile::write(const char* prefix) const
{
    char* filename = new char[strlen(prefix) + 1024];

    sprintf(filename, "%s", prefix);
    if (!exists(filename)) {
        mkdir(filename, 0777);
    }
    
    sprintf(filename, "%s/%d", prefix, m_level);
    if (!exists(filename)) {
        mkdir(filename, 0777);
    }
    
    sprintf(filename, "%s/%d/%d", prefix, m_level, m_tileX);
    if (!exists(filename)) {
        mkdir(filename, 0777);
    }
    
    sprintf(filename, "%s/%d/%d/%d.ria", prefix, m_level, m_tileX, m_tileY);
    
    //printf("--> %s\n", buf);
    
    FILE* fp = fopen(filename, "wb");
    //gzFile fp = gzopen(filename, "wb");
    
    writeData(fp);
    
    // child mask
    boost::uint8_t mask = 0x0;
    if (m_children) {
        if (m_children[QuadSW]) mask += 1;
        if (m_children[QuadSE]) mask += 2;
        if (m_children[QuadNE]) mask += 4;
        if (m_children[QuadNW]) mask += 8;
    }
    //gzwrite(fp, &mask, 1);
    fwrite(&mask, 1, 1, fp);
    
    
    fclose(fp);
    //gzclose(fp);
    
    if (m_children) {
        for (int i=0; i<4; i++) {
            if (m_children[i]) {
                m_children[i]->write(prefix);
            }
        }
    }
    
    fclose(fp);
    
    delete[] filename;
}


void Tile::writeData(FILE* fp) const
{
    std::vector<pdal::Dimension::Id::Enum> dimIds = m_pdal.getDimIds();
    boost::uint32_t numDims = dimIds.size();

    for (int i=0; i<m_points.size(); i++)
    {
        char* p = m_points[i];

        for (int i=0; i<numDims; i++) {

            const pdal::Dimension::Id::Enum id = dimIds[i];
        
            pdal::Dimension::Type::Enum type = m_pdal.getDimType(id);
            size_t size = pdal::Dimension::size(type);
         
            fwrite(p, size, 1, fp);
            
            p += size;
        }
    }
}
