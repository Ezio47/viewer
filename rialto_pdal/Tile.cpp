
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


Tile::Tile(int level, int x, int y) :
    m_level(level),
    m_x(x),
    m_y(y)
{
}


Tile::~Tile()
{
}


void Tile::add(double x, double y, double z)
{
    Point p(x,y,z);
    m_points.push_back(p);
}


#if 0

Tile::Tile(int level, int colNum, int rowNum, Tile* parent) {
    m_level = level;
    m_parent = parent;
    
    m_colNum = colNum;
    m_rowNum = rowNum;

    if (colNum % 2 == 0) {
        if (rowNum % 2 == 0)
            m_quadrant = QuadrantSW;
        else
            m_quadrant = QuadrantNW;
    } else {
        if (rowNum % 2 == 0)
            m_quadrant = QuadrantSE;
        else
            m_quadrant = QuadrantNE;
    }

    if (parent == NULL) {
        assert(m_quadrant == QuadrantSW || m_quadrant == QuadrantSE);

        m_xmin = (m_quadrant == QuadrantSW) ? -180.0 : 0.0;
        m_xmax = m_xmin + 180.0;
        m_ymin = -90.0;
        m_ymax = 90;
        
        m_numCols = 2;
        m_numRows = 1;        
        
    } else {        
        setBounds();

        m_numCols = parent->getNumCols() * 2;
        m_numRows = parent->getNumRows() * 2;
    }
    
    m_xres = (m_xmax - m_xmin) / SIZ;
    m_yres = (m_ymax - m_ymin) / SIZ;
    m_xmid = m_xmin + (m_xmax - m_xmin) / 2.0;
    m_ymid = m_ymin + (m_ymax - m_ymin) / 2.0;

    m_data = new double[SIZ*SIZ];
    for (int i=0; i<SIZ*SIZ; i++) m_data[i] = DBL_MAX;

    m_children = NULL;
    
    
    m_id = tileCount;
    ++tileCount;
    
    //printf("TILE: %d.%d.%d   min=(%f,%f)  max=(%f,%f)\n",
        //m_level, m_colNum, m_rowNum, m_xmin, m_ymin, m_xmax, m_ymax);
}


void Tile::setBounds() {
    assert(m_parent);
    switch (m_quadrant) {
        case QuadrantSW:
            m_xmin = m_parent->m_xmin;
            m_xmax = m_parent->m_xmid;
            m_ymin = m_parent->m_ymin;
            m_ymax = m_parent->m_ymid;
            break;
        case QuadrantSE:
            m_xmin = m_parent->m_xmid;
            m_xmax = m_parent->m_xmax;
            m_ymin = m_parent->m_ymin;
            m_ymax = m_parent->m_ymid;
            break;
        case QuadrantNE:
            m_xmin = m_parent->m_xmid;
            m_xmax = m_parent->m_xmax;
            m_ymin = m_parent->m_ymid;
            m_ymax = m_parent->m_ymax;
            break;
        case QuadrantNW:
            m_xmin = m_parent->m_xmin;
            m_xmax = m_parent->m_xmid;
            m_ymin = m_parent->m_ymid;
            m_ymax = m_parent->m_ymax;
            break;
        default:
            assert(false); // TODO
    }
}


// 0..3
Tile::Quadrant Tile::whichChildQuadrant(double x, double y) {

    if (x >= m_xmin && x < m_xmid &&
        y >= m_ymin && y < m_ymid) return QuadrantSW;
    if (x >= m_xmid && x < m_xmax &&
        y >= m_ymin && y < m_ymid) return QuadrantSE;
    if (x >= m_xmid && x < m_xmax &&
        y >= m_ymid && y < m_ymax) return QuadrantNE;
    if (x >= m_xmin && x < m_xmid &&
        y >= m_ymid && y < m_ymax) return QuadrantNW;
            
    assert(0);
    return QuadrantInvalid;
}

bool Tile::containsPoint(double x, double y) {
    
    if (x < m_xmin || x >= m_xmax) return false;
    if (y < m_ymin || y >= m_ymax) return false;
    return true;
}
                

void Tile::setPoint(double x, double y, double z)
{
    assert(containsPoint(x,y));
    
    //printf("test at %d.%d.%d (%f..%f): %f %f\n", m_level, m_colNum, m_rowNum, m_xmin, m_xmax, x, y);

    // this tile, or one of its children, contains the point
    
    if (m_level == MAXLEVEL) {
        // we don't have room to make another level down, so set here
        
        int i = floor((x - m_xmin) / m_xres);
        int j = floor((y - m_ymin) / m_yres);
        assert(i>=0 && i<SIZ);
        assert(j>=0 && j<SIZ);
        
        assert(m_data);

        int idx = j*SIZ + i;
        assert(idx < SIZ*SIZ);
        m_data[idx] = z;
        
        //printf("    SET: %d.%d.%d at %d\n", m_level, m_colNum, m_rowNum, idx);
        return;
    }

    // we need use (or make) a child to hold the point
    Quadrant q = whichChildQuadrant(x,y);
    int qi = (int)q;
    
    if (m_children == NULL) {
        m_children = new Tile*[4];
        for (int i=0; i<4; i++) {
            m_children[i] = NULL;
        }
    }
    
    if (m_children[qi] == NULL) {
        int colNum = getColNum() * 2 + ((q==QuadrantSE || q==QuadrantNE) ? 1:0);
        int rowNum = getRowNum() * 2 + ((q==QuadrantNE || q==QuadrantNW) ? 1:0);
        //printf("at %d.%d.%d: qi=%d\n", m_level, m_colNum, m_rowNum, qi);
        m_children[qi] = new Tile(m_level + 1,  colNum, rowNum, this);
        assert(m_children[qi]->getQuadrant() == q);
    }
    
    m_children[qi]->setPoint(x,y,z);

    return;
}


