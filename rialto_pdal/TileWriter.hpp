
#include <pdal/Writer.hpp>
#include <pdal/FileUtils.hpp>
#include <pdal/StageFactory.hpp>

#include <memory>
#include <vector>
#include <string>

#include <zlib.h>

class Tile;

class TileWriter
{
public:
    TileWriter();

    void goBuffers(const pdal::PointBufferSet& bufs);
    void goBuffer(const pdal::PointBufferPtr& buf);
    
    Tile* m_root0;
    Tile* m_root1;
    
    void write(const std::string& prefix) const;
    
private:
    TileWriter& operator=(const TileWriter&); // not implemented
    TileWriter(const TileWriter&); // not implemented
};
