#ifdef GL_ES
precision highp float;
#endif

uniform vec2 uResolution;
uniform float uTime;
uniform float uOrientation;
uniform float uFrequency;
uniform float uMapping;
uniform float uFamily;
uniform float uSymmetry;
uniform float uInstability;
uniform bool uDebug;

const float PI = 3.141592653589793;

float bandWeight(float value, float center) {
  return max(1.0 - abs(value - center), 0.0);
}

// Each coordinate system produces a phase rather than a drawn shape. Integer
// angular repetitions keep radial and spiral fields continuous around the seam.
float mappedPhase(vec2 p, float angle, float mapping) {
  float r = length(p);
  float theta = atan(p.y, p.x);
  float logRadius = log(r + 0.018);
  float frequency = uFrequency * (1.0 + 0.055 * sin(uTime * 0.68));
  vec2 direction = vec2(cos(angle), sin(angle));

  float cartesian = dot(p, direction) * frequency;
  float tunnel = logRadius * frequency + sin(angle) * 0.45 * sin(theta * 2.0);
  float radial = theta * 8.0 + cos(angle) * logRadius * 1.2;
  float spiral = logRadius * frequency * 0.72 + theta * 5.0 + angle;

  float phase = cartesian * bandWeight(mapping, 0.0)
    + tunnel * bandWeight(mapping, 1.0)
    + radial * bandWeight(mapping, 2.0)
    + spiral * bandWeight(mapping, 3.0);
  return phase;
}

float waveAt(vec2 p, float angle, float mapping) {
  return sin(mappedPhase(p, angle, mapping) + uTime * 0.34);
}

float familyField(vec2 p, float mapping) {
  float a = uOrientation;
  float rolls = waveAt(p, a, mapping);

  // Two perpendicular plane waves interfere to form the square/grid family.
  float square = 0.5 * (waveAt(p, a, mapping) + waveAt(p, a + PI * 0.5, mapping));

  // Three waves separated by 60 degrees produce a hexagonal interference field.
  float hexagonal = (waveAt(p, a, mapping) + waveAt(p, a + PI / 3.0, mapping)
    + waveAt(p, a + 2.0 * PI / 3.0, mapping)) / 3.0;

  // Folding the polar angle into 2/3/4/6 sectors makes rotational order emerge.
  float folds = 2.0 * bandWeight(uSymmetry, 0.0)
    + 3.0 * bandWeight(uSymmetry, 1.0)
    + 4.0 * bandWeight(uSymmetry, 2.0)
    + 6.0 * bandWeight(uSymmetry, 3.0);
  float theta = atan(p.y, p.x);
  float folded = abs(fract(theta / (2.0 * PI) * folds + 0.5) - 0.5) * 2.0;
  float rotational = sin(length(p) * uFrequency * 1.4 - folded * PI * folds + uTime * 0.3);

  return rolls * bandWeight(uFamily, 0.0)
    + square * bandWeight(uFamily, 1.0)
    + hexagonal * bandWeight(uFamily, 2.0)
    + rotational * bandWeight(uFamily, 3.0);
}

void main() {
  vec2 pixel = gl_FragCoord.xy;
  float mapping = uMapping;
  vec2 viewResolution = uResolution;

  // Research mode places the unmapped source beside the transformed result.
  if (uDebug) {
    bool left = pixel.x < uResolution.x * 0.5;
    viewResolution.x *= 0.5;
    pixel.x = mod(pixel.x, viewResolution.x);
    mapping = left ? 0.0 : uMapping;
  }

  vec2 p = (2.0 * pixel - viewResolution) / min(viewResolution.x, viewResolution.y);

  // Instability remains deterministic: harmonics bend the domain without noise.
  float pulse = sin(uTime * 1.7) * uInstability;
  p *= 1.0 + 0.08 * pulse;
  p += uInstability * 0.045 * vec2(
    sin(p.y * 5.0 + uTime * 2.1),
    cos(p.x * 4.0 - uTime * 1.6)
  );

  float field = familyField(p, mapping);
  float edge = 0.035 + 0.0012 * uFrequency + uInstability * 0.025;
  float monochrome = smoothstep(-edge, edge, field);

  if (uDebug && abs(gl_FragCoord.x - uResolution.x * 0.5) < 1.0) monochrome = 0.5;
  gl_FragColor = vec4(vec3(monochrome), 1.0);
}
