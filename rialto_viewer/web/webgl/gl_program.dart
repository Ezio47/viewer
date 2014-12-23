// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class GlProgram {
    Map<String, int> _attributes = new Map<String, int>();
    Map<String, UniformLocation> _uniforms = new Map<String, UniformLocation>();
    Program _program;
    Shader _fragmentShader, _vertexShader;
    RenderingContext gl;

    GlProgram(RenderingContext this.gl, String fragmentCode, String vertexCode, List<String> attributeNames,
            List<String> uniformNames) {

        _fragmentShader = gl.createShader(FRAGMENT_SHADER);
        gl.shaderSource(_fragmentShader, fragmentCode);
        gl.compileShader(_fragmentShader);

        _vertexShader = gl.createShader(VERTEX_SHADER);
        gl.shaderSource(_vertexShader, vertexCode);
        gl.compileShader(_vertexShader);

        _program = gl.createProgram();
        gl.attachShader(_program, _vertexShader);
        gl.attachShader(_program, _fragmentShader);
        gl.linkProgram(_program);

        if (!gl.getProgramParameter(_program, LINK_STATUS)) {
            print("Could not initialise shaders");
            assert(false);
        }

        for (String attrib in attributeNames) {
            int attributeLocation = gl.getAttribLocation(_program, attrib);
            gl.enableVertexAttribArray(attributeLocation);
            _attributes[attrib] = attributeLocation;
        }
        for (String uniform in uniformNames) {
            var uniformLocation = gl.getUniformLocation(_program, uniform);
            _uniforms[uniform] = uniformLocation;
        }

        Hub.root.gl = gl;
    }
}

