const TAU = Math.PI * 2;

export const MAPPING_PRESETS = [
  { name: "stripes", amount: 0, axis: 0.5 },
  { name: "tunnel", amount: 1, axis: 0 },
  { name: "radial", amount: 1, axis: 1 },
  { name: "spiral", amount: 1, axis: 0.42 },
];

const approach = (current, target, responsiveness, deltaSeconds) => {
  const weight = 1 - Math.exp(-responsiveness * deltaSeconds);
  return current + (target - current) * weight;
};

export class Parameters {
  constructor() {
    this.reset();
  }

  reset() {
    this.orientation = this.targetOrientation = 0.12 * TAU;
    this.frequency = this.targetFrequency = 12;
    this.mappingAmount = this.targetMappingAmount = 0;
    this.mappingAxis = this.targetMappingAxis = 0.5;
    this.mappingIndex = 0;
    this.paused = false;
    this.elapsed = 0;
  }

  setPointer(normalX, normalY) {
    this.targetOrientation = normalX * TAU;
    this.targetFrequency = 5 + normalY * 24;
  }

  selectMapping(index) {
    this.mappingIndex = ((index % MAPPING_PRESETS.length) + MAPPING_PRESETS.length) % MAPPING_PRESETS.length;
    const preset = MAPPING_PRESETS[this.mappingIndex];
    this.targetMappingAmount = preset.amount;
    this.targetMappingAxis = preset.axis;
  }

  cycleMapping() {
    this.selectMapping(this.mappingIndex + 1);
  }

  update(deltaSeconds) {
    if (!this.paused) this.elapsed += Math.min(deltaSeconds, 0.05);

    // Exponential easing remains frame-rate independent and lets mappings reorganize visibly.
    this.orientation = approach(this.orientation, this.targetOrientation, 5, deltaSeconds);
    this.frequency = approach(this.frequency, this.targetFrequency, 5, deltaSeconds);
    this.mappingAmount = approach(this.mappingAmount, this.targetMappingAmount, 1.5, deltaSeconds);
    this.mappingAxis = approach(this.mappingAxis, this.targetMappingAxis, 1.35, deltaSeconds);
  }
}
