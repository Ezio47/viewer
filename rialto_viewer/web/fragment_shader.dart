part of rialto.viewer;


String fragmentShader = '''
precision mediump float;

uniform vec4 uPickingColor;
uniform int uOffscreen;
  
varying vec4 vColor;

void main(void) {
   //if (uOffscreen==1) {
        //gl_FragColor = uPickingColor;
    //    vec4 rgba = vec4(0.25, 0.50, 0.75, 1.0);
      //  gl_FragColor = uPickingColor;
    //} else {
        gl_FragColor = vColor;
    //}
}
''';

