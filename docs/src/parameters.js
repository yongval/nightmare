const TAU = Math.PI * 2;

// Orbifold notation for the four orientation-preserving wallpaper groups used here.
export const SYMMETRY_TYPES = ["2222", "333", "442", "632"];
export const CAPSULE_PATTERNS = ["TIGHT", "CROSSED", "WEAVY", "CIRCULAR", "MODULAR", "DIAGONAL"];
export const VARIANTS = [
  ...CAPSULE_PATTERNS.map((pattern, capsulePattern) => ({ form: 0, capsulePattern, label: `CAPSULE · ${pattern}` })),
  { form: 1, label: "RICE 70°" },
  ...SYMMETRY_TYPES.map((symmetry, index) => ({ form: 2, symmetry: index, label: `WALLPAPER · ${symmetry}` })),
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
    this.frequency = this.targetFrequency = 7;
    this.symmetryFrom = this.symmetryTo = 0;
    this.capsulePatternFrom = this.capsulePatternTo = 0;
    this.formFrom = this.formTo = 0;
    this.variantMix = 1;
    this.instability = this.targetInstability = 0.06;
    this.formIndex = 0;
    this.variantIndex = 0;
    this.paused = false;
    this.elapsed = 0;
  }

  setPointer(normalX, normalY) {
    this.targetOrientation = normalX * TAU;
    this.targetFrequency = 2.5 + normalY * 9.5;
  }

  cycleVariant() {
    this.formFrom = this.formIndex;
    this.symmetryFrom = this.symmetryTo;
    this.capsulePatternFrom = this.capsulePatternTo;
    this.variantIndex = (this.variantIndex + 1) % VARIANTS.length;
    const variant = VARIANTS[this.variantIndex];
    this.formIndex = variant.form;
    this.formTo = this.formIndex;
    this.symmetryTo = variant.symmetry ?? this.symmetryTo;
    this.capsulePatternTo = variant.capsulePattern ?? this.capsulePatternTo;
    this.variantMix = 0;
  }

  disturb(amount) {
    this.targetInstability = Math.min(0.55, this.targetInstability + amount);
  }

  update(deltaSeconds) {
    if (!this.paused) this.elapsed += Math.min(deltaSeconds, 0.05);

    this.orientation = approach(this.orientation, this.targetOrientation, 5, deltaSeconds);
    this.frequency = approach(this.frequency, this.targetFrequency, 5, deltaSeconds);
    this.variantMix = Math.min(1, this.variantMix + deltaSeconds / 0.45);
    this.targetInstability = approach(this.targetInstability, 0.06, 0.75, deltaSeconds);
    this.instability = approach(this.instability, this.targetInstability, 4, deltaSeconds);
  }
}
