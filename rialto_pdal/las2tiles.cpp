#include <assert.h>

#include "PdalBridge.hpp"

int main(int argc, char *argv[])
{
    PdalBridge pdal;
    
    pdal.open(argv[1]);
    
    boost::uint64_t numPoints = pdal.getNumPoints();
    printf("num points: %lld\n", numPoints);

#if 0
    std::vector<pdal::Dimension::Id::Enum> dimIds = pdal.getDimIds();
    
    boost::uint32_t numDims = dimIds.size();
    printf("Num dims: %d\n", numDims);

    for (int i=0; i<numDims; i++) {
        pdal::Dimension::Id::Enum id = dimIds[i];
        pdal::Dimension::Type::Enum type = pdal.getDimType(id);
        
        /*double min, mean, max;
        pdal.getStats(id, min, mean, max);*/
        
        printf("Dim %d: %s (%s)\n",
            i,
            pdal::Dimension::name(id).c_str(),
            pdal::Dimension::interpretationName(type).c_str());
        
        /*printf("  (%f,%f,%f)\n",
            min, mean, max);*/
    }
    
    double min, mean, max;
    pdal.getStats((pdal::Dimension::Id::Enum)0, min, mean, max);
    
    const std::string wkt = pdal.getWkt();
    printf("WKT: %s\n", wkt.c_str());
#endif

    pdal.writeTiles();
    
    pdal.close();
    
    return 0;
}


// https://code.google.com/p/maptiler/source/browse/trunk/maptiler/gdal2tiles.py?r=31
class Tiler {
public:
    Tiler(int tileSize) {
        m_tileSize = tileSize;  // 256
        m_MAXZOOMLEVEL = 32;
    }

    void LatLonToPixels(double lat, double lon, int zoom, int& px, int& py) {
        // Converts lat/lon to pixel coordinates in given zoom of the EPSG:4326 pyramid
        double res = 180.0 / m_tileSize / pow(2,zoom);
        px = (180 + lat) / res;
        py = (90 + lon) / res;
    }

    void PixelsToTile(int px, int py, int& tx, int& ty) {
        // Returns coordinates of the tile covering region in pixel coordinates
        tx = int( ceil( px / float(m_tileSize) ) - 1 );
        ty = int( ceil( py / float(m_tileSize) ) - 1 );
    }
    
    void LatLonToTile(double lat, double lon, int zoom, int& tx, int& ty) {
        // Returns the tile for zoom which covers given lat/lon coordinates
        int px, py;
        LatLonToPixels(lat, lon, zoom, px, py);
        PixelsToTile(px,py, tx, ty);
    }
    
    double Resolution(int zoom) {
        // Resolution (arc/pixel) for given zoom level (measured at Equator)
        return 180.0 / m_tileSize / pow(2,zoom);
    }
    
    int ZoomForPixelSize(double pixelSize) {
        // Maximal scaledown zoom of the pyramid closest to the pixelSize.
    
        for (int i=0; i<m_MAXZOOMLEVEL; i++) {
            if (pixelSize > Resolution(i)) {
                if (i!=0) {
                    return i-1;
                } else {
                    return 0; //We don't want to scale up
                }
            }
        }
        assert(false);
    }
    
    void TileBounds(int tx, int ty, int zoom, double& txlo, double& tylo, double& txhi, double& tyhi) {
        // Returns bounds of the given tile
        double res = 180.0 / m_tileSize / pow(2,zoom);
        txlo = tx*m_tileSize*res - 180;
        tylo = ty*m_tileSize*res - 90;
        txhi = (tx+1)*m_tileSize*res - 180;
        tyhi = (ty+1)*m_tileSize*res - 90;
    }
    
    void TileLatLonBounds(int tx, int ty, int zoom, double& tS, double& tW, double& tN, double& tE) {
        // Returns bounds of the given tile in the SWNE form
        TileBounds(tx, ty, zoom, tW, tS, tE, tN);
    }

private:
    int m_tileSize;
    int m_MAXZOOMLEVEL;
};
