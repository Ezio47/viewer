
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

const int MAXLEVEL = 14;
const int SIZ = 64;

static int tileCount = 0;


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
            assert(false);
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


boost::uint16_t Tile::convert(double z) const {
    boost::uint16_t h = 12345;
    return h;
}


void Tile::write(FILE* fp) const {
    for (int y=0; y<SIZ + 1; y++) {
        for (int x=0; x<SIZ + 1; x++) {

            boost::uint16_t height;
            double z;
            
            if (x == SIZ) {
                int idx = y*SIZ + (x-1); // BUG
                z = m_data[idx];
            } else if (y == SIZ) {
                int idx = (y-1)*SIZ + x; // BUG
                z = m_data[idx];
            } else {            
                int idx = y*SIZ + x;
                z = m_data[idx];
            }
            height = convert(z);
            fwrite(&height, 2, 1, fp);
        }
    }
}

    
void Tile::write(const std::string& prefix) const {
    char buf[1024];
    sprintf(buf, "%s/%d.%d.%d.terrain", prefix.c_str(), m_level, m_colNum, m_rowNum);
    assert(strlen(buf) < 1024);
    printf("--> %s\n", buf);
    
    FILE* fp = fopen(buf, "wb");
    write(fp);
    fclose(fp);
    
    if (m_children) {
        for (int i=0; i<4; i++) {
            if (m_children[i]) {
                m_children[i]->write(prefix);
            }
        }
    }
}


//////////////////////////////////////////////


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
