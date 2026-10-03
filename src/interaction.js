export class Interaction {
  constructor(p, parameters) {
    this.p = p;
    this.parameters = parameters;
    this.pointerMoved = false;
  }

  updatePointer(x, y) {
    this.pointerMoved = true;
    const normalX = this.p.constrain(x / this.p.width, 0, 1);
    const normalY = this.p.constrain(y / this.p.height, 0, 1);
    this.parameters.setPointer(normalX, normalY);
  }

  pointerMovedAt(x, y) {
    this.updatePointer(x, y);
    return false;
  }

  clicked() {
    this.parameters.cycleMapping();
    return false;
  }

  keyPressed(key, keyCode) {
    if (key === " " || keyCode === 32) {
      this.parameters.paused = !this.parameters.paused;
    } else if (key.toLowerCase() === "m") {
      this.parameters.cycleMapping();
    } else if (key.toLowerCase() === "r") {
      this.parameters.reset();
    } else if (/^[1-4]$/.test(key)) {
      this.parameters.selectMapping(Number(key) - 1);
    } else {
      return true;
    }
    return false;
  }
}
