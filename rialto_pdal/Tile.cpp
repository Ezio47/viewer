
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
    m_maxLevel(maxLevel)
{    
    printf("created tb (l=%d, tx=%d, ty=%d)  --  w%f s%f e%f n%f\n",
        m_level, m_tileX, m_tileY,
        rect.west, rect.south, rect.east, rect.north);
    
    m_children = new Tile*[4];
    m_children[0] = NULL;
    m_children[1] = NULL;
    m_children[2] = NULL;
    m_children[3] = NULL;
}


Tile::~Tile()
{
    for (int i=0; i<4; i++)
        if (m_children[i])
            delete m_children[i];
}


void Tile::add(double lon, double lat, double height)
{
    assert(rect.contains(lon, lat));
    
    Point p(lon, lat, height);
    m_points.push_back(p);
    
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

    t->add(lon, lat, height);
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


bool Tile::exists(const char* path) {
    struct stat st;
    if(stat(path,&st) == 0)
        return true;
    return false;
}

void Tile::write(const std::string& prefix) const {
    //assert(dirExists("/tmp"));
    //assert(dirExists("/tmp/x"));
    //assert(!dirExists("/tmp/y"));
    
    char buf[1024];

    sprintf(buf, "%s/%d", prefix.c_str(), m_level);
    if (!exists(buf)) {
        mkdir(buf, 0777);
    }
    
    sprintf(buf, "%s/%d/%d", prefix.c_str(), m_level, m_colNum);
    if (!exists(buf)) {
        mkdir(buf, 0777);
    }
    
    sprintf(buf, "%s/%d/%d/%d.terrain", prefix.c_str(), m_level, m_colNum, m_rowNum);
    
    printf("--> %s\n", buf);
    
    //FILE* fp = fopen(buf, "wb");
    gzFile fp = gzopen(buf, "wb");
    write(fp);
    //fclose(fp);
    gzclose(fp);
    
    if (m_children) {
        for (int i=0; i<4; i++) {
            if (m_children[i]) {
                m_children[i]->write(prefix);
            }
        }
    }
}

#endif
