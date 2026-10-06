export class Artwork {
  constructor(p, shaderProgram, parameters) {
    this.p = p;
    this.shaderProgram = shaderProgram;
    this.parameters = parameters;
  }

  render() {
    const p = this.p;
    const state = this.parameters;
    state.update(p.deltaTime / 1000);

    p.shader(this.shaderProgram);
    this.shaderProgram.setUniform("uResolution", [p.width, p.height]);
    this.shaderProgram.setUniform("uTime", state.elapsed);
    this.shaderProgram.setUniform("uOrientation", state.orientation);
    this.shaderProgram.setUniform("uFrequency", state.frequency);
    this.shaderProgram.setUniform("uSymmetryFrom", state.symmetryFrom);
    this.shaderProgram.setUniform("uSymmetryTo", state.symmetryTo);
    this.shaderProgram.setUniform("uSymmetryMix", state.variantMix);
    this.shaderProgram.setUniform("uCapsulePatternFrom", state.capsulePatternFrom);
    this.shaderProgram.setUniform("uCapsulePatternTo", state.capsulePatternTo);
    this.shaderProgram.setUniform("uCapsulePatternMix", state.variantMix);
    this.shaderProgram.setUniform("uFormFrom", state.formFrom);
    this.shaderProgram.setUniform("uFormTo", state.formTo);
    this.shaderProgram.setUniform("uFormMix", state.variantMix);
    this.shaderProgram.setUniform("uInstability", state.instability);

    p.noStroke();
    p.rect(-p.width / 2, -p.height / 2, p.width, p.height);
  }
}
