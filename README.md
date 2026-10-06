# Fever Field

Fever Field is an interactive, black-and-white generative artwork made with WebGL and GLSL. It combines repeating capsule motifs, a Marjorie Rice-inspired radial pentagon pattern, and rotational wallpaper variations in a continuously moving field.

## Try it

The artwork requires a browser with WebGL support. p5.js is loaded from jsDelivr, so an internet connection is needed when opening the page for the first time.

### Run locally

Use Node.js to serve the `docs/` site over HTTP:

```bash
npm run dev
```

Open <http://localhost:5173>. No package installation is needed.

### Deploy

The deployable static site is in `docs/`. To publish with GitHub Pages, set **Settings → Pages → Build and deployment → Source** to **GitHub Actions**. The workflow deploys `docs/` on pushes to `main`; it can also be run manually from the Actions tab.

## Interact

- **Click or tap the artwork** to advance through all 11 variations. The list wraps back to the beginning:
  1. Capsule: Tight
  2. Capsule: Crossed
  3. Capsule: Weavy
  4. Capsule: Circular
  5. Capsule: Modular
  6. Capsule: Diagonal
  7. Rice-inspired 70° radial pentagon pattern
  8. Wallpaper: 2222
  9. Wallpaper: 333
  10. Wallpaper: 442
  11. Wallpaper: 632
- **Move the pointer** to change orientation and pattern density. Moving quickly briefly disturbs the pattern.
- The field **rotates and breathes continuously**. Press **Space** to pause or resume its time-based motion.
- Press **V** to advance to the next variation, **R** to reset, or **F** to toggle fullscreen.

Transitions between variations crossfade smoothly. The artwork uses black and white throughout.

## How it works

The fragment shader generates the image per pixel. JavaScript handles pointer and keyboard input, eases parameter changes, and passes uniforms to the shader.

- **Capsule variations** repeat rounded capsule shapes in six arrangements.
- **Rice-inspired variation** arranges black-and-white regions in staggered radial rings. It is an artistic interpretation, not a claim of a mathematically exact Marjorie Rice tiling.
- **Wallpaper variations** repeat a slender cane-like glyph using four rotational symmetry configurations: 2222, 333, 442, and 632.

The pointer-driven disturbance is deterministic: it bends the shader coordinates based on animated sine and cosine functions rather than introducing random noise.

## Development

```bash
npm run check
```

This checks JavaScript syntax in the application and development server.

## Project layout

```text
scripts/dev-server.mjs      Local static development server
docs/index.html             Artwork page
docs/style.css              Full-screen presentation
docs/src/main.js            p5.js lifecycle and error reporting
docs/src/interaction.js     Pointer and keyboard input
docs/src/parameters.js      Variation sequence and eased state
docs/src/artwork.js         WebGL uniform updates and rendering
docs/shaders/vertex.glsl    WebGL vertex shader
docs/shaders/fragment.glsl  Generative artwork
.github/workflows/          GitHub Pages deployment
```
