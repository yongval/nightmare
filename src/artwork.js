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
    this.shaderProgram.setUniform("uMappingAmount", state.mappingAmount);
    this.shaderProgram.setUniform("uMappingAxis", state.mappingAxis);

    // A single clip-space rectangle gives the fragment shader one invocation per pixel.
    p.noStroke();
    p.rect(-p.width / 2, -p.height / 2, p.width, p.height);
  }
}
