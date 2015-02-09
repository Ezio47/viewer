// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class CloudShape extends Shape {
    int numPoints;
    Float64List pointsX;
    Float64List pointsY;
    Float64List pointsZ;
    Uint8List colors;

    CloudShape(Float64List this.pointsX, Float64List this.pointsY, Float64List this.pointsZ, Uint8List this.colors)
            : super("cloud") {
        numPoints = pointsX.length;
        if (!(numPoints * 4 == colors.length)) {
            log(numPoints);
            log(colors.length);
        }
        assert(numPoints * 4 == colors.length);

        isSelectable = true;

        primitive = _createCesiumObject();
    }

    @override
    dynamic _createCesiumObject() {
        return _hub.cesium.createCloud(numPoints, pointsX, pointsY, pointsZ, colors);
    }
}
