# Fever Field

An interactive, full-screen study in black-and-white periodic waves, interference, log-polar transformation, rotational order, and controlled instability.

## Run locally

The shader files must be served over HTTP (opening `index.html` as a `file://` URL will usually be blocked by the browser):

```bash
npm run dev
```

Then open <http://localhost:5173>. The dependency-free development server uses Node.js directly, so no install step is necessary. The only browser dependency is p5.js 1.11.10, loaded from jsDelivr, so the first page load requires a network connection.

## Publish on GitHub Pages

The artwork is a static site; `npm run dev` is only a convenience for local development and is not required in production. All publishable files live in `docs/`, which supports both GitHub Pages publishing options:

- **Recommended:** choose **Settings → Pages → Build and deployment → Source: GitHub Actions**. The included workflow uploads `docs/` whenever `main` is updated.
- **Branch fallback:** choose **Deploy from a branch**, select `main`, and select `/docs` as the folder.

Do not combine a Jekyll workflow with the `/docs` source. This project does not use Jekyll, Ruby, themes, or an `assets/css/style.scss` build step. The published project URL will be `https://<username>.github.io/<repository>/`.

The `docs/.nojekyll` marker tells Pages to serve the shader and source directories exactly as committed. All browser asset links are relative, so a project subpath such as `/nightmare/` is supported.

## Interaction

- **Move left/right:** rotate the underlying wave vector.
- **Move up/down:** move from broad, slow bands to dense, intense bands.
- **Click the artwork** or use the **PATTERN** button: morph through rolls, square/grid interference, hexagonal interference, and rotational symmetry.
- **SPACE button:** reorganize smoothly through Cartesian stripes, a concentric tunnel, radial rays, and a spiral.
- **ROTATION button:** cycle the rotational structures 2222, 333, 442, and 632.
- **VIEW button:** compare the simple pattern space and transformed perceptual space side by side.
- **MOTION button:** pause or resume automatic movement.

The compact on-screen controls are the primary interface and always show the current state. Optional presentation shortcuts remain available:

- **M / S / D:** cycle space, rotation, or research view.
- **I:** toggle a minimal research information readout.
- **Space:** pause/resume the internal breathing motion.
- **R:** return to the initial state.
- **F:** enter or leave fullscreen.

Fast pointer movement briefly increases deterministic instability; stopping lets the field reorganize and settle.

The controls stay deliberately compact and monochrome so the geometry remains the dominant visual element.

## Mathematical system

The source field is a plane wave

`P(q) = sin(f (cos(a) q.x + sin(a) q.y) + phase)`

where `a` is mouse-controlled orientation and `f` is mouse-controlled spatial frequency. The fragment shader also derives log-polar coordinates:

- `r = sqrt(x² + y²)`
- `theta = atan(y, x)`
- `q = (log(r + epsilon), theta)`

Sampling `log(r)` produces nested tunnel rings; sampling integer multiples of `theta` produces seamless radial rays; combining both produces a spiral impression. The phases from neighboring mapping states are crossfaded rather than switched, so the image visibly reorganizes. Two perpendicular waves create the square family, while three waves separated by 60° create hexagonal interference. Folded angular coordinates emphasize 2-, 3-, 4-, or 6-fold rotational order. A slow sinusoidal change in scale and phase supplies restrained expansion and contraction.

Instability is deterministic rather than random: mouse velocity raises its amplitude, and paired sine/cosine harmonics bend the sampling domain before slowly settling. Mathematical order therefore remains visible even at maximum disturbance.

The equations are evaluated once per pixel in GLSL. JavaScript only smooths interaction values and passes uniforms, keeping rendering suitable for real time.

## Research and artistic context

The project is informed by Heinrich Klüver's descriptions of geometric *form constants* and by later work from Bressloff and collaborators on geometric visual hallucinations, Euclidean symmetry, cortical pattern formation, and retino-cortical mapping. The movement from a simple periodic field to tunnel-, ray-, and spiral-like geometry takes that research as a conceptual point of departure.

This is **a research-informed artistic interpretation, not a scientific model or an explanation of fever dreams**. In particular, the shader's interpolated mapping, breathing, tonal treatment, and association with a personal fever-dream memory are aesthetic decisions. Its selected rotational structures use planar symmetry material from the associated course as an artistic extension; the project does not claim that hallucination research is based on the 17 wallpaper groups or that its shorthand labels implement full wallpaper groups.

## Structure

```text
package.json           dependency-free npm development commands
scripts/dev-server.mjs local static development server
docs/index.html        page shell and p5.js dependency
docs/style.css         full-viewport presentation
docs/src/main.js       p5 lifecycle and application assembly
docs/src/artwork.js    WebGL renderer and uniform updates
docs/src/interaction.js pointer and keyboard input
docs/src/parameters.js state, mapping presets, and smoothing
docs/shaders/*.glsl    full-canvas vertex and fragment shaders
docs/.nojekyll         disable Jekyll processing
```

## Implemented development phases

The second iteration adds square and hexagonal interference fields, controlled pointer-driven instability, selected 2/3/4/6-fold rotational structures, smooth family morphing, a split research view, and an information overlay. The symmetry labels are artistic shorthand for rotational emphasis rather than complete implementations of wallpaper groups.

Potential later work includes more rigorous reflection and glide-reflection constructions, reproducible saved states, accessibility controls for visual intensity, and performance profiling across mobile GPUs.
