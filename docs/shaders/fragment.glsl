#ifdef GL_ES
precision highp float;
#endif

uniform vec2 uResolution;
uniform float uTime;
uniform float uOrientation;
uniform float uFrequency;
uniform float uSymmetry;
uniform float uInstability;

const float PI = 3.141592653589793;
const float SQRT3 = 1.732050807568877;

float bandWeight(float value, float center) {
  return max(1.0 - abs(value - center), 0.0);
}

float segmentDistance(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h);
}

// An asymmetric two-part glyph is the seed for every wallpaper pattern.
// Rotating the glyph, rather than reflecting it, keeps the four groups chiral.
float seedGlyph(vec2 p) {
  float stem = exp(-105.0 * segmentDistance(p, vec2(0.07, 0.04), vec2(0.31, 0.12)));
  float hook = exp(-125.0 * abs(length(p - vec2(0.29, 0.21)) - 0.055));
  hook *= smoothstep(-0.02, 0.08, p.x - 0.27);
  return max(stem, hook * 0.85);
}

vec2 rotatePoint(vec2 p, float angle) {
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * p;
}

float glyph2(vec2 p) {
  return max(seedGlyph(p), seedGlyph(-p));
}

float glyph3(vec2 p) {
  return max(seedGlyph(p), max(
    seedGlyph(rotatePoint(p, -2.0 * PI / 3.0)),
    seedGlyph(rotatePoint(p, -4.0 * PI / 3.0))
  ));
}

float glyph4(vec2 p) {
  return max(glyph2(p), max(
    seedGlyph(rotatePoint(p, -PI * 0.5)),
    seedGlyph(rotatePoint(p, -PI * 1.5))
  ));
}

float glyph6(vec2 p) {
  return max(glyph3(p), max(
    seedGlyph(rotatePoint(p, -PI / 3.0)),
    max(seedGlyph(rotatePoint(p, -PI)), seedGlyph(rotatePoint(p, -5.0 * PI / 3.0)))
  ));
}

// Nearest square-lattice cell, used by 2222 (p2) and 442 (p4).
vec2 squareCell(vec2 p) {
  return fract(p + 0.5) - 0.5;
}

// Nearest triangular-lattice cell, used by 333 (p3) and 632 (p6).
vec2 triangularCell(vec2 p) {
  vec2 lattice = vec2(p.x - p.y / SQRT3, 2.0 * p.y / SQRT3);
  vec2 cell = floor(lattice + 0.5);
  vec2 center = vec2(cell.x + 0.5 * cell.y, 0.5 * SQRT3 * cell.y);
  return p - center;
}

float wallpaper(vec2 p, float group) {
  vec2 square = squareCell(p);
  vec2 triangular = triangularCell(p);
  float p2 = glyph2(square);
  float p3 = glyph3(triangular);
  float p4 = glyph4(square);
  float p6 = glyph6(triangular);
  return p2 * bandWeight(group, 0.0)
    + p3 * bandWeight(group, 1.0)
    + p4 * bandWeight(group, 2.0)
    + p6 * bandWeight(group, 3.0);
}

void main() {
  vec2 p = (2.0 * gl_FragCoord.xy - uResolution.xy) / min(uResolution.x, uResolution.y);
  mat2 orientation = mat2(
    cos(uOrientation), -sin(uOrientation),
    sin(uOrientation), cos(uOrientation)
  );

  // Mouse frequency controls lattice scale; breathing and harmonic bending keep
  // the repeated construction ordered while allowing bodily instability.
  p = orientation * p * uFrequency * (1.0 + 0.018 * sin(uTime * 0.7));
  p += uInstability * 0.035 * vec2(
    sin(p.y * 2.0 + uTime * 1.7),
    cos(p.x * 2.0 - uTime * 1.3)
  );

  float field = wallpaper(p, uSymmetry);
  float ink = smoothstep(0.18, 0.58, field);
  gl_FragColor = vec4(vec3(ink), 1.0);
}
