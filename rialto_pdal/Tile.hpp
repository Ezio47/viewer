
#include <pdal/Writer.hpp>
#include <pdal/FileUtils.hpp>
#include <pdal/StageFactory.hpp>

#include <memory>
#include <vector>
#include <string>

#include <zlib.h>

class Tile {
public:
    enum Quadrant {
        QuadrantSW=0, QuadrantSE=1, QuadrantNE=2, QuadrantNW=3,
        QuadrantInvalid=-1
    };

    Tile(int level, int colNum, int rowNum, Tile* parent);
    double m_xmin, m_xmax, m_xmid, m_xres;
    double m_ymin, m_ymax, m_yres, m_ymid;
    
    void setPoint(double x, double y, double z);
    double getPoint(int x, int y);
    
    Quadrant getQuadrant() const { return m_quadrant; }
    
    int getColNum() const { return m_colNum; }
    int getRowNum() const { return m_rowNum; }

    int getNumCols() const { return m_numCols; }
    int getNumRows() const { return m_numRows; }
    
    bool containsPoint(double x, double y);        

    void fillInCells();

    void dump();
    
    void write(const std::string& prefix) const;
    
    static bool exists(const char* path);

    void getMinMax(double& xmin, double& ymin, double& xmax, double& ymax) const;
    
private:
    Quadrant whichChildQuadrant(double x, double y);        
    void setBounds();
    double computeCell(int x, int y);
    void write(gzFile) const;
    boost::uint16_t convert(double z) const;
        
    Tile** m_children;
    double* m_data;
    
    int m_level;
    Quadrant m_quadrant;
    Tile* m_parent;
    int m_id;
    int m_colNum, m_rowNum;
    int m_numCols, m_numRows;
};
