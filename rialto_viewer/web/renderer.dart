// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Renderer {
    // public
    double _mouseGeoX = 0.0;
    double _mouseGeoY = 0.0;
    bool _axesVisible;
    bool _bboxVisible;

    Hub _hub;

    // private
    PerspectiveCamera _camera;
    Scene _scene;
    WebGLRenderer _webglRenderer;
    var _cameraControls;
    Projector _projector;
    Element _canvas;
    ParticleSystem _particleSystem;
    Line _myline;
    double _ndcMouseX = 0.0,
            _ndcMouseY = 0.0; // [-1..+1]

    RenderablePointCloudSet _renderSource;

    Vector3 _cameraHomeEyePoint;
    Vector3 _cameraHomeTargetPoint;
    Vector3 _cameraUpVector;
    Vector3 _cameraCurrentEyePoint;
    Vector3 _cameraCurrentTargetPoint;

    AxesObject _axesObject;
    Object3D _bboxObject;

    Matrix4 modelToWorld;

    String _name;

    Renderer(RenderPanel renderPanel, RenderablePointCloudSet rpcSet, String name) {
        _hub = Hub.root;
        _name = name;

        _scene = null;
        _projector = new Projector();

        _webglRenderer = new WebGLRenderer();

        var containerElement = renderPanel.shadowRoot.querySelector("#container");
        assert(containerElement != null);
        containerElement.children.add(_webglRenderer.domElement);

        if (name == "nav") {
            _webglRenderer.setSize(renderPanel.parent.parent.clientWidth, renderPanel.parent.parent.clientHeight);
        } else if (name == "main") {
            _webglRenderer.setSize(window.innerWidth, window.innerHeight);
        } else {
            assert(false);
        }

        _hub.eventRegistry.MouseMove.subscribe(_handleMouseMove);
        _hub.eventRegistry.WindowResize.subscribe0(_handleWindowResize);
        _hub.eventRegistry.DisplayAxes.subscribe(_handleDisplayAxes);
        _hub.eventRegistry.DisplayBbox.subscribe(_handleDisplayBbox);
        _hub.eventRegistry.UpdateCameraEyePosition.subscribe(_handleUpdateCameraEyePosition);
        _hub.eventRegistry.UpdateCameraTargetPosition.subscribe(_handleUpdateCameraTargetPosition);

        _renderSource = rpcSet;

        modelToWorld = new Matrix4.identity();

        _canvas = _webglRenderer.domElement;

        _axesVisible = false;
        _bboxVisible = false;
    }

    Element get canvas => _canvas;


    void _handleUpdateCameraTargetPosition(Vector3 data) {
        if (data == null) data = _cameraHomeTargetPoint;
        data.copyInto(_cameraCurrentTargetPoint);
        _updateCameraModel();
    }

    void _handleUpdateCameraEyePosition(Vector3 data) {
        if (data == null) data = _cameraHomeEyePoint;
        data.copyInto(_cameraCurrentEyePoint);
        _updateCameraModel();
    }

    void _updateCameraModel() {
        _camera.position.setFrom(_cameraCurrentEyePoint);
        _camera.up.setFrom(_cameraUpVector);
        _camera.lookAt(_cameraCurrentTargetPoint);
    }

    int get _canvasWidth {
        return _canvas.clientWidth;
    }
    int get _canvasHeight {
        return _canvas.clientHeight;
    }
    int get _canvasOffsetX {
        return _canvas.documentOffset.x;
    }
    int get _canvasOffsetY {
        return _canvas.documentOffset.y;
    }

    void _addCamera() {
        var w = _canvasWidth;
        var h = _canvasHeight;
        final double aspect = w.toDouble() / h.toDouble();
        _camera = new PerspectiveCamera(50.0, aspect, 0.01, 200000.0);

        _scene.add(_camera);
    }

    void _addCameraControls() {
        _cameraControls = new TrackballControls(_camera, _webglRenderer.domElement);
        _cameraControls.zoomSpeed = 0.25;

        //_cameraControls.rotateSpeed = 1.0;
        //_cameraControls.panSpeed = 0.8;
        //_cameraControls.noZoom = false;
        //_cameraControls.noPan = false;
        //_cameraControls.staticMoving = true;
        //_cameraControls.dynamicDampingFactor = 0.3;
    }

    void update() {

        _scene = new Scene();

        // model space ...(xmin,ymin,zmin)..(xmax,ymax,zmax)...
        // world space ...(0,0)..(xlen,ylen)...
        //
        // min point of the model becomes the origin of world space

        var theMin = _renderSource.min;
        var theLen = _renderSource.len;
        if (_renderSource.length == 0) {
            theMin = new Vector3.zero();
            theLen = new Vector3(100.0, 100.0, 100.0);
        }

        modelToWorld = new Matrix4.identity();
        modelToWorld.translate(-theMin);

        {
            for (var rpc in _renderSource.renderablePointClouds) {
                var obj = rpc.buildParticleSystem();
                obj.visible = rpc.visible;
                obj.applyMatrix(modelToWorld);
                _scene.add(obj);
            }
        }

        {
            // bbox model space is (0,0,0)..(100,100,100)
            _bboxObject = new BboxObject();
            Vector3 a = new Vector3(100.0, 100.0, 100.0);
            Vector3 b = theLen.clone();
            Vector3 c = b.divide(a);
            var bboxModelToWorld = new Matrix4.identity().scale(c);
            _bboxObject.applyMatrix(bboxModelToWorld);
            if (_bboxVisible) {
                _scene.add(_bboxObject);
            }
        }

        {
            // axes model space is (0,0,0)..(100,100,100)
            _axesObject = new AxesObject();
            Vector3 a = new Vector3(100.0, 100.0, 100.0);
            Vector3 b = theLen.clone();
            Vector3 c = b.divide(a).scale(1.0 / 4.0);
            var axesModelToWorld = new Matrix4.identity().scale(c);
            _axesObject.applyMatrix(axesModelToWorld);
            //if (_axesVisible) {
            _scene.add(_axesObject);
            //}
        }


        {
            // camera positions are computed in geo space, but maintained in world space
            _cameraHomeEyePoint = RenderUtils.getCameraPointEye(_renderSource);
            _cameraHomeTargetPoint = RenderUtils.getCameraPointTarget(_renderSource);

            // move position to world space
            _cameraHomeEyePoint.applyProjection(modelToWorld);
            _cameraHomeTargetPoint.applyProjection(modelToWorld);
            _cameraUpVector = new Vector3(0.0, 0.0, 1.0);

            _cameraCurrentEyePoint = _cameraHomeEyePoint;
            _cameraCurrentTargetPoint = _cameraHomeTargetPoint;

            _addCamera();
            _addCameraControls();
            _cameraControls.target = _cameraHomeTargetPoint;

            _updateCameraModel();
        }

    }


    void _handleDisplayAxes(bool v) {
        _axesVisible = v;
        if (_axesVisible) {
            _scene.add(_axesObject);
        } else {
            _scene.remove(_axesObject);
        }
    }

    void _handleDisplayBbox(bool v) {
        _bboxVisible = v;
        if (_bboxVisible) {
            _scene.add(_bboxObject);
        } else {
            _scene.remove(_bboxObject);
        }
    }

    Vector3 fromMouseToNdc(int newX, int newY) {

        // event.client.x,y is from upper left (0,0) of entire browser window

        // x,y is from upper left (0,0) of the canvas
        var x = newX - _canvasOffsetX;
        var y = newY - _canvasOffsetY;

        //print("screen: $x $y");

        // ncdX,Y is from lower left (-1,-1) to upper right (+1,+1) of the canvas
        final double ndcX = (x / _canvasWidth) * 2 - 1;
        final double ndcY = -(y / _canvasHeight) * 2 + 1;

        assert(ndcX > -1.01 && ndcX < 1.01);
        assert(ndcY > -1.01 && ndcY < 1.01);

        var vec = new Vector3(ndcX, ndcY, 0.0);
        return vec;
    }

    Vector3 fromNdcToModel(double ndcX, double ndcY) {
        var vector = new Vector3(ndcX, ndcY, 0.5);

        Ray ray = _projector.pickingRay(vector.clone(), _camera);

        var q = VectorAtZ(ray.origin, ray.direction, 0.0);

        Matrix4 inv = modelToWorld.clone();
        inv.copyInverse(inv);

        var qq = q.clone();
        qq.applyProjection(inv);

        return qq;
    }



    void _handleMouseMove(MouseMoveData data) {
        if (this.canvas != data.canvas) return;

        var ndcVec = fromMouseToNdc(data.newX, data.newY);

        _ndcMouseX = ndcVec.x;
        _ndcMouseY = ndcVec.y;

        //print("ncd: $_ndcMouseX $_ndcMouseY");
    }


    void _handleWindowResize() {
        final w = window.innerWidth;
        final h = window.innerHeight;
        _webglRenderer.setSize(w, h);

        final double aspect = w.toDouble() / h.toDouble();
        _camera.aspect = aspect;

        _camera.lookAt(_scene.position);
    }


    void animate(num time) {
        window.requestAnimationFrame(animate);
        _render();
    }

    var aline;
    void _render() {
        if (_camera == null) return;

        if (_hub.annotator.running) {
            //if (aline != null) _scene.remove(aline);
            aline = _hub.annotator.graphic;
            if (aline != null) _scene.add(aline);
        } else {
            if (_cameraControls != null) {
                _cameraControls.update();
            }
        }

        _updateMouseWorldCoords();

        _webglRenderer.render(_scene, _camera);
    }

    Vector3 VectorAtZ(Vector3 origin, Vector3 direction, double z) {
        var o = origin.clone();
        var d = direction.clone();

        /*if (d.z < 0.001 && d.z > -0.001) {
            if (d.z < 0.0) {
                d.z = -0.001;
            } else {
                d.z = 0.001;
            }
        }*/

        var t = z - o.z;
        /*if (t < 0.001 && t > -0.001) {
            if (t < 0.0) {
                t = -0.001;
            } else {
                t = 0.001;
            }
        }*/

        var k = t / d.z;

        var vec = o + d * k;

        return vec;
    }

    String _p(double v) => v.toStringAsFixed(4);
    String _pp(Vector3 v) => "${_p(v.x)} ${_p(v.y)} ${_p(v.z)}";

    Line _line1, _line2, _line3;
    void _draw1(Vector3 p, Vector3 q) {
        if (_line1 != null) _scene.remove(_line1);
        //p.x += 5.0;
        //q.x += 5.0;
        var gline = new Geometry()
                ..vertices.add(p)
                ..vertices.add(q);

        _line1 = new Line(gline, new LineBasicMaterial(color: 0xff0000));
        _scene.add(_line1);
    }
    void _draw2(Vector3 p, Vector3 q) {
        if (_line2 != null) _scene.remove(_line2);
        //p.x += 15.0;
        //q.x += 15.0;
        var gline = new Geometry()
                ..vertices.add(p)
                ..vertices.add(q);

        _line2 = new Line(gline, new LineBasicMaterial(color: 0x00ff00));
        _scene.add(_line2);
    }
    void _draw3(Vector3 p, Vector3 q) {
        if (_line3 != null) _scene.remove(_line3);
        //p.x += 25.0;
        //q.x += 25.0;
        var gline = new Geometry()
                ..vertices.add(p)
                ..vertices.add(q);

        _line3 = new Line(gline, new LineBasicMaterial(color: 0x0000ff));
        _scene.add(_line3);
    }


    void _updateMouseWorldCoords() {
        {
            double ndcX = _ndcMouseX;
            double ndcY = _ndcMouseY;
            var tmp = new Vector3(ndcX, ndcY, 999.999);

            Ray tmpray = _projector.pickingRay(tmp, _camera);
            MyRay ray = new MyRay(tmpray.origin, tmpray.direction);

            Vector3 mouseWorld = VectorAtZ(ray.origin, ray.direction, 0.0);

            //var originWorld = new Vector3.zero();
            var eyeWorld = _cameraCurrentEyePoint;

            var mydirWorld = mouseWorld - eyeWorld;
            var mydirWorld_norm = mydirWorld.normalized();

            var raydirWorld_norm = ray.direction;

            // print("${_pp(mydirWorld_norm)} | ${_pp(raydirWorld_norm)}");

            //  _draw1(mouseWorld, mouseWorld - mydirWorld_norm * 100.0, 0x0000ff);
            //  _draw2(mouseWorld, raydirWorld_norm - raydirWorld_norm * 100.0, 0xff0000);

            Vector3 r = VectorAtZ(ray.origin, ray.direction, -100.0);
            Vector3 s = VectorAtZ(ray.origin, ray.direction, 0.0);
            Vector3 t = VectorAtZ(ray.origin, ray.direction, 100.0);
            _draw1(r, s);
            _draw2(s, t);
            _draw3(r, t);

            List<Intersect> l = ray.intersectObject(_scene, recursive: true);
            if (l.length > 0) {
                l.forEach((i) => print("${i.object.toString()} - ${i.object.name} - ${i.point}"));
            }
        }

        {
            final Vector3 vModel = fromNdcToModel(_ndcMouseX, _ndcMouseY);
            _mouseGeoX = vModel.x;
            _mouseGeoY = vModel.y;

            _hub.eventRegistry.MouseGeoCoords.fire(new Vector3(_mouseGeoX, _mouseGeoY, this._renderSource.min.z));
        }
    }
}

