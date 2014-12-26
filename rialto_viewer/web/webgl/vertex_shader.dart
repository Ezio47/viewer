// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

String vertexShader = '''
attribute vec3 aVertexPosition;
attribute vec4 aVertexColor;
attribute vec4 aSelectionColor;
attribute float aSelectionMask;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

varying vec4 vColor;

void main(void) {
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
    if (aSelectionMask == 0.0) {
        vColor = aVertexColor;
    } else {
        vColor = aSelectionColor;
    }
}
''';
