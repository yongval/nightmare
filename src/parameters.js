const TAU = Math.PI * 2;

export const MAPPING_PRESETS = [
  "cartesian",
  "tunnel",
  "radial",
  "spiral",
];

export const PATTERN_FAMILIES = ["rolls", "square / grid", "hexagonal", "rotational symmetry"];
export const SYMMETRY_TYPES = ["2222", "333", "442", "632"];

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
    this.mapping = this.targetMapping = 0;
    this.family = this.targetFamily = 0;
    this.symmetry = this.targetSymmetry = 0;
    this.instability = this.targetInstability = 0.08;
    this.mappingIndex = 0;
    this.familyIndex = 0;
    this.symmetryIndex = 0;
    this.debug = false;
    this.showInformation = false;
    this.paused = false;
    this.elapsed = 0;
  }

  setPointer(normalX, normalY) {
    this.targetOrientation = normalX * TAU;
    this.targetFrequency = 5 + normalY * 24;
  }

  selectMapping(index) {
    this.mappingIndex = ((index % MAPPING_PRESETS.length) + MAPPING_PRESETS.length) % MAPPING_PRESETS.length;
    this.targetMapping = this.mappingIndex;
  }

  cycleMapping() {
    this.selectMapping(this.mappingIndex + 1);
  }

  cycleFamily() {
    this.familyIndex = (this.familyIndex + 1) % PATTERN_FAMILIES.length;
    this.targetFamily = this.familyIndex;
  }

  cycleSymmetry() {
    this.symmetryIndex = (this.symmetryIndex + 1) % SYMMETRY_TYPES.length;
    this.targetSymmetry = this.symmetryIndex;
  }

  disturb(amount) {
    this.targetInstability = Math.min(1, this.targetInstability + amount);
  }

  update(deltaSeconds) {
    if (!this.paused) this.elapsed += Math.min(deltaSeconds, 0.05);

    // Exponential easing remains frame-rate independent and lets mappings reorganize visibly.
    this.orientation = approach(this.orientation, this.targetOrientation, 5, deltaSeconds);
    this.frequency = approach(this.frequency, this.targetFrequency, 5, deltaSeconds);
    this.mapping = approach(this.mapping, this.targetMapping, 1.7, deltaSeconds);
    this.family = approach(this.family, this.targetFamily, 1.45, deltaSeconds);
    this.symmetry = approach(this.symmetry, this.targetSymmetry, 1.4, deltaSeconds);
    this.targetInstability = approach(this.targetInstability, 0.08, 0.75, deltaSeconds);
    this.instability = approach(this.instability, this.targetInstability, 4, deltaSeconds);
  }
}
