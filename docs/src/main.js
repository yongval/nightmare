import { Artwork } from "./artwork.js";
import { Interaction } from "./interaction.js";
import { Parameters } from "./parameters.js";

const sketch = (p) => {
  let artwork;
  let interaction;
  let shaderProgram;
  let firstFrame = true;

  p.preload = () => {
    shaderProgram = p.loadShader(
      "shaders/vertex.glsl?v=wallpaper-v3",
      "shaders/fragment.glsl?v=wallpaper-v3",
    );
  };

  p.setup = () => {
    p.setAttributes("antialias", false);
    p.pixelDensity(Math.min(window.devicePixelRatio || 1, 1.5));
    const canvas = p.createCanvas(p.windowWidth, p.windowHeight, p.WEBGL);
    canvas.parent("artwork");

    const parameters = new Parameters();
    artwork = new Artwork(p, shaderProgram, parameters);
    interaction = new Interaction(p, parameters);
  };

  p.draw = () => {
    artwork.render();
    if (firstFrame) {
      document.querySelector("#status").classList.add("ready");
      firstFrame = false;
    }
  };
  p.mouseMoved = () => interaction.pointerMovedAt(p.mouseX, p.mouseY);
  p.mouseDragged = () => interaction.pointerMovedAt(p.mouseX, p.mouseY);
  p.touchMoved = () => interaction.pointerMovedAt(p.mouseX, p.mouseY);
  p.mouseClicked = (event) => interaction.clicked(event);
  p.keyPressed = () => interaction.keyPressed(p.key, p.keyCode);
  p.windowResized = () => p.resizeCanvas(p.windowWidth, p.windowHeight);
};

new window.p5(sketch);
