library graph;

import 'dart:core';
import "dart:math" as math;


class Graph
{
  bool _isActive;
  Map _points;
  String _name;
  
  Graph(String name)
  {
    _name = name;
    
    switch (_name) {
      case "1":
        _points = _getLineModel();
        break;
      case "2":
        _points = getCubeModel();
        break;
      case "3":
        _points = _getRandomModel();
        break;
      case "4":
        _points = _makeCubeLines();
        break;
      default:
        _points = _makeCubeLines();
        //assert(false);
    }
    
    _isActive = true;
    
    return;
  }

  
  Map get points => _points;
  bool get isActive => _isActive;
  String get name => _name;
 
  static 
  Map _toJsonPoints(List colors, List normals, List points, int numPoints)
  {
    Map normal = 
      {
        "elements": normals,
        "itemSize": 3,
        "type": "ARRAY_BUFFER"
      };
    Map color = {
                 "elements": colors,
                 "itemSize": 4, 
                 "type": "ARRAY_BUFFER"
               };
    Map vertex = {
                  "elements": points,
                  "itemSize": 3, 
                  "type": "ARRAY_BUFFER"
                };
    Map attributes = {
                      "Color": color, 
                      "Normal" : normal, 
                      "Vertex": vertex
                    };
    
    Map primitives = {
                      "count": numPoints, 
                      "first": 0, 
                      "mode": "POINTS"
                    };
    Map child1 = {
                  "attributes": attributes, 
                  "name": "child1", 
                  "primitives": [primitives]
                };
    
    Map m =
      {
      "children": [ {
          "children": [ child1 ], 
          "name": "cloud.osg"
        }
      ],
      "name": "top"
    };
    
    return m;
  }

  
  static 
  Map _toJsonLines(List colors, List normals, List points, int numPoints)
  {
    Map normal = {
                   "elements": normals,
                   "itemSize": 3,
                   "type": "ARRAY_BUFFER"
                 };
    Map color = {
                  "elements": colors,
                  "itemSize": 4, 
                  "type": "ARRAY_BUFFER"
                };
    Map vertex = {
                   "elements": points,
                   "itemSize": 3, 
                   "type": "ARRAY_BUFFER"
                 };
    Map attributes = {
                       "Color": color, 
                       "Normal" : normal, 
                       "Vertex": vertex
                     };
    
    Map primitives = {
                       "count": numPoints, 
                       "first": 0, 
                       "mode": "LINES"
                     };
    Map child1 = {
                   "attributes": attributes, 
                   "name": "", 
                   "primitives": [primitives]
                 };
    
    Map m =
      {
      "children": [ {
          "children": [ child1 ], 
          "name": "cloud.osg"
        }
      ]
    };
  
    return m;
  }

  
  Map _makeCubeLines()
  {
    double xmin = 0.0;
    double xmax = 5.0;
    double ymin = 0.0;
    double ymax = 10.0;
    double zmin = 0.0;
    double zmax = 15.0;
    
    // x = red
    // y = green
    // z = blue
    
    List colors = [];
    List normals = [];
    List points = [];
    
    // X
    points.addAll([xmin, ymin, zmin]);
    points.addAll([xmax, ymin, zmin]);
    points.addAll([xmin, ymax, zmin]);
    points.addAll([xmax, ymax, zmin]);
    points.addAll([xmin, ymin, zmax]);
    points.addAll([xmax, ymin, zmax]);
    points.addAll([xmin, ymax, zmax]);
    points.addAll([xmax, ymax, zmax]);
    
    // Y
    points.addAll([xmin, ymin, zmin]);
    points.addAll([xmin, ymax, zmin]);
    points.addAll([xmax, ymin, zmin]);
    points.addAll([xmax, ymax, zmin]);
    points.addAll([xmin, ymin, zmax]);
    points.addAll([xmin, ymax, zmax]);
    points.addAll([xmax, ymin, zmax]);
    points.addAll([xmax, ymax, zmax]);
    
    // Z
    points.addAll([xmin, ymin, zmin]);
    points.addAll([xmin, ymin, zmax]);
    points.addAll([xmax, ymin, zmin]);
    points.addAll([xmax, ymin, zmax]);
    points.addAll([xmin, ymax, zmin]);
    points.addAll([xmin, ymax, zmax]);
    points.addAll([xmax, ymax, zmin]);
    points.addAll([xmax, ymax, zmax]);
    
    var numPoints = 8*3;
    
    for (var i=0; i<numPoints; i++)
    {
      colors.addAll([1,1,1,1]);
      normals.addAll([1.0, 1.0, 1.0]);
    }
    

    Map m = _toJsonLines(colors, normals, points, numPoints); 
    
    return m;
  }
 
  
  static Map getCubeModel()
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
    
    Map m = _toJsonPoints(colors, normals, points, numPoints); 
    return m;
  }
  
  
  static Map _getRandomModel()
  {
    var xdim = 5;
    var ydim = 20;
    var zdim = 10;
    
    List colors = [];
    List normals = [];
    List points = [];
    
    var random = new math.Random();
    
    var numPoints = 5000;
    
    for (var i=0; i<numPoints; i++)
    {
      colors.addAll([1,1,1,1]);
      normals.addAll([1.0, 1.0, 1.0]);
      var x = random.nextDouble() * xdim;
      var y = random.nextDouble() * ydim;
      var z = random.nextDouble() * zdim;
      points.addAll([x, y, z]);
    }
    
    Map m = _toJsonPoints(colors, normals, points, numPoints); 
    return m;
  }

  
  static Map _getLineModel()
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

    Map m = _toJsonPoints(colors, normals, points, siz); 
    return m;
  }
}
