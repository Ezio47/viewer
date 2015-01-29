// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

var CesiumBridge = function (element) {
    Cesium.BingMapsApi.defaultKey = "ApI13eFfY6SbmvsWx0DbJ1p5C1CaoR54uFc7Bk_Z9Jimwo1SKwCezqvWCskESZaf";

    var options = {
        timeline: false,
        geocoder: false,
        animation: false,
        sceneMode : Cesium.SceneMode.SCENE3D,
        fullscreenButton: false,
        creditContainer: "creditContainer"
    };


    this.viewer = new Cesium.Viewer(element, options);

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
        //console.log("was " + primitive.show);
        primitive.show = value;
        //console.log("now " + primitive.show);
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
            // BUG: hack fix for now
            this.goHome();
            return;
        }

        var ellipsoid = scene.globe.ellipsoid;

        var eyeCartographic = Cesium.Cartographic.fromDegrees(eyeLon, eyeLat, eyeHeight);
        var targetCartographic = Cesium.Cartographic.fromDegrees(targetLon, targetLat, targetHeight);
        var eyeCartesian = ellipsoid.cartographicToCartesian(eyeCartographic);
        var targetCartesian = ellipsoid.cartographicToCartesian(targetCartographic);

        //console.log("eye cartesian: " + eyeCartesian.x + ", " + eyeCartesian.y + ", " + eyeCartesian.z);
        //console.log("target cartesian: " + targetCartesian.x + ", " + targetCartesian.y + ", " + targetCartesian.z);

        var up = new Cesium.Cartesian3(upX, upY, upZ);

        // BUG: we only support PerspectiveFrustum camera, so seeting FOV is okay
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


    this.createCircle = function(lon, lat, radius, colorR, colorG, colorB) {
        var color = new Cesium.Color(colorR, colorG, colorB, 0.5);
        var scene = this.viewer.scene;
        var primitives = scene.primitives;
        var solidWhite = Cesium.ColorGeometryInstanceAttribute.fromColor(color);

        var circleInstance = new Cesium.GeometryInstance({
                geometry : new Cesium.CircleGeometry({
                center: Cesium.Cartesian3.fromDegrees(lon, lat),
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


    this.createCloud = function(cnt, pointBuffer, colorBuffer) {
        var scene = this.viewer.scene;
        var primitives = scene.primitives;

        var f32 = new Float32Array(pointBuffer, 0, cnt*3);

        var carts = Cesium.Cartesian3.fromDegreesArrayHeights(f32);

        var f64 = new Float64Array(cnt*3);
        for (var i = 0; i<cnt; i++) {
            f64[i*3+0] = carts[i].x;
            f64[i*3+1] = carts[i].y;
            f64[i*3+2] = carts[i].z;
        }

        var u8 = new Uint8Array(colorBuffer, 0, cnt*4);

        var pointInstance = new Cesium.GeometryInstance({
            geometry : new Cesium.PointGeometry({
                positionsTypedArray: f64,
                colorsTypedArray: u8
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


    this.createLabel = function(text, x, y, z) {
       ///// scene.primitives.removeAll();
        var labels = scene.primitives.add(new Cesium.LabelCollection());
        labels.add({
             position : Cesium.Cartesian3.fromDegrees(-75.10, 39.57),
             text     : 'Philadelphia'
        });

        var ellipsoid = this.viewer.scene.globe.ellipsoid;
        var labels = scene.primitives.add(new Cesium.LabelCollection());
        label = labels.add();
        label.fillColor = Cesium.Color.VIOLET;
        label.show = true;
        label.text = "My house!";
        label.position = new Cartesian3(x,y,z);
    }

    this.create64 = function(len, buf) {
        var f32 = new Float32Array(buf);
        var f64 = new Float64Array(len);
        for (var i=0; i<len; i++) {
            //console.log(f32[i]);
            f64[i] = f32[i];
        }
        return f64;
    }
}
