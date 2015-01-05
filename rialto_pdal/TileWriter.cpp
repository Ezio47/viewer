
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

const int MAXLEVEL = 20;
const int SIZ = 64;

static int tileCount = 0;

Tile::Tile(int level, Tile* parent, int which, bool west) {
    
    m_level = level;
    m_which = which;
    m_parent = parent;
    m_west = west;
    
    m_data = new double[SIZ*SIZ];
    for (int i=0; i<SIZ*SIZ; i++) m_data[i] = DBL_MAX;

    m_children = NULL;
    
    setBounds();
    m_xres = (m_xmax - m_xmin) / SIZ;
    m_yres = (m_ymax - m_ymin) / SIZ;
    m_xmid = m_xmin + (m_xmax - m_xmin) / 2.0;
    m_ymid = m_ymin + (m_ymax - m_ymin) / 2.0;
    
    m_id = tileCount;
    ++tileCount;
}

void Tile::setBounds() {
    if (m_parent == NULL) {
        if (m_which == 1) {
            m_xmin = -180.0;
            m_xmax = 0.0;
            m_ymin = -90.0;
            m_ymax = 90.0;
        } else if (m_which == 2) {
            m_xmin = 0.0;
            m_xmax = 180;
            m_ymin = -90.0;
            m_ymax = 90;
        } else {
            assert(false);
        }
        
        return;
    }
    
    assert(m_parent);
    switch (m_which) {
        case 0:
            m_xmin = m_parent->m_xmin;
            m_xmax = m_parent->m_xmid;
            m_ymin = m_parent->m_ymin;
            m_ymax = m_parent->m_ymid;
            break;
        case 1:
            m_xmin = m_parent->m_xmid;
            m_xmax = m_parent->m_xmax;
            m_ymin = m_parent->m_ymin;
            m_ymax = m_parent->m_ymid;
            break;
        case 2:
            m_xmin = m_parent->m_xmid;
            m_xmax = m_parent->m_xmax;
            m_ymin = m_parent->m_ymid;
            m_ymax = m_parent->m_ymax;
            break;
        case 3:
            m_xmin = m_parent->m_xmin;
            m_xmax = m_parent->m_xmid;
            m_ymin = m_parent->m_ymid;
            m_ymax = m_parent->m_ymax;
            break;
        default:
            assert(false);
    }
}


// 0..3
int Tile::whichChild(double x, double y) {

    if (x >= m_xmin && x < m_xmid &&
        y >= m_ymin && y < m_ymid) return 0;
    if (x >= m_xmid && x < m_xmax &&
        y >= m_ymin && y < m_ymid) return 1;
    if (x >= m_xmid && x < m_xmax &&
        y >= m_ymid && y < m_ymax) return 2;
    if (x >= m_xmin && x < m_xmid &&
        y >= m_ymid && y < m_ymax) return 3;
            
    assert(0);
    return -999;
}

bool Tile::containsPoint(double x, double y) {
    
    if (x < m_xmin || x >= m_xmax) return false;
    if (y < m_ymin || y >= m_ymax) return false;
    return true;
}
                

bool Tile::setPoint(double x, double y, double z)
{
    //printf("test at %d.%d.%d (%f..%f): %f %f\n", m_west?0:1, m_level, m_which, m_xmin, m_xmax, x, y);

    bool ok = containsPoint(x,y);
    if (!ok) {
        //printf("    nope\n");
        return false;
    }
        
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
        
        //printf("    SET: %d.%d.%d at %d\n", m_west?0:1, m_level, m_which, idx);
        return true;
    }

    // we need use (or make) a child to hold the point
    int c = whichChild(x,y);
    if (m_children == NULL) {
        m_children = new Tile*[4];
        for (int i=0; i<4; i++) {
            m_children[i] = NULL;
        }
    }
    if (m_children[c] == NULL) {
        m_children[c] = new Tile(m_level + 1, this, c, m_west);
        //printf("c=%d, creating\n", c);
    } else {
        //printf("c=%d, existing\n", c);
    }
    
    ok = m_children[c]->setPoint(x,y,z);
    assert(ok);
    return ok;
}


void Tile::dump() {    
    if (m_data != NULL) {
        int cnt = 0;
        for (int idx=0; idx<SIZ*SIZ; idx++) {
            if (m_data[idx] != DBL_MAX) ++cnt;
        }
        
        if (m_level == MAXLEVEL) {
            printf("%d.%d.%d: X=(%f..%f)  Y=(%f..%f)  cnt=%d\n",
                m_west?1:0, m_level, m_which,
                m_xmin, m_xmax, m_ymin, m_ymax,
                cnt);
        }
    }
    
    if (m_children) {
        for (int i=0; i<4; i++) {
            if (m_children[i]) m_children[i]->dump();
        }
    }
}


double Tile::getPoint(int idx) {
    assert(idx >= 0 && idx < SIZ*SIZ);
    return m_data[idx];
}


double Tile::computeCell(int idx) {
    
    double p[4];
    
    // collect the four points
    for (int i=0; i<4; i++) {    
        if (m_children[i]) {
            p[i] = m_children[i]->getPoint(idx);
        } else {
            p[i] = DBL_MAX;
        }
    }
        
    // average the points
    double sum=0.0;
    int cnt = 0;
        
    for (int i=0; i<4; i++) {
        if (p[i] == DBL_MAX) continue;
            
        if (cnt==0) {
            sum = p[i];
        } else {
            sum += p[i];
        }
        ++cnt;
    }
    
    if (cnt == 0) return DBL_MAX;;
     
    double avg = sum / cnt;
    return avg;
}
        
        
void Tile::fillInCells() {
    
    if (m_children == NULL) {
        // do nothing
        return;
    }
            
    for (int i=0; i<4; i++) {
        if (m_children[i])
            m_children[i]->fillInCells();
    }

    // this tile's Ith cell is the avg of the children's Ith cells
    
    for (int idx=0; idx<SIZ*SIZ; idx++) {
        m_data[idx] = computeCell(idx);
    }
    
    return;
}


//////////////////////////////////////////////


TileWriter::TileWriter()
{
    m_root1 = new Tile(0, NULL, 1, true);
    m_root2 = new Tile(0, NULL, 2, false);
}


void TileWriter::goBuffers(const pdal::PointBufferSet& bufs) {
    for (auto pi = bufs.begin(); pi != bufs.end(); ++pi)
    {
        const pdal::PointBufferPtr buf = *pi;
        goBuffer(buf);
    }

    printf("made %d tiles\n", tileCount);
    
    // now fill in the upper levels: use max of children
    m_root1->fillInCells();
    m_root2->fillInCells();
    
    m_root1->dump();
    m_root2->dump();
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
        
        bool ok;
        
        if (x <= 0.0) {
            ok = m_root1->setPoint(x, y, z);
        } else {
            ok = m_root2->setPoint(x, y, z);
        }
        assert(ok);
        
        if (idx % 10000 == 0) {
            printf("%f complete\n", ((double)idx/(double)buf->size()) * 100.0);
        }
    }
}
