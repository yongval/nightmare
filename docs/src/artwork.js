export class Artwork {
  constructor(p, shaderProgram, parameters) {
    this.p = p;
    this.shaderProgram = shaderProgram;
    this.parameters = parameters;
    this.information = document.querySelector("#information");
    this.researchLabels = document.querySelector("#research-labels");
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
    this.shaderProgram.setUniform("uMapping", state.mapping);
    this.shaderProgram.setUniform("uFamily", state.family);
    this.shaderProgram.setUniform("uSymmetry", state.symmetry);
    this.shaderProgram.setUniform("uInstability", state.instability);
    this.shaderProgram.setUniform("uDebug", state.debug);

    this.information.classList.toggle("visible", state.showInformation);
    this.researchLabels.classList.toggle("visible", state.debug);
    if (state.showInformation) {
      const familyNames = ["ROLLS", "SQUARE / GRID", "HEXAGONAL", "ROTATIONAL"];
      const mappings = ["CARTESIAN", "TUNNEL", "RADIAL", "SPIRAL"];
      const symmetries = ["2222", "333", "442", "632"];
      this.information.value = [
        `PATTERN  ${familyNames[state.familyIndex]}`,
        `MAPPING  ${mappings[state.mappingIndex]}`,
        `SYMMETRY ${symmetries[state.symmetryIndex]}`,
        `FREQUENCY ${state.frequency.toFixed(1)}`,
        `INSTABILITY ${state.instability.toFixed(2)}`,
      ].join("\n");
    }

    // A single clip-space rectangle gives the fragment shader one invocation per pixel.
    p.noStroke();
    p.rect(-p.width / 2, -p.height / 2, p.width, p.height);
  }
}
