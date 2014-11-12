library render_utils;

import 'dart:core';
import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart';
import 'utils.dart';
import 'point_cloud.dart';


class RenderUtils
{
  static Line drawLine(Vector3 p1, Vector3 p2, int xcolor)
  {
    var material = new LineBasicMaterial(color:xcolor);

    var geometry = new Geometry();
    geometry.vertices.add(p1);
    geometry.vertices.add(p2);

    var line = new Line(geometry, material);

    return line;
  }


  // given the two bounds of a box, draw the three axis lines
  static List<Line> drawAxes(Vector3 lo, Vector3 hi)
  {
    var p0 = lo;
    var px = new Vector3(hi.x, lo.y, lo.z);
    var py = new Vector3(lo.x, hi.y, lo.z);
    var pz = new Vector3(lo.x, lo.y, hi.z);

    var linex = drawLine(p0, px, 0xff0000);

    var liney = drawLine(p0, py, 0x00ff00);

    var linez = drawLine(p0, pz, 0x0000ff);

    List<Line> lines = [linex, liney, linez];

    return lines;
  }


  // given the two bounds of a box, draw the lines of the cube
  static List<Line> drawBbox(Vector3 lo, Vector3 hi)
  {
    var lll = new Vector3(lo.x, lo.y, lo.z);
    var hll = new Vector3(hi.x, lo.y, lo.z);
    var lhl = new Vector3(lo.x, hi.y, lo.z);
    var hhl = new Vector3(hi.x, hi.y, lo.z);
    var llh = new Vector3(lo.x, lo.y, hi.z);
    var hlh = new Vector3(hi.x, lo.y, hi.z);
    var lhh = new Vector3(lo.x, hi.y, hi.z);
    var hhh = new Vector3(hi.x, hi.y, hi.z);

    // X
    var x1 = drawLine(lll, hll, 0xff0000);
    var x2 = drawLine(lhl, hhl, 0xff0000);
    var x3 = drawLine(llh, hlh, 0xff0000);
    var x4 = drawLine(lhh, hhh, 0xff0000);

    // Y
    var y1 = drawLine(lll, lhl, 0x00ff00);
    var y2 = drawLine(hll, hhl, 0x00ff00);
    var y3 = drawLine(llh, lhh, 0x00ff00);
    var y4 = drawLine(hlh, hhh, 0x00ff00);

    // Z
    var z1 = drawLine(lll, llh, 0x0000ff);
    var z2 = drawLine(hll, hlh, 0x0000ff);
    var z3 = drawLine(lhl, lhh, 0x0000ff);
    var z4 = drawLine(hhl, hhh, 0x0000ff);

    List<Line> lines = [x1, x2, x3, x4, y1, y2, y3, y4, z1, z2, z3, z4];
    return lines;
  }

  static ParticleSystem drawPoints(PointCloud cloud)
  {
    var positions = cloud.dims["positions"];
    var colors    = cloud.dims["colors"];
    assert(positions != null);
    assert(colors != null);

    // the underlying system wants to take ownership of these arrays, so we'll
    // pass them copies
    BufferGeometry geometry = new BufferGeometry();
    geometry.attributes = {
       "position" : Utils.clone(positions),
       "color"    : Utils.clone(colors)
    };

    geometry.computeBoundingSphere();
    var material = new ParticleBasicMaterial( size: 1, vertexColors: 2 );

    var particleSystem = new ParticleSystem( geometry, material );

    return particleSystem;
  }
}
