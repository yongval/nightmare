# Fever Field

An interactive, full-screen study in repeating glyphs, radial tilings, rotational order, and controlled instability.

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

If Pages is accidentally configured to publish `main` from `/ (root)`, the root `index.html` now redirects to `docs/` instead of letting Jekyll turn this README into the website. A root `.nojekyll` marker also disables that unintended README/Jekyll rendering path.

The `docs/.nojekyll` marker tells Pages to serve the shader and source directories exactly as committed. All browser asset links are relative, so a project subpath such as `/nightmare/` is supported.

### Verify the deployed release

The planar-wallpaper release marks its `<body>` with `data-release="wallpaper-v2"`. If the public page is blank or shows an older version, use **View Source** and search for `wallpaper-v2`. When it is absent, Pages is serving an older artifact: run the **Deploy static artwork to GitHub Pages** workflow from `main`. The workflow verifies the release marker and the artwork entry point. Versioned shader URLs prevent a browser from reusing an earlier shader.

## Interaction

- **Move left/right:** rotate the underlying wave vector.
- **Move up/down:** move from broad, slow bands to dense, intense bands.
- **Click the artwork:** cycle through all six capsule arrangements, the Marjorie Rice-inspired 70° pentagon tiling, and all four wallpaper symmetries, in that order. The sequence returns to the first capsule arrangement after the last wallpaper symmetry. Every variation crossfades smoothly.
- **Motion:** slow rotation and breathing scale animation run continuously across all three styles.

Optional keyboard shortcuts remain available:

- **V:** cycle to the next artwork variation.
- **Space:** pause/resume the animation.
- **R:** return to the initial state.
- **F:** enter or leave fullscreen.

Fast pointer movement briefly increases deterministic instability; stopping lets the field reorganize and settle.

## Mathematical system

The wallpaper style begins with a connected dash-and-arc glyph. It constructs a rotational orbit of that motif, then repeats the orbit on a compatible translation lattice:

- **2222 / p2:** 2-fold glyph on a square translation lattice
- **333 / p3:** 3-fold glyph on a triangular translation lattice
- **442 / p4:** 4-fold glyph on a square translation lattice
- **632 / p6:** 6-fold glyph on a triangular translation lattice

Repeating neighboring cells in the fragment shader makes the field continuous across every tile boundary. The asymmetric seed and rotational copies avoid introducing reflection as a construction operation. The notation describes the orders of rotation centers present in each orientation-preserving wallpaper group; it is no longer used merely as a visual label.

Mouse X rotates the complete plane and mouse Y changes the translation-lattice density. Instability remains deterministic rather than random: mouse velocity briefly raises the amplitude of paired sine/cosine domain bends, then the pattern settles. A slow rotational drift and restrained scale oscillation animate all three styles continuously; press Space to pause or resume them.

The equations are evaluated once per pixel in GLSL. JavaScript only smooths interaction values and passes uniforms, keeping rendering suitable for real time.

## Research and artistic context

The project is informed by Heinrich Klüver's descriptions of geometric *form constants* and by later work from Bressloff and collaborators on geometric visual hallucinations, Euclidean symmetry, cortical pattern formation, and retino-cortical mapping. The emergence of complex visual structure from a small periodic construction takes that research as a conceptual point of departure.

This is **a research-informed artistic interpretation, not a scientific model or an explanation of fever dreams**. In particular, the breathing, instability, glyph design, tonal treatment, and association with a personal fever-dream memory are aesthetic decisions. The wallpaper constructions use planar symmetry material from the associated course as an artistic extension; the project does not claim that hallucination research is based on the 17 wallpaper groups.

## Structure

```text
package.json           dependency-free npm development commands
scripts/dev-server.mjs local static development server
docs/index.html        page shell and p5.js dependency
docs/style.css         full-viewport presentation
docs/src/main.js       p5 lifecycle and application assembly
docs/src/artwork.js    WebGL renderer and uniform updates
docs/src/interaction.js pointer and keyboard input
docs/src/parameters.js symmetry state and interaction smoothing
docs/shaders/*.glsl    full-canvas vertex and fragment shaders
docs/.nojekyll         disable Jekyll processing
```

## Implemented development phases

The default style repeats a fine connected dash-and-hook motif on square and triangular translation lattices. The STYLE control also offers a fixed 10-fold radial pentagon mosaic inspired by the Marjorie Rice 70° reference and six rounded-capsule arrangements: Tight, Crossed, Weavy, Circular, Modular, and Diagonal. The symmetry control cycles the arrangement when Capsule is selected; wrapping from the last option to the first applies immediately without animating backward through the intervening patterns.

Potential later work includes more rigorous reflection and glide-reflection constructions, reproducible saved states, accessibility controls for visual intensity, and performance profiling across mobile GPUs.
