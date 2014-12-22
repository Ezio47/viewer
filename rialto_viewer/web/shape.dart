part of rialto.viewer;

typedef void SetUniformsFunc(Renderable);

abstract class Shape {
    static int offscreen = 0;
    static int _ids = 257;

    RenderingContext gl;

    Buffer _vertexBuffer;
    Float32List _vertexArray;
    Buffer _colorBuffer;
    Float32List _colorArray;
    Buffer _idBuffer;
    Float32List _idArray;

    String name;

    int id;

    static Map<int, Shape> shapes = {};

    // to change from model to world coords
    Matrix4 modelMatrix = new Matrix4.identity();

    Shape(RenderingContext this.gl) {
        id = Shape.getNewId();

        shapes[id] = this;

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

        _idBuffer = gl.createBuffer();
        gl.bindBuffer(ARRAY_BUFFER, _idBuffer);
        gl.bufferDataTyped(ARRAY_BUFFER, _idArray, STATIC_DRAW);

        var pcode = Utils.convertIdToFvec(id);
        print("creted ${this.runtimeType}: $id ($pcode)");
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

    }

    void draw(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms) {
         setBindings(vertexAttrib, colorAttrib, setUniforms);
         drawImpl();
     }

    void drawImpl();

    void setBindings(int vertexAttrib, int colorAttrib, SetUniformsFunc setUniforms) {
        gl.bindBuffer(ARRAY_BUFFER, _vertexBuffer);
        gl.vertexAttribPointer(vertexAttrib, 3/*how many floats per point*/, FLOAT, false, 0/*3*4:bytes*/, 0);

        gl.bindBuffer(ARRAY_BUFFER, Shape.offscreen == 1 ? _idBuffer : _colorBuffer);
        gl.vertexAttribPointer(colorAttrib, 4, FLOAT, false, 0/*4*4:bytes*/, 0);

        if (setUniforms != null) setUniforms(this);
    }
}
