
#include <pdal/Writer.hpp>
#include <pdal/FileUtils.hpp>
#include <pdal/StageFactory.hpp>

#include <memory>
#include <vector>
#include <string>


class Tile {
public:
    Tile(int level, Tile* parent, int which, bool west);
    double m_xmin, m_xmax, m_xmid, m_xres;
    double m_ymin, m_ymax, m_yres, m_ymid;
    
    bool setPoint(double x, double y, double z);
    double getPoint(int idx);
    
    void fillInCells();

    void dump();
    
private:
    bool containsPoint(double x, double y);        
    int whichChild(double x, double y);        
    void setBounds();
    double computeCell(int idx);
    
    Tile** m_children;
    double* m_data;
    
    int m_level;
    int m_which; // 0=sw, 1=se, 2=ne, 3=nw
    bool m_west;
    Tile* m_parent;
    int m_id;
};


class TileWriter
{
public:
    TileWriter();

    void goBuffers(const pdal::PointBufferSet& bufs);
    void goBuffer(const pdal::PointBufferPtr& buf);
    
    Tile* m_root1;
    Tile* m_root2;
    
private:
    TileWriter& operator=(const TileWriter&); // not implemented
    TileWriter(const TileWriter&); // not implemented
};
