#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 aPosition;
uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

void main() {
  // p5's matrices convert the pixel-sized rectangle into WebGL clip space.
  gl_Position = uProjectionMatrix * uModelViewMatrix * vec4(aPosition, 1.0);
}
