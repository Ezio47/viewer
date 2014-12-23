part of rialto.viewer;

typedef void SetUniformsFunc(Renderable);
typedef void PickFunc(int pickedId);

abstract class Shape {
    static int offscreen = 0;
    static int _ids = 257;

    RenderingContext gl;

    Float32List _vertexArray;
    Buffer _vertexBuffer;

    Float32List _colorArray;
    Buffer _colorBuffer;
    Float32List _highlightColorArray;
    Buffer _highlightColorBuffer;

    Buffer _idBuffer;
    Float32List _idArray;
    PickFunc pickFunc;

    String name;
    bool visible;
    bool _highlight;
    int id;

    static Map<int, Shape> shapes = {};

    // to change from model to world coords
    Matrix4 modelMatrix = new Matrix4.identity();

    Shape(RenderingContext this.gl) {
        id = Shape.getNewId();
        visible = true;
        _highlight = false;

        shapes[id] = this;

        pickFunc = defaultPickFunc;
    }

    void init() {
        setArrays();
        assert(_vertexArray != null);
        assert(_colorArray != null);
        assert(_idArray != null);

        _vertexBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _vertexArray, STATIC_DRAW);

        _colorBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _colorArray, STATIC_DRAW);

        _highlightColorBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _highlightColorBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _highlightColorArray, STATIC_DRAW);

        _idBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _idArray, STATIC_DRAW);

        var pcode = Utils.convertIdToFvec(id);
        //print("created ${this.runtimeType}: $id ($pcode)");
    }

    static int getNewId() => _ids++;

    void setArrays();

    // more renderable objects will use this: it sets the entire object to a single ID
    void setDefaultIdArray() {
        var pcode = Utils.convertIdToFvec(id);
        _idArray = new Float32List(_colorArray.length);
        for (int i = 0; i < _idArray.length; i += 4) {
            _idArray[i] = pcode[0];
            _idArray[i + 1] = pcode[1];
            _idArray[i + 2] = pcode[2];
            _idArray[i + 3] = pcode[3];
        }

        _highlightColorArray = new Float32List(_colorArray.length);
        for (int i = 0; i < _highlightColorArray.length; i += 4) {
            _highlightColorArray[i] = 0.0;
            _highlightColorArray[i + 1] = 0.0;
            _highlightColorArray[i + 2] = 1.0;
            _highlightColorArray[i + 3] = 1.0;
        }

    }

    void draw(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms) {
        if (!visible) return;

        setBindings(vertexAttrib, colorAttrib, setUniforms);
        drawImpl();
    }

    void drawImpl();

    void setBindings(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms) {
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.vertexAttribPointer(vertexAttrib, 3/*how many floats per point*/, FLOAT, false, 0/*3*4:bytes*/, 0);

        if (Shape.offscreen == 1) {
            gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
            gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);
        } else  {
            if (_highlight) {
                gl.bindBuffer(ARRAY_BUFFER, _highlightColorBuffer);
                gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);
            }
            else {
                gl.bindBuffer(ARRAY_BUFFER, _colorBuffer);
                gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);
            }
        }

        if (setUniforms != null) setUniforms(this);
    }

    void defaultPickFunc(int pickedId) {
        assert(id == pickedId);
        print("BOOM: $id is ${runtimeType.toString()}");
    }

    bool get highlight => _highlight;

    void set highlight(bool value) {
        if (value == _highlight) return;

        _highlight = value;
    }
}
