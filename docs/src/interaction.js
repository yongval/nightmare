export class Interaction {
  constructor(p, parameters) {
    this.p = p;
    this.parameters = parameters;
    this.pointerMoved = false;
    this.previousX = null;
    this.previousY = null;
    this.bindControls();
  }

  bindControls() {
    document.querySelector("#controls").addEventListener("click", (event) => {
      const action = event.target.closest("button")?.dataset.action;
      if (!action) return;
      event.stopPropagation();

      if (action === "family") this.parameters.cycleFamily();
      if (action === "mapping") this.parameters.cycleMapping();
      if (action === "symmetry") this.parameters.cycleSymmetry();
      if (action === "research") this.parameters.debug = !this.parameters.debug;
      if (action === "pause") this.parameters.paused = !this.parameters.paused;
    });
  }

  updatePointer(x, y) {
    this.pointerMoved = true;
    const normalX = this.p.constrain(x / this.p.width, 0, 1);
    const normalY = this.p.constrain(y / this.p.height, 0, 1);
    this.parameters.setPointer(normalX, normalY);
    if (this.previousX !== null) {
      const speed = Math.hypot(x - this.previousX, y - this.previousY) / Math.max(this.p.width, this.p.height);
      this.parameters.disturb(Math.min(speed * 2.4, 0.32));
    }
    this.previousX = x;
    this.previousY = y;
  }

  pointerMovedAt(x, y) {
    this.updatePointer(x, y);
    return false;
  }

  clicked(event) {
    if (event?.target?.closest?.("#controls")) return false;
    this.parameters.cycleFamily();
    return false;
  }

  keyPressed(key, keyCode) {
    if (key === " " || keyCode === 32) {
      this.parameters.paused = !this.parameters.paused;
    } else if (key.toLowerCase() === "m") {
      this.parameters.cycleMapping();
    } else if (key.toLowerCase() === "s") {
      this.parameters.cycleSymmetry();
    } else if (key.toLowerCase() === "d") {
      this.parameters.debug = !this.parameters.debug;
    } else if (key.toLowerCase() === "i") {
      this.parameters.showInformation = !this.parameters.showInformation;
    } else if (key.toLowerCase() === "f") {
      this.p.fullscreen(!this.p.fullscreen());
    } else if (key.toLowerCase() === "r") {
      this.parameters.reset();
    } else {
      return true;
    }
    return false;
  }
}