class MyRay {
    Vector3 origin, direction;
    num near, far;

    final num precision;

    MyRay([this.origin, this.direction, this.near = 0, this.far = double.INFINITY])
            : precision = 0.0001 {

        if (this.origin == null) this.origin = new Vector3.zero();
        if (this.direction == null) this.direction = new Vector3.zero();

    }

    double _distanceFromIntersection(Vector3 origin, Vector3 direction, Vector3 position) {
        Vector3 v0 = position - origin;
        double dot = v0.dot(direction);

        Vector3 intersect = origin + direction.scaled(dot);
        double distance = position.absoluteError(intersect);

        return distance;
    }

    //http://www.blackpawn.com/texts/pointinpoly/default.html
    bool _pointInFace3(Vector3 p, Vector3 a, Vector3 b, Vector3 c) {
        num dot00, dot01, dot02, dot11, dot12, invDenom, u, v;

        Vector3 v0 = c - a;
        Vector3 v1 = b - a;
        Vector3 v2 = p - a;

        dot00 = v0.dot(v0);
        dot01 = v0.dot(v1);
        dot02 = v0.dot(v2);
        dot11 = v1.dot(v1);
        dot12 = v1.dot(v2);

        invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
        u = (dot11 * dot02 - dot01 * dot12) * invDenom;
        v = (dot00 * dot12 - dot01 * dot02) * invDenom;

        return (u >= 0) && (v >= 0) && (u + v < 1);
    }

