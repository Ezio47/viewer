// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

var CesiumBridge = function (element) {
    var options = {
        timeline: false,
        geocoder: false,
        animation: false,
        sceneMode : Cesium.SceneMode.COLUMBUS_VIEW
    };
    this.viewer = new Cesium.Viewer(element, options);

    this.setUpdater = function(f) {
        this.viewer.scene.preRender.addEventListener(f);
    }

    this.createRect = function(a,b,c,d) {

        var scene = this.viewer.scene;
        var primitives = scene.primitives;
        var solidWhite = Cesium.ColorGeometryInstanceAttribute.fromColor(Cesium.Color.WHITE);

        var rectangle = Cesium.Rectangle.fromDegrees(a,b,c,d);

        var rectangleInstance = new Cesium.GeometryInstance({
                geometry : new Cesium.RectangleOutlineGeometry({
                rectangle : rectangle
            }),
            attributes : {
                color : solidWhite
            }
        });
        var appearance = new Cesium.PerInstanceColorAppearance({
                    flat : true,
                    translucent : false,
                    renderState : {
                        lineWidth : Math.min(2.0, scene.maximumAliasedLineWidth)
                    }
                });
        var prim = primitives.add(new Cesium.Primitive({
                geometryInstances : [rectangleInstance],
                appearance : appearance
        }));
        return prim;
    }

    this.removePrimitive = function(prim) {
        var scene = this.viewer.scene;
        var primitives = scene.primitives;
        primitives.remove(prim);
    }

    this.createCloud = function(cnt, ps, cs) {

        var scene = this.viewer.scene;
        var primitives = scene.primitives;

        for (var i = 0; i<cnt; i++) {
            var x = ps[i*3+0];
            var y = ps[i*3+1];
            var z = ps[i*3+2];
            var p = Cesium.Cartesian3.fromDegrees(x,y,z);
            ps[i*3+0] = p.x;
            ps[i*3+1] = p.y;
            ps[i*3+2] = p.z;
        }

        var pointInstance = new Cesium.GeometryInstance({
            geometry : new Cesium.PointGeometry({
                positionsTypedArray: ps,
                colorsTypedArray: cs
            }),
            id : 'point'
        });

        var prim = new Cesium.Primitive({
            geometryInstances : [pointInstance],
            appearance : new Cesium.PointAppearance()
        });
        primitives.add(prim);

        return prim;
    }

    this._createLineInstance = function(x0, y0, z0, x1, y1, z1, color) {
      var p1 = Cesium.Cartesian3.fromDegrees(x0, y0, z0);
      var p2 = Cesium.Cartesian3.fromDegrees(x1, y1, z1);
      var vertices = [p1, p2];
      var geom = new Cesium.PolylineGeometry({
            positions : vertices,
            width : 1.0,
            vertexFormat : Cesium.PolylineColorAppearance.VERTEX_FORMAT,
            followSurface: true
        });

        var instance = new Cesium.GeometryInstance({
            geometry : geom,
            attributes: {
                color: Cesium.ColorGeometryInstanceAttribute.fromColor(color)
            }
        });

        return instance;
    }

    this.createAxes = function(x0, y0, z0, xlen, ylen, zlen) {
        var red = this._createLineInstance(x0, y0, z0, x0 + xlen, y0, z0, Cesium.Color.RED);
        var green = this._createLineInstance(x0, y0, z0, x0, y0 + ylen, z0, Cesium.Color.GREEN);
        var blue = this._createLineInstance(x0, y0, z0, x0, y0, z0 + zlen, Cesium.Color.BLUE);

        var prim = new Cesium.Primitive({
            geometryInstances : [red, green, blue],
            appearance : new Cesium.PolylineColorAppearance()
        });

        this.viewer.scene.primitives.add(prim);
        return prim;
    }

    this.createBbox = function(x0, y0, z0, x1, y1, z1) {

        var red1 = this._createLineInstance(x0, y0, z0, x1, y0, z0, Cesium.Color.RED);
        var red2 = this._createLineInstance(x0, y1, z0, x1, y1, z0, Cesium.Color.RED);
        var red3 = this._createLineInstance(x0, y0, z1, x1, y0, z1, Cesium.Color.RED);
        var red4 = this._createLineInstance(x0, y1, z1, x1, y1, z1, Cesium.Color.RED);

        var green1 = this._createLineInstance(x0, y0, z0, x0, y1, z0, Cesium.Color.GREEN);
        var green2 = this._createLineInstance(x1, y0, z0, x1, y1, z0, Cesium.Color.GREEN);
        var green3 = this._createLineInstance(x0, y0, z1, x0, y1, z1, Cesium.Color.GREEN);
        var green4 = this._createLineInstance(x1, y0, z1, x1, y1, z1, Cesium.Color.GREEN);

        var blue1 = this._createLineInstance(x0, y0, z0, x0, y0, z1, Cesium.Color.BLUE);
        var blue2 = this._createLineInstance(x1, y0, z0, x1, y0, z1, Cesium.Color.BLUE);
        var blue3 = this._createLineInstance(x0, y1, z0, x0, y1, z1, Cesium.Color.BLUE);
        var blue4 = this._createLineInstance(x1, y1, z0, x1, y1, z1, Cesium.Color.BLUE);

        var prim = new Cesium.Primitive({
            geometryInstances : [red1, red2, red3, red4,
                                 green1, green2, green3, green4,
                                 blue1, blue2, blue3, blue4],
            appearance : new Cesium.PolylineColorAppearance()
        });
        this.viewer.scene.primitives.add(prim);
        return prim;
    }

    this.getCurrentPoint = function() {
    }
}
