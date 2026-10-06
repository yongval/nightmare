#ifdef GL_ES
precision highp float;
#endif

uniform vec2 uResolution;
uniform float uTime;
uniform float uOrientation;
uniform float uFrequency;
uniform float uSymmetryFrom;
uniform float uSymmetryTo;
uniform float uSymmetryMix;
uniform float uCapsulePatternFrom;
uniform float uCapsulePatternTo;
uniform float uCapsulePatternMix;
uniform float uFormFrom;
uniform float uFormTo;
uniform float uFormMix;
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

// A slender cane: a long straight shaft with a compact hooked handle.
float seedGlyph(vec2 p) {
  float shaft = segmentDistance(p, vec2(0.0, -0.29), vec2(0.0, 0.115)) - 0.018;
  float handle = min(
    segmentDistance(p, vec2(0.0, 0.115), vec2(-0.013, 0.147)),
    min(
      segmentDistance(p, vec2(-0.013, 0.147), vec2(-0.045, 0.16)),
      min(
        segmentDistance(p, vec2(-0.045, 0.16), vec2(-0.077, 0.147)),
        min(
          segmentDistance(p, vec2(-0.077, 0.147), vec2(-0.09, 0.115)),
          min(
            segmentDistance(p, vec2(-0.09, 0.115), vec2(-0.077, 0.083)),
            segmentDistance(p, vec2(-0.077, 0.083), vec2(-0.045, 0.07))
          )
        )
      )
    )
  ) - 0.018;
  float distanceToGlyph = min(shaft, handle);
  return 1.0 - smoothstep(-0.004, 0.004, distanceToGlyph);
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

float riceTiling(vec2 p) {
  float spacing = 0.64;
  float radius = length(p);
  float theta = atan(p.y, p.x);
  int baseRing = int(floor(radius / spacing));
  float nearest = radius;
  float secondNearest = 1000.0;
  float bestRing = 0.0;
  float bestSector = 0.0;
  float bestCount = 10.0;

  for (int ringOffset = -1; ringOffset <= 1; ringOffset++) {
    int ring = baseRing + ringOffset;
    if (ring < 1) continue;
    float ringValue = float(ring);
    float count = 10.0 * max(1.0, floor(ringValue * 2.0 * PI / 10.0 + 0.5));
    float stepAngle = 2.0 * PI / count;
    float stagger = fract(ringValue * 0.618033989) * stepAngle;
    float sectorBase = floor((theta - stagger) / stepAngle);
    float ringRadius = ringValue * spacing
      + 0.055 * spacing * sin(ringValue * 2.39996323);

    for (int sectorOffset = -1; sectorOffset <= 1; sectorOffset++) {
      float sector = mod(sectorBase + float(sectorOffset), count);
      float angle = stagger + (sector + 0.5) * stepAngle;
      vec2 center = ringRadius * vec2(cos(angle), sin(angle));
      float distanceToCenter = length(p - center);

      if (distanceToCenter < nearest) {
        secondNearest = nearest;
        nearest = distanceToCenter;
        bestRing = ringValue;
        bestSector = sector;
        bestCount = count;
      } else if (distanceToCenter < secondNearest) {
        secondNearest = distanceToCenter;
      }
    }
  }

  float tileClass = mod(bestRing + floor(bestSector * 10.0 / bestCount), 2.0);
  float interior = smoothstep(0.018, 0.055, secondNearest - nearest);
  float whiteTile = 1.0 - tileClass;
  return whiteTile * step(0.055, interior);
}

float roundedCapsule(vec2 p, float halfLength, float radius) {
  vec2 segment = vec2(0.0, max(halfLength - radius, 0.0));
  return length(p - clamp(p, -segment, segment)) - radius;
}

float capsulePattern(vec2 p, float pattern) {
  float mode = floor(pattern + 0.5);
  float distanceToShape;

  if (mode < 0.5) {
    vec2 pitch = vec2(0.72, 0.58);
    vec2 cell = fract(p / pitch + 0.5) - 0.5;
    distanceToShape = roundedCapsule(cell * pitch, 0.27, 0.16);
  } else if (mode < 1.5) {
    vec2 pitch = vec2(0.94, 0.78);
    vec2 cellId = floor(p / pitch + 0.5);
    vec2 cell = fract(p / pitch + 0.5) - 0.5;
    float angle = mix(-PI / 4.0, PI / 4.0, mod(abs(cellId.x + cellId.y), 2.0));
    distanceToShape = roundedCapsule(rotatePoint(cell * pitch, angle), 0.31, 0.14);
  } else if (mode < 2.5) {
    vec2 woven = p;
    woven.x += 0.19 * sin(p.y * 2.7);
    woven.y += 0.12 * sin(woven.x * 2.4);
    vec2 pitch = vec2(0.82, 0.64);
    vec2 cell = fract(woven / pitch + 0.5) - 0.5;
    distanceToShape = roundedCapsule(cell * pitch, 0.29, 0.15);
  } else if (mode < 3.5) {
    float radius = length(p);
    float angle = atan(p.y, p.x);
    float ring = max(floor(radius / 0.78 + 0.5), 1.0);
    float count = max(6.0, floor(2.0 * PI * ring / 0.78 + 0.5));
    float stepAngle = 2.0 * PI / count;
    float sector = floor(angle / stepAngle + 0.5);
    float tileAngle = sector * stepAngle;
    vec2 center = 0.78 * ring * vec2(cos(tileAngle), sin(tileAngle));
    vec2 local = rotatePoint(p - center, -tileAngle);
    distanceToShape = roundedCapsule(local, 0.29, 0.15);
  } else if (mode < 4.5) {
    vec2 pitch = vec2(1.72, 1.5);
    vec2 moduleId = floor(p / pitch + 0.5);
    vec2 module = fract(p / pitch + 0.5) - 0.5;
    vec2 local = abs(module * pitch);
    float horizontal = roundedCapsule(local - vec2(0.42, 0.0), 0.31, 0.14);
    float vertical = roundedCapsule(rotatePoint(local - vec2(0.0, 0.42), PI * 0.5), 0.31, 0.14);
    float center = length(local) - 0.19;
    distanceToShape = min(min(horizontal, vertical), center);
    distanceToShape += 0.015 * mod(abs(moduleId.x + moduleId.y), 2.0);
  } else {
    vec2 rotated = rotatePoint(p, PI / 4.0);
    vec2 pitch = vec2(0.72, 0.82);
    float row = floor(rotated.y / pitch.y);
    float x = rotated.x / pitch.x - 0.5 * mod(row, 2.0);
    vec2 cell = vec2(fract(x + 0.5) - 0.5, fract(rotated.y / pitch.y + 0.5) - 0.5);
    distanceToShape = roundedCapsule(cell * pitch, 0.31, 0.15);
  }

  float shape = 1.0 - smoothstep(-0.008, 0.008, distanceToShape);
  float edge = 1.0 - smoothstep(0.018, 0.032, abs(distanceToShape));
  return max(shape, edge);
}

void main() {
  vec2 p = (2.0 * gl_FragCoord.xy - uResolution.xy) / min(uResolution.x, uResolution.y);
  float angle = uOrientation + 0.18 * uTime + 0.045 * sin(uTime * 0.37);
  mat2 orientation = mat2(
    cos(angle), -sin(angle),
    sin(angle), cos(angle)
  );

  vec2 oriented = orientation * p * (1.0 + 0.035 * sin(uTime * 0.8));
  vec2 glyphPoint = oriented * uFrequency * 0.82;
  glyphPoint += uInstability * 0.035 * vec2(
    sin(glyphPoint.y * 2.0 + uTime * 1.7),
    cos(glyphPoint.x * 2.0 - uTime * 1.3)
  );

  float symmetryMix = smoothstep(0.0, 1.0, uSymmetryMix);
  float wallpaperFrom = smoothstep(0.45, 0.55, wallpaper(glyphPoint, uSymmetryFrom));
  float wallpaperTo = smoothstep(0.45, 0.55, wallpaper(glyphPoint, uSymmetryTo));
  float wallpaperInk = mix(wallpaperFrom, wallpaperTo, symmetryMix);
  float riceInk = riceTiling(oriented * uFrequency * 0.82);
  float capsuleMix = smoothstep(0.0, 1.0, uCapsulePatternMix);
  float capsuleFrom = capsulePattern(oriented * uFrequency * 0.82, uCapsulePatternFrom);
  float capsuleTo = capsulePattern(oriented * uFrequency * 0.82, uCapsulePatternTo);
  float capsuleInk = mix(capsuleFrom, capsuleTo, capsuleMix);
  float styleFrom = wallpaperInk * bandWeight(uFormFrom, 2.0)
    + riceInk * bandWeight(uFormFrom, 1.0)
    + capsuleInk * bandWeight(uFormFrom, 0.0);
  float styleTo = wallpaperInk * bandWeight(uFormTo, 2.0)
    + riceInk * bandWeight(uFormTo, 1.0)
    + capsuleInk * bandWeight(uFormTo, 0.0);
  float ink = mix(styleFrom, styleTo, smoothstep(0.0, 1.0, uFormMix));
  gl_FragColor = vec4(vec3(ink), 1.0);
}
