// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class CloudShape extends Shape {
    int numPoints;
    Float32List points;
    Float32List colors;

    CloudShape(Float32List this.points, Float32List this.colors) : super() {
        numPoints = points.length ~/ 3;
        assert(numPoints * 3 == points.length);
        assert(numPoints * 4 == colors.length);

        isSelectable = true;
    }

    @override
    void _createCesiumObject() {
        _hub.cesium.createCloud(numPoints, points, colors);
    }
}
