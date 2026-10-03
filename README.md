# Fever Field — first prototype

An interactive, full-screen study in black-and-white periodic waves. This first prototype concentrates on one deliberately small system: a plane wave, continuously sampled between Cartesian and log-polar coordinates.

## Run locally

The shader files must be served over HTTP (opening `index.html` as a `file://` URL will usually be blocked by the browser):

```bash
npm run dev
```
 
Then open <http://localhost:5173>. The dependency-free development server uses Node.js directly, so no install step is necessary. The only browser dependency is p5.js 1.11.10, loaded from jsDelivr, so the first page load requires a network connection.

## Publish on GitHub Pages

The artwork is a static site; `npm run dev` is only a convenience for local development and is not required in production. A GitHub Actions workflow deploys the repository root whenever `main` is updated. In the repository, choose **Settings → Pages → Build and deployment → Source: GitHub Actions** once, then push or merge to `main`. The published project URL will be `https://<username>.github.io/<repository>/`.

The `.nojekyll` marker tells Pages to serve the shader and source directories exactly as committed. All browser asset links are relative, so a project subpath such as `/nightmare/` is supported.

## Interaction

- **Move left/right:** rotate the underlying wave vector.
- **Move up/down:** move from broad, slow bands to dense, intense bands.
- **Click** or press **M:** reorganize smoothly through Cartesian stripes, a concentric tunnel, radial rays, and a spiral.
- **1–4:** select one of those mappings directly.
- **Space:** pause/resume the internal breathing motion.
- **R:** return to the initial state.

There is intentionally no visible interface in this immersive version.

## Mathematical system

The source field is a plane wave

`P(q) = sin(f (cos(a) q.x + sin(a) q.y) + phase)`

where `a` is mouse-controlled orientation and `f` is mouse-controlled spatial frequency. Before the wave is evaluated, the fragment position `(x, y)` can be continuously blended with log-polar coordinates:

- `r = sqrt(x² + y²)`
- `theta = atan(y, x)`
- `q = (log(r + epsilon), theta)`

Sampling mostly along `log(r)` produces nested tunnel rings; sampling mostly along `theta` produces radial rays; combining both produces a logarithmic spiral impression. The Cartesian and transformed coordinates are interpolated rather than switched, so the image visibly reorganizes. A slow sinusoidal change in scale and phase supplies the restrained expansion/contraction.

The equations are evaluated once per pixel in GLSL. JavaScript only smooths interaction values and passes uniforms, keeping rendering suitable for real time.

## Research and artistic context

The project is informed by Heinrich Klüver's descriptions of geometric *form constants* and by later work from Bressloff and collaborators on geometric visual hallucinations, Euclidean symmetry, cortical pattern formation, and retino-cortical mapping. The movement from a simple periodic field to tunnel-, ray-, and spiral-like geometry takes that research as a conceptual point of departure.

This is **a research-informed artistic interpretation, not a scientific model or an explanation of fever dreams**. In particular, the shader's interpolated mapping, breathing, tonal treatment, and association with a personal fever-dream memory are aesthetic decisions. Planar symmetry and the wallpaper-group material from the associated course are intended as a later artistic extension; this prototype does not claim that the hallucination research is based on the 17 wallpaper groups.

## Structure

```text
index.html             page shell and p5.js dependency
package.json           dependency-free npm development commands
style.css              full-viewport presentation
scripts/dev-server.mjs local static development server
src/main.js            p5 lifecycle and application assembly
src/artwork.js         WebGL renderer and uniform updates
src/interaction.js     pointer and keyboard input
src/parameters.js      state, mapping presets, and smoothing
shaders/vertex.glsl    full-canvas vertex shader
shaders/fragment.glsl  wave and coordinate mathematics
```

## Next phases (not implemented)

After validating this prototype, development can add square and hexagonal interference fields, controlled instability, selected 2/3/4/6-fold rotational structures, smooth family morphing, and finally the optional split research view and information overlay. These remain intentionally absent so the base wave and coordinate transformation can be evaluated first.