void Tile::dump() {    
    if (m_data != NULL) {
        int cnt = 0;
        for (int idx=0; idx<SIZ*SIZ; idx++) {
            if (m_data[idx] != DBL_MAX) ++cnt;
        }
        
        if (m_level == MAXLEVEL) {
            printf("%d.%d.%d: min=(%f,%f)  max=(%f,%f)  cnt=%d\n",
                m_level, m_colNum, m_rowNum,
                m_xmin, m_ymin, m_xmax, m_ymax,
                cnt);
        }
    }
    
    if (m_children) {
        for (int i=0; i<4; i++) {
            if (m_children[i]) m_children[i]->dump();
        }
    }
}


double Tile::getPoint(int x, int y) {
    assert(x >= 0 && x < SIZ);
    assert(y >= 0 && y < SIZ);
    int idx = y*SIZ + x;
    return m_data[idx];
}


double Tile::computeCell(int x, int y) {
    
    // figure out which child
    Tile* tile = NULL;
    if (y < SIZ/2) {
        if (x < SIZ/2) {
            // SW
            tile = m_children[0];
            x = x * 2;
            y = y * 2;
        } else {
            // SE
            tile = m_children[1];
            x = (x - SIZ/2) * 2;
            y = y * 2;
        }
    } else {
        if (x < SIZ/2) {
            // NW
            tile = m_children[2];
            x = x * 2;
            y = (y - SIZ/2) * 2;
        } else {
            // NE
            tile = m_children[3];
            x = (x - SIZ/2) * 2;
            y = (y - SIZ/2) * 2;
        }
    }

    if (!tile) return DBL_MAX;

    // TODO: hack for a 4-point stencil
    int cnt = 0;
    double sum = 0.0;

    double sw = tile->getPoint(x, y); // SW
    if (sw != DBL_MAX) {
        ++cnt;
        sum += sw;
    }
    if (x < SIZ-1) {
        double se = tile->getPoint(x+1, y);
        if (se != DBL_MAX) {
            ++cnt;
            sum += se;
        }
    }
    if (x < SIZ-1 && y < SIZ-1) {
        double ne = tile->getPoint(x+1, y+1);
        if (ne != DBL_MAX) {
            ++cnt;
            sum += ne;
        }
    }
    if (y < SIZ-1) {
        double nw = tile->getPoint(x, y+1);
        if (nw != DBL_MAX) {
            ++cnt;
            sum += nw;
        }
    }

    if (cnt == 0) {
        return DBL_MAX;
    }
     
    double avg = sum / cnt;
    return avg;
}
        
        
void Tile::fillInCells() {
    
    if (m_children == NULL) return;
    
    for (int i=0; i<4; i++) {
        if (m_children[i]) {
            m_children[i]->fillInCells();
        }
    }

    // this tile's Ith cell is the avg of the children's Ith cells    
    for (int y=0; y<SIZ; y++) {
        for (int x=0; x<SIZ; x++) {
            int idx = y*SIZ + x;
            m_data[idx] = computeCell(x, y);
        }
    }
    
    return;
}


boost::uint16_t Tile::convert(double z) const {
    if (z == DBL_MAX) return 0;
    
    // TODO: assume Z is in meters for now
    
    // the spec calls for height to be in 0.2 meter increments,
    // with a lower bound of -1000 meters
    
    double e = (z + 1000.0) * 5.0;
    if (e < 0.0) e = 0.0;
    if (e > 65535.0) e = 65535.0;
    
    boost::uint16_t h = (boost::uint16_t)e;
    return h;
}


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


void Tile::getMinMax(double& xmin, double& ymin, double& xmax, double& ymax) const {    
    if (m_children) {
        for (int i=0; i<4; i++) {
            if (m_children[i]) {
                m_children[i]->getMinMax(xmin, ymin, xmax, ymax);
            }
        }
    }
    
    if (m_level == MAXLEVEL) {
        if (m_xmin < xmin) xmin = m_xmin;
        if (m_ymin < ymin) ymin = m_ymin;
        if (m_xmax > xmax) xmax = m_xmax;
        if (m_ymax > ymax) ymax = m_ymax;
    }    
}
#endif
