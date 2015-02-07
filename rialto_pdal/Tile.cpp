
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


Tile::Tile(int level, int tx, int ty, Rectangle r, int maxLevel) :
    m_level(level),
    m_tileX(tx),
    m_tileY(ty),
    rect(r),
    parent(NULL),
    m_maxLevel(maxLevel),
    m_skip(0)
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
    for (int i=0; i<4; i++)
        if (m_children[i])
            delete m_children[i];
}


void Tile::add(int pointNumber, double lon, double lat, double height)
{
    assert(rect.contains(lon, lat));
    
    //printf("-- -- %d %d %d\n", pointNumber, m_skip, pointNumber % m_skip == 0);
    if (pointNumber % m_skip == 0) {
        Point p(lon, lat, height);
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
            t = new Tile(m_level+1, m_tileX*2, m_tileY*2, r, m_maxLevel);
            break;
        case QuadNW:
            t = new Tile(m_level+1, m_tileX*2+1, m_tileY*2, r, m_maxLevel);
            break;
        case QuadSE:
            t = new Tile(m_level+1, m_tileX*2, m_tileY*2+1, r, m_maxLevel);
            break;
        case QuadNE:
            t = new Tile(m_level+1, m_tileX*2+1, m_tileY*2+1, r, m_maxLevel);
            break;
        default:
            assert(0);
        }
        m_children[q] = t;
    }

    t->add(pointNumber, lon, lat, height);
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


void Tile::stats(int* numPointsPerLevel, int* numTilesPerLevel) const {

    numPointsPerLevel[m_level] += m_points.size();
    ++numTilesPerLevel[m_level];
    
    for (int i=0; i<4; i++)
        if (m_children[i]) 
            m_children[i]->stats(numPointsPerLevel, numTilesPerLevel);
}

#if 0


void Tile::write(gzFile fp) const {
    assert(fp);
    
    for (int y=0; y<SIZ + 1; y++) {
        for (int x=0; x<SIZ + 1; x++) {
            
            // TODO: do the edge condition later
            int xx = (x < SIZ) ? x : x - 1;
            int yy = (y < SIZ) ? y : y - 1;

            int idx = yy*SIZ + xx;
            double z = m_data[idx];

            boost::uint16_t height = convert(z);
            height = boost::uint16_t(1000.0 + 50000.0 * (double)(xx+yy)/(double)(SIZ+SIZ));
            gzwrite(fp, &height, 2);
        }
    }
    
    // child mask
    boost::uint8_t mask = 0x0;
    if (m_children) {
        if (m_children[0]) mask += 1; // sw
        if (m_children[1]) mask += 2; // se
        if (m_children[2]) mask += 8; // nw
        if (m_children[3]) mask += 4; // ne
    }
    gzwrite(fp, &mask, 1);

    // land-or-water byte
    boost::uint8_t lw = 0;
    gzwrite(fp, &lw, 1);
}
#endif

static bool exists(const char* path) {
    struct stat st;
    if(stat(path,&st) == 0)
        return true;
    return false;
}


void Tile::write(const char* prefix) const {
    //assert(dirExists("/tmp"));
    //assert(dirExists("/tmp/x"));
    //assert(!dirExists("/tmp/y"));
    
    char buf[1024];

    assert(exists(prefix));
    
    sprintf(buf, "%s/%d", prefix, m_level);
    if (!exists(buf)) {
        mkdir(buf, 0777);
    }
    
    sprintf(buf, "%s/%d/%d", prefix, m_level, m_tileX);
    if (!exists(buf)) {
        mkdir(buf, 0777);
    }
    
    sprintf(buf, "%s/%d/%d/%d.terrain", prefix, m_level, m_tileX, m_tileY);
    
    //printf("--> %s\n", buf);
    
    FILE* fp = fopen(buf, "wb");
    //gzFile fp = gzopen(buf, "wb");
    //write(fp);
    fclose(fp);
    //gzclose(fp);
    
    if (m_children) {
        for (int i=0; i<4; i++) {
            if (m_children[i]) {
                m_children[i]->write(prefix);
            }
        }
    }
}
