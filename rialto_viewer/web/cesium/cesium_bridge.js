// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.


var CesiumBridge = function (element) {
    Cesium.BingMapsApi.defaultKey = "ApI13eFfY6SbmvsWx0DbJ1p5C1CaoR54uFc7Bk_Z9Jimwo1SKwCezqvWCskESZaf";

    var options = {
        creditContainer: "creditContainer"
    };


    this.viewer = new Cesium.CesiumWidget(element, options);

    // 0=3D, 1=2.5D, 2=2D
    this.setViewMode = function(m) {

        var scene = this.viewer.scene;
        var sec = 0.5;

        if (m == 0) {
            scene.morphTo2D(sec);
        } else if (m == 1) {
            scene.morphToColumbusView(sec);
        } else if (m == 2) {
            scene.morphTo3D(sec);
        } else {
            myassert(false, "bad scene mode value");
        }
    }


    // returns a promise<provider>
    this._createTileProvider2Async = function(urlarg, colorizeRamp, colorizeDimension, visible) {
        var deferred = Cesium.when.defer();

        var provider = new PCTileProvider(urlarg, colorizeRamp, colorizeDimension, visible);

        provider.readHeaderAsync().then(function(provider) {
            deferred.resolve(provider);
        }).otherwise(function (error) {
            myerror("Unable to read point cloud header: " + urlarg, error);
        });

        return deferred.promise;
    }

    // returns nothing, but sets the completer<promise>
    this.createTileProviderAsync = function(urlarg, colorizeRamp, colorizeDimension, visible, completer) {

        var thisthis = this;

        this._createTileProvider2Async(urlarg, colorizeRamp, colorizeDimension, visible).then(function(provider) {

            var viewer = thisthis.viewer;
            var scene = viewer.scene;
            var primitives = scene.primitives;

            primitives.add(new Cesium.QuadtreePrimitive({
                tileProvider : provider
            }));

            completer(provider);
            return;

        }).otherwise(function (error) {
            myerror("Unable to create point cloud tile provider", error);
        });
    }

    this.unloadTileProvider = function(provider) {

        var viewer = this.viewer;
        var scene = viewer.scene;
        var primitives = scene.primitives;

        primitives.remove(provider.quadtree);
    }

    this.getDimensionNamesFromProvider = function (provider) {
        var ret = [];

        var dims = provider.header.dimensions;
        for (var i=0; i<dims.length; i++) {
            ret.push(dims[i].name);
        }

        return ret;
    }

    this.getNumPointsFromProvider = function (provider) {
        var n = provider.header.numPoints;
        return n;
    }

    this.getTileBboxFromProvider = function (provider) {
        var b = provider.header.tilebbox;
        return b;
    }

    this.getStatsFromProvider = function (provider, dimName) {
        var dims = provider.header.dimensions;
        for (var i=0; i<dims.length; i++) {
            if (dims[i].name == dimName) {
                var list = [dims[i].min, dims[i].mean, dims[i].max];
                return list;
            }
        }

        return null;
    }

    this.getColorRampNames = function () {
        var keys = Object.keys(colorRamps);
        return keys;
    }

    this.addDataSource = function (dataSource) {
        this.viewer.dataSources.add(dataSource);
    }

    this.removeDataSource = function (dataSource) {
        this.viewer.dataSources.remove(dataSource);
    }

    this.addGeoJson = function(url) {
        var viewer = this.viewer;
        // these are default styling settings, if no simplestyle present
        var ds = Cesium.GeoJsonDataSource.fromUrl(url, {
          stroke: Cesium.Color.WHITE,
          fill: Cesium.Color.WHITE,
          strokeWidth: 1,
          markerSymbol: '*'
        });

        viewer.dataSources.add(ds);

        return ds;
    }

    // taken from HomeButtonView.viewHome
    this.goHome = function() {
        var scene = this.viewer.scene;
        var mode = scene.mode;

        if (Cesium.defined(scene) && mode === Cesium.SceneMode.MORPHING) {
            scene.completeMorph();
        }

        var direction;
        var right;
        var up;

        if (mode === Cesium.SceneMode.SCENE2D) {
            scene.camera.flyToRectangle({
                destination : Cesium.Rectangle.MAX_VALUE,
                duration : 0,
                endTransform : Cesium.Matrix4.IDENTITY
            });
        } else if (mode === Cesium.SceneMode.SCENE3D) {
            var destination = scene.camera.getRectangleCameraCoordinates(Cesium.Camera.DEFAULT_VIEW_RECTANGLE);
            var mag = Cesium.Cartesian3.magnitude(destination);
            mag += mag * Cesium.Camera.DEFAULT_VIEW_FACTOR;
            Cesium.Cartesian3.normalize(destination, destination);
            Cesium.Cartesian3.multiplyByScalar(destination, mag, destination);

            direction = Cesium.Cartesian3.normalize(destination, new Cesium.Cartesian3());
            Cesium.Cartesian3.negate(direction, direction);
            right = Cesium.Cartesian3.cross(direction, Cesium.Cartesian3.UNIT_Z, new Cesium.Cartesian3());
            up = Cesium.Cartesian3.cross(right, direction, new Cesium.Cartesian3());

            scene.camera.flyTo({
                destination : destination,
                direction: direction,
                up : up,
                duration : 0,
                endTransform : Cesium.Matrix4.IDENTITY
            });
        } else if (mode === Cesium.SceneMode.COLUMBUS_VIEW) {
            var maxRadii = scene.globe.ellipsoid.maximumRadius;
            var position = new Cesium.Cartesian3(0.0, -1.0, 1.0);
            position = Cesium.Cartesian3.multiplyByScalar(Cesium.Cartesian3.normalize(position, position), 5.0 * maxRadii, position);
            direction = new Cesium.Cartesian3();
            direction = Cesium.Cartesian3.normalize(Cesium.Cartesian3.subtract(Cesium.Cartesian3.ZERO, position, direction), direction);
            right = Cesium.Cartesian3.cross(direction, Cesium.Cartesian3.UNIT_Z, new Cesium.Cartesian3());
            up = Cesium.Cartesian3.cross(right, direction, new Cesium.Cartesian3());

            scene.camera.flyTo({
                destination : position,
                duration : 0,
                up : up,
                direction : direction,
                endTransform : Cesium.Matrix4.IDENTITY,
                convert : false
            });
        }
    }

    this.isPrimitiveVisible = function(primitive) {
        return primitive.show;
    }

    this.setPrimitiveVisible = function(primitive, value) {
        //mylog("was " + primitive.show);
        primitive.show = value;
        //mylog("now " + primitive.show);
    }

    this.setUpdater = function(f) {
        this.viewer.scene.preRender.addEventListener(f);
    }

    // input: cartographic, height in meters
    this.lookAtCartographic = function(eyeLon, eyeLat, eyeHeight,
                                       targetLon, targetLat, targetHeight,
                                       upX, upY, upZ, fovDegrees) {
        var scene = this.viewer.scene;
        var mode = scene.mode;

        if (Cesium.defined(scene) && mode === Cesium.SceneMode.MORPHING) {
            scene.completeMorph();
        }

        if (mode === Cesium.SceneMode.SCENE2D ||
            mode == Cesium.SceneMode.COLUMBUS_VIEW) {
            // TODO: hack fix for now
            this.goHome();
            return;
        }

        var ellipsoid = scene.globe.ellipsoid;

        var eyeCartographic = Cesium.Cartographic.fromDegrees(eyeLon, eyeLat, eyeHeight);
        var targetCartographic = Cesium.Cartographic.fromDegrees(targetLon, targetLat, targetHeight);
        var eyeCartesian = ellipsoid.cartographicToCartesian(eyeCartographic);
        var targetCartesian = ellipsoid.cartographicToCartesian(targetCartographic);

        //mylog("eye cartesian: " + eyeCartesian.x + ", " + eyeCartesian.y + ", " + eyeCartesian.z);
        //mylog("target cartesian: " + targetCartesian.x + ", " + targetCartesian.y + ", " + targetCartesian.z);

        var up = new Cesium.Cartesian3(upX, upY, upZ);

        // we only support PerspectiveFrustum camera, so seeting FOV is okay
        this.viewer.camera.frustum.fov = Cesium.Math.toRadians(fovDegrees);

        this.viewer.camera.lookAt(eyeCartesian, targetCartesian, up);
    }

    this.onMouseMove = function(f) {
        var handler = new Cesium.ScreenSpaceEventHandler(this.viewer.scene.canvas);
        handler.setInputAction(

            function(event) {
                var windowX = event.endPosition.x;
                var windowY = event.endPosition.y;
                f(windowX,windowY);
            },

            Cesium.ScreenSpaceEventType.MOUSE_MOVE
        );
    }

    this.onMouseDown = function(f) {
        var handler = new Cesium.ScreenSpaceEventHandler(this.viewer.scene.canvas);
        handler.setInputAction(
            function(event) {
                var windowX = event.position.x;
                var windowY = event.position.y;
                f(windowX, windowY, 0);
            },
            Cesium.ScreenSpaceEventType.LEFT_DOWN
        );
        handler.setInputAction(
            function(event) {
                var windowX = event.position.x;
                var windowY = event.position.y;
                f(windowX, windowY, 1);
            },
            Cesium.ScreenSpaceEventType.MIDDLE_DOWN
        );
        handler.setInputAction(
            function(event) {
                var windowX = event.position.x;
                var windowY = event.position.y;
                f(windowX, windowY, 2);
            },
            Cesium.ScreenSpaceEventType.RIGHT_DOWN
        );
    }

    this.onMouseUp = function(f) {
        var handler = new Cesium.ScreenSpaceEventHandler(this.viewer.scene.canvas);
        handler.setInputAction(
            function(event) {
                var windowX = event.position.x;
                var windowY = event.position.y;
                f(windowX, windowY, 0);
            },
            Cesium.ScreenSpaceEventType.LEFT_UP
        );
        handler.setInputAction(
            function(event) {
                var windowX = event.position.x;
                var windowY = event.position.y;
                f(windowX, windowY, 1);
            },
            Cesium.ScreenSpaceEventType.MIDDLE_UP
        );
        handler.setInputAction(
            function(event) {
                var windowX = event.position.x;
                var windowY = event.position.y;
                f(windowX, windowY, 2);
            },
            Cesium.ScreenSpaceEventType.RIGHT_UP
        );
    }

    this.onMouseWheel = function(f) {
        var handler = new Cesium.ScreenSpaceEventHandler(this.viewer.scene.canvas);
        handler.setInputAction(
            function(delta) {
                f(delta);
            },
            Cesium.ScreenSpaceEventType.WHEEL
        );
    }

    this.createRectangle = function(x1, y1, x2, y2, colorR, colorG, colorB) {
        var color = new Cesium.Color(colorR, colorG, colorB, 1.0);
        var scene = this.viewer.scene;
        var primitives = scene.primitives;
        var solidWhite = Cesium.ColorGeometryInstanceAttribute.fromColor(color);

        var rectangle = Cesium.Rectangle.fromDegrees(x1, y1, x2, y2);

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


    this.createCircle = function(centerLon, centerLat, pointLon, pointLat, colorR, colorG, colorB) {
        var center = Cesium.Cartesian3.fromDegrees(centerLon, centerLat);
        var point = Cesium.Cartesian3.fromDegrees(pointLon, pointLat);
        var radius = Cesium.Cartesian3.distance(center, point);

        var color = new Cesium.Color(colorR, colorG, colorB, 0.5);
        var scene = this.viewer.scene;
        var primitives = scene.primitives;
        var solidWhite = Cesium.ColorGeometryInstanceAttribute.fromColor(color);

        var circleInstance = new Cesium.GeometryInstance({
                geometry : new Cesium.CircleGeometry({
                center: center,
                radius: radius
            }),
            attributes : {
                color : solidWhite
            }
        });
        var appearance = new Cesium.PerInstanceColorAppearance({
                    flat : true,
                    translucent : true,
                    renderState : {
                        lineWidth : Math.min(2.0, scene.maximumAliasedLineWidth)
                    }
                });
        var prim = primitives.add(new Cesium.Primitive({
                geometryInstances : [circleInstance],
                appearance : appearance
        }));
        return prim;
    }

    this.removePrimitive = function(prim) {
        var scene = this.viewer.scene;
        var primitives = scene.primitives;
        primitives.remove(prim);
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


    this.createLine = function(x0, y0, z0, x1, y1, z1, colorR, colorG, colorB) {
        var color = new Cesium.Color(colorR, colorG, colorB, 1.0);
        var inst = this._createLineInstance(x0, y0, z0, x1, y1, z1, color);
        var prim = new Cesium.Primitive({
            geometryInstances : [inst],
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
        //prim.show = false;
        return prim;
    }


    // returns triplet of cartographic degrees as doubles
    this.getMouseCoords = function(windowX, windowY) {
        var pt2 = new Cesium.Cartesian2(windowX, windowY);
        var ellipsoid = this.viewer.scene.globe.ellipsoid;
        var cartesian = this.viewer.camera.pickEllipsoid(pt2, ellipsoid);
        if (cartesian) {
            var cartographic = ellipsoid.cartesianToCartographic(cartesian);
            var lon = Cesium.Math.toDegrees(cartographic.longitude);
            var lat = Cesium.Math.toDegrees(cartographic.latitude);
            var h = cartographic.height;
            return [lon, lat, h];
        } else {
            return null;
        }
    }
}
