part of rialto.viewer;




class RenderUtils {
    static Line createLine(Vector3 p1, Vector3 p2, int xcolor) {
        var material = new LineBasicMaterial(color: xcolor);

        var geometry = new Geometry();
        geometry.vertices.add(p1);
        geometry.vertices.add(p2);

        var line = new Line(geometry, material);

        return line;
    }

    static Vector3 getCameraPointTarget(RenderablePointCloudSet set) {

        double minx = 0.0;
        double miny = 0.0;
        double minz = 0.0;
        double lenx = 100.0;
        double leny = 100.0;

        if (set.length > 0) {
            minx = set.min.x;
            miny = set.min.y;
            minz = set.min.z;
            lenx = set.len.x;
            leny = set.len.y;
        }

        final double x = minx + lenx / 2.0;
        final double y = miny + leny / 2.0;
        final double z = minz;

        return new Vector3(x, y, z);
    }

    static Vector3 getCameraPointEye(RenderablePointCloudSet set) {

        double lenx = 100.0;
        double leny = 100.0;
        double maxz = 25.0;

        if (set.length > 0) {
            lenx = set.len.x;
            leny = set.len.y;
            maxz = set.max.z;

        }

        var v = getCameraPointTarget(set);

        v.x = v.x - 0.5 * lenx;
        v.y = v.y - 1.25 * leny;
        v.z = maxz * 5.0;

        return v;
    }
}
