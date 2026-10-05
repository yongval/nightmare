const TAU = Math.PI * 2;

// Orbifold notation for the four orientation-preserving wallpaper groups used here.
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
    this.frequency = this.targetFrequency = 7;
    this.symmetry = this.targetSymmetry = 0;
    this.instability = this.targetInstability = 0.06;
    this.symmetryIndex = 0;
    this.paused = false;
    this.elapsed = 0;
  }

  setPointer(normalX, normalY) {
    this.targetOrientation = normalX * TAU;
    this.targetFrequency = 2.5 + normalY * 9.5;
  }

  cycleSymmetry() {
    this.symmetryIndex = (this.symmetryIndex + 1) % SYMMETRY_TYPES.length;
    this.targetSymmetry = this.symmetryIndex;
  }

  disturb(amount) {
    this.targetInstability = Math.min(0.55, this.targetInstability + amount);
  }

  update(deltaSeconds) {
    if (!this.paused) this.elapsed += Math.min(deltaSeconds, 0.05);

    this.orientation = approach(this.orientation, this.targetOrientation, 5, deltaSeconds);
    this.frequency = approach(this.frequency, this.targetFrequency, 5, deltaSeconds);
    this.symmetry = approach(this.symmetry, this.targetSymmetry, 1.8, deltaSeconds);
    this.targetInstability = approach(this.targetInstability, 0.06, 0.75, deltaSeconds);
    this.instability = approach(this.instability, this.targetInstability, 4, deltaSeconds);
  }
}
