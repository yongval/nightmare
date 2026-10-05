import { SYMMETRY_TYPES } from "./parameters.js";

export class Artwork {
  constructor(p, shaderProgram, parameters) {
    this.p = p;
    this.shaderProgram = shaderProgram;
    this.parameters = parameters;
    this.symmetryValue = document.querySelector('[data-action="symmetry"] strong');
    this.pauseControl = document.querySelector('[data-action="pause"]');
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
    this.shaderProgram.setUniform("uSymmetry", state.symmetry);
    this.shaderProgram.setUniform("uInstability", state.instability);

    this.symmetryValue.textContent = SYMMETRY_TYPES[state.symmetryIndex];
    this.pauseControl.querySelector("strong").textContent = state.paused ? "PAUSED" : "PLAYING";
    this.pauseControl.setAttribute("aria-pressed", state.paused);

    p.noStroke();
    p.rect(-p.width / 2, -p.height / 2, p.width, p.height);
  }
}
