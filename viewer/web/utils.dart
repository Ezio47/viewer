library utils;


//import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart';


class Utils
{
  static GeometryAttribute clone(GeometryAttribute src)
  {
    final int count = src.numItems;

    var dst = new GeometryAttribute.float32(count, 3);

    for (int i=0; i<count; i++)
    {
      dst.array[i] = src.array[i];
    }

    return dst;
  }
}
