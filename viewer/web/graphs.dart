import 'dart:core';

class Graphs
{
  Map _toJson(List colors, List normals, List points, int numPoints)
  {
    Map m =
      {
      "children": [ {
          "children": [ {
              "attributes": {
                "Color": {
                  "elements": colors,
                  "itemSize": 4, 
                  "type": "ARRAY_BUFFER"
                }, 
                "Normal": {
                  "elements": normals,
                  "itemSize": 3, 
                  "type": "ARRAY_BUFFER"
                }, 
                "Vertex": {
                  "elements": points,
                  "itemSize": 3, 
                  "type": "ARRAY_BUFFER"
                }
              }, 
              "name": "", 
              "primitives": [ {
                  "count": numPoints, 
                  "first": 0, 
                  "mode": "POINTS"
                }
              ]
            }
          ], 
          "name": "cloud.osg"
        }
      ]
    };
  
    return m;
  }

  Map makeCube(double xmin, double ymin, double zmin, double xmax, double ymax, double zmax)
  {
    // x = red
    // y = green
    // z = blue
    
    // X
    /*(xmin, ymin, zmin), (xmax, ymin, zmin)
    (xmin, ymax, zmin), (xmax, ymax, zmin)
    (xmin, ymin, zmax), (xmax, ymin, zmax)
    (xmin, ymax, zmax), (xmax, ymax, zmax)
    
    // Y
    (xmin, ymin, zmin), (xmin, ymax, zmin)
    (xmax, ymin, zmin), (xmax, ymax, zmin)
    (xmin, ymin, zmax), (xmin, ymax, zmax)
    (xmax, ymin, zmax), (xmax, ymax, zmax)
    
    // Z
    (xmin, ymin, zmin), (xmin, ymin, zmax)
    (xmax, ymin, zmin), (xmax, ymin, zmax)
    (xmin, ymax, zmin), (xmin, ymax, zmax)
    (xmax, ymax, zmin), (xmax, ymax, zmax)
    */
  }
 
  Map getModel2()
  {
    var xdim = 5;
    var ydim = 50;
    var zdim = 10;
    
    List colors = [];
    List normals = [];
    List points = [];
    
    for (var x=0; x<xdim; x++)
    {
      for (var y=0; y<ydim; y++)
      {
        for (var z=0; z<zdim; z++)
        {
          colors.addAll([1,1,1,1]);
          normals.addAll([1.0, 1.0, 1.0]);
          points.addAll([x, y, z]);
        }
      }
    }
    
    var numPoints = xdim * ydim * zdim;
    
    Map m = _toJson(colors, normals, points, numPoints); 
    return m;
  }
    
  Map getModel()
  {
    var K = 1000;
    var siz = 20 * K;
    
    List colors = [];
    List normals = [];
    List points = [];
    
    for (var i=0; i<siz; i++)
    {
      colors.addAll([1,1,1,1]);
      normals.addAll([1.0, 1.0, 1.0]);
      var pt = (i / siz) * 10.0;
      points.addAll([pt, pt, pt]);
    }  

    Map m = _toJson(colors, normals, points, siz); 
    return m;
  }
}
