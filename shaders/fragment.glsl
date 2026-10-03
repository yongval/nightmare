#ifdef GL_ES
precision highp float;
#endif

uniform vec2 uResolution;
uniform float uTime;
uniform float uOrientation;
uniform float uFrequency;
uniform float uMappingAmount;
uniform float uMappingAxis;

const float PI = 3.141592653589793;

void main() {
  // Centered, aspect-correct coordinates keep circles round at every viewport size.
  vec2 position = (2.0 * gl_FragCoord.xy - uResolution.xy) / min(uResolution.x, uResolution.y);
  float radius = length(position);
  float theta = atan(position.y, position.x);

  // Epsilon keeps log(r) finite at the perceptual center.
  vec2 logPolar = vec2(log(radius + 0.018), theta / PI);

  // This artistic normalization gives log-radius and angle comparable visual scale.
  logPolar *= vec2(0.72, 1.35);

  // The axis parameter rotates the log-polar domain: x yields rings, y yields rays,
  // and intermediate directions combine both coordinates into spiral trajectories.
  float mappingAngle = uMappingAxis * PI * 0.5;
  mat2 domainRotation = mat2(
    cos(mappingAngle), -sin(mappingAngle),
    sin(mappingAngle),  cos(mappingAngle)
  );
  vec2 transformed = domainRotation * logPolar;

  // Continuous interpolation exposes the reorganization from plane to log-polar space.
  float easedMapping = smoothstep(0.0, 1.0, uMappingAmount);
  vec2 samplePoint = mix(position, transformed, easedMapping);

  // A plane wave is the sine of the projection onto its oriented wave vector.
  vec2 direction = vec2(cos(uOrientation), sin(uOrientation));

  // Low-amplitude frequency and phase motion creates breathing, not arbitrary noise.
  float breath = 1.0 + 0.055 * sin(uTime * 0.68);
  float phase = uTime * 0.34 + 0.14 * sin(uTime * 0.21);
  float wave = sin(dot(samplePoint, direction) * uFrequency * breath + phase);

  // A small frequency-aware transition keeps edges clean without requiring the
  // optional WebGL 1 standard-derivatives extension (important on older devices).
  float edge = 0.026 + 0.0014 * uFrequency;
  float monochrome = smoothstep(-edge, edge, wave);
  gl_FragColor = vec4(vec3(monochrome), 1.0);
}