    List<Intersect> intersectObject(Object3D object, {bool recursive: true}) {
        List<Vector3> abcd = new List.generate(4, (_) => new Vector3.zero());

        Vector3 originCopy = new Vector3.zero();
        Vector3 directionCopy = new Vector3.zero();

        Vector3 vector = new Vector3.zero();
        Vector3 normal = new Vector3.zero();
        Vector3 intersectPoint = new Vector3.zero();

        Intersect intersect;
        List intersects = [];
        int l = object.children.length;

        if (recursive) {
            object.children.forEach((child) {
                intersects.addAll(intersectObject(child));
            });
        }

        if (object is Particle) {
            num distance = _distanceFromIntersection(origin, direction, object.matrixWorld.getTranslation());

            if (distance > object.scale.x) {
                return [];
            }

            intersect = new Intersect(distance: distance, point: object.position, face: null, object: object);


            intersects.add(intersect);

        } else if (object is ParticleSystem) {
            ParticleSystem ps = object;

            var threshold = 1;
            var localThreshold = threshold / ((ps.scale.x + ps.scale.y + ps.scale.z) / 3);

            var distanceToPoint = (Vector3 point) {
                var directionDistance = (point.clone() - origin.clone()).dot(direction);
                // point behind the ray
                if (directionDistance < 0) {
                    return this.origin.distanceTo(point);
                }
                Vector3 ans = (direction.clone() * (directionDistance)) + origin;
                return ans.distanceTo(point);
            };

            var closestPointToPoint = (Vector3 point) {
                var result = new Vector3.zero();
                result = point.clone() - origin;
                var directionDistance = result.dot(direction);
                if (directionDistance < 0) {
                    return origin.clone();
                }
                return (direction.clone() * directionDistance).clone().add(origin);
            };

            var testPoint = (point, index) {
                var rayPointDistance = distanceToPoint(point);
                if (rayPointDistance < localThreshold) {
                    var intersectPoint = closestPointToPoint(point);
                    intersectPoint.applyMatrix4(object.matrixWorld);
                    var distance = origin.distanceTo(intersectPoint);
                    intersects.add(new Intersect(distance: distance, //distanceToRay: rayPointDistance,
                    point: intersectPoint.clone(), //index: index,
                    face: null, object: ps));
                }
            };

            /////////////////////////

            // Checking boundingSphere
            num distance = _distanceFromIntersection(origin, direction, object.matrixWorld.getTranslation());
            Vector3 scale = new Vector3.zero().setValues( //, y_, z_).__v1.setValues(
            object.matrixWorld.getColumn(0).length,
                    object.matrixWorld.getColumn(1).length,
                    object.matrixWorld.getColumn(2).length);

            if (distance > ps.geometry.boundingSphere.radius * Math.max(scale.x, Math.max(scale.y, scale.z))) {
                return intersects;
            }

            ////////////////////////

            if (ps.geometry is BufferGeometry) {
                var attributes = (ps.geometry as BufferGeometry).attributes;
                GeometryAttribute<dynamic> tmp = attributes["position"];

                dynamic ta = tmp.array;
                //assert(ta == null || ta is Float32List || ta is Buffer);
                if (ta == null && tmp.buffer != null) {
                    Buffer b = tmp.buffer;

                } else if (ta is Float32List) {
                    int y = 0;
                } else {
                    int z = 0;
                }
                Float32List positions = tmp.array;

                /*  if ( false /* attributes.index !== undefined */) {
                           var indices = attributes.index.array;
                            var offsets = geometry.offsets;
                            if ( offsets.length === 0 ) {
                                var offset = {
                                    start: 0,
                                    count: indices.length,
                                    index: 0
                                };
                                offsets = [ offset ];
                            }
                            for ( var oi = 0, ol = offsets.length; oi < ol; ++oi ) {
                                var start = offsets[ oi ].start;
                                var count = offsets[ oi ].count;
                                var index = offsets[ oi ].index;
                                for ( var i = start, il = start + count; i < il; i ++ ) {
                                    var a = index + indices[ i ];
                                    position.fromArray( positions, a * 3 );
                                    testPoint( position, a );
                                }
                            }
                        } else*/ {
                    if (positions != null) {
                        var pointCount = positions.length / 3;
                        for (var i = 0; i < pointCount; i++) {
                            var position = new Vector3(positions[3 * i], positions[3 * i + 1], positions[3 * i + 2]);
                            testPoint(position, i);
                        }
                    }
                }
            } else {
                //  not BufferGeometry
                assert(false);
                /*
                        var vertices = this.geometry.vertices;
                        for ( var i = 0; i < vertices.length; i ++ ) {
                            testPoint( vertices[ i ], i );
                        }*/
            }


            ////////////////////////

        } else if (object is Mesh) {
            Mesh mesh = object;
            // Checking boundingSphere
            num distance = _distanceFromIntersection(origin, direction, object.matrixWorld.getTranslation());
            Vector3 scale = new Vector3.zero().setValues( //, y_, z_).__v1.setValues(
            object.matrixWorld.getColumn(0).length,
                    object.matrixWorld.getColumn(1).length,
                    object.matrixWorld.getColumn(2).length);

            if (distance > mesh.geometry.boundingSphere.radius * Math.max(scale.x, Math.max(scale.y, scale.z))) {
                return intersects;
            }

            // Checking faces

            int f;

            Face face;
            num dot, scalar;
            Geometry geometry = mesh.geometry;
            List vertices = geometry.vertices;
            Matrix4 objMatrix;
            Material material;

            List<Material> geometryMaterials = object.geometry.materials;
            bool isFaceMaterial = object.material is MeshFaceMaterial;
            int side = object.material.side;


            extractRotation(object.matrixRotationWorld, object.matrixWorld);

            int fl = geometry.faces.length;

            for (var f = 0; f < fl; f++) {

                face = geometry.faces[f];

                material = isFaceMaterial == true ? geometryMaterials[face.materialIndex] : object.material;
                if (material == null) continue;

                side = material.side;

                originCopy.setFrom(origin);
                directionCopy.setFrom(direction);

                objMatrix = object.matrixWorld;

                // determine if ray intersects the plane of the face
                // note: this works regardless of the direction of the face normal

                vector.setFrom(face.centroid);
                vector.applyProjection(objMatrix).sub(originCopy);
                normal.setFrom(face.normal);
                normal.applyProjection(object.matrixRotationWorld);
                dot = directionCopy.dot(normal);

                // bail if ray and plane are parallel
                if (dot.abs() < 0.0001) continue;

                // calc distance to plane

                scalar = normal.dot(vector) / dot;

                // if negative distance, then plane is behind ray

                if (scalar < 0) continue;

                if (side == DoubleSide || (side == FrontSide ? dot < 0 : dot > 0)) {

                    intersectPoint = originCopy + directionCopy.scale(scalar);

                    abcd = face.indices.map((idx) => vertices[idx].clone().applyProjection(objMatrix)).toList();

                    var pointInFace;

                    // TODO - Make this work a face of arbitrary size
                    if (face.size == 3) {

                        pointInFace = _pointInFace3(intersectPoint, abcd[0], abcd[1], abcd[2]);

                    } else if (face.size == 4) {

                        pointInFace =
                                _pointInFace3(intersectPoint, abcd[0], abcd[1], abcd[3]) || _pointInFace3(intersectPoint, abcd[1], abcd[2], abcd[3]);

                    }

                    if (pointInFace) {
                        intersect = new Intersect(
                                distance: originCopy.absoluteError(intersectPoint),
                                point: intersectPoint.clone(),
                                face: face,
                                object: object);

                        intersects.add(intersect);
                    }
                }
            }
        }

        return intersects;
    }

    List<Intersect> intersectObjects(List<Object3D> objects) {
        int l = objects.length;
        List<Intersect> intersects = [];

        objects.forEach((o) => intersects.addAll(intersectObject(o)));

        intersects.sort((a, b) => a.distance.compareTo(b.distance));

        return intersects;
    }

}

class Intersect {
    num distance;
    Vector3 point;
    Face face;
    Object3D object;

    Intersect({this.distance, this.point, this.face, this.object});
}
