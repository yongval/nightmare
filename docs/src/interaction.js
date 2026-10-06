export class Interaction {
  constructor(p, parameters) {
    this.p = p;
    this.parameters = parameters;
    this.previousX = null;
    this.previousY = null;
  }

  updatePointer(x, y) {
    const normalX = this.p.constrain(x / this.p.width, 0, 1);
    const normalY = this.p.constrain(y / this.p.height, 0, 1);
    this.parameters.setPointer(normalX, normalY);

    if (this.previousX !== null) {
      const speed = Math.hypot(x - this.previousX, y - this.previousY) / Math.max(this.p.width, this.p.height);
      this.parameters.disturb(Math.min(speed * 1.8, 0.2));
    }
    this.previousX = x;
    this.previousY = y;
  }

  pointerMovedAt(x, y) {
    this.updatePointer(x, y);
    return false;
  }

  clicked(event) {
    this.parameters.cycleVariant();
    return false;
  }

  keyPressed(key, keyCode) {
    if (key === " " || keyCode === 32) this.parameters.paused = !this.parameters.paused;
    else if (key.toLowerCase() === "v") this.parameters.cycleVariant();
    else if (key.toLowerCase() === "f") this.p.fullscreen(!this.p.fullscreen());
    else if (key.toLowerCase() === "r") this.parameters.reset();
    else return true;
    return false;
  }
}
