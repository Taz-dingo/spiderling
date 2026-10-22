# Spiderling

A procedural jumping-spider desktop pet for macOS.

Spiderling is an experiment in making a desktop creature feel **alive**, rather than turning an animal model into a cursor follower. It combines a small stateful behavior system, body-intent-first locomotion, procedural gait / IK, and a lightweight native macOS shell that can move the pet across physical displays.

> **Status:** `v0.0.001` — experimental and playable. Core behavior, locomotion, and the tested dual-display traversal work. An ad-hoc-signed macOS app **preview** can now be built, but there is no notarized release.

## Highlights

- **Stateful behavior** — `REST`, `WANDER`, `OBSERVE`, `APPROACH`, `STALK`, and `POUNCE`.
- **The cursor is a stimulus, not a leash** — ordinary mouse movement is usually ignored; nearby repeated activity can attract attention and escalate behavior.
- **Body-intent-first locomotion** — the body owns movement intent while the legs adapt to explain it visually.
- **Procedural gait** — predictive replants, planted-foot locking, future-pose footholds, soft motion constraints, and bounded fixed-length IK.
- **Real desktop traversal** — a small transparent click-through native window follows the spider in global desktop coordinates and can cross display seams.
- **Deterministic verification** — gait, behavior, coordinate mapping, and host geometry have automated regression coverage.
- **Zero-build browser core** — the Three.js experiment remains directly inspectable without a bundler or framework.

## How it works

```text
Desktop stimuli
      ↓
Spider Brain
REST / WANDER / OBSERVE / APPROACH / STALK / POUNCE
      ↓
Motion Controller
heading + desired movement
      ↓
Procedural Gait
stance / swing + predictive footholds
      ↓
Foot locking + IK
      ↓
Three.js renderer
      ↓
macOS WKWebView pet window
```

A key design rule is:

> **Animation owns intent; geometry and lightweight constraints keep the result believable.**

The project deliberately favors perceptual plausibility over a full biomechanical or rigid-body simulation.

## Run it

### Browser experiment

Open `index.html` directly in a browser.

This is useful for inspecting the procedural spider, locomotion, and debug controls. The browser experiment is not identical to the native desktop-pet behavior path.

### macOS desktop pet

Requirements:

- macOS
- Swift toolchain / Xcode Command Line Tools

Run:

```sh
./desktop/run.sh
```

The script compiles the lightweight Swift host to `/tmp/SpiderPet` and launches a transparent, click-through `WKWebView` window.

Quit with `Ctrl-C` in the launching terminal, or choose **Quit Spiderling** from the menu bar spider icon.

### macOS app preview (not an official release)

On a Mac with Xcode Command Line Tools:

```sh
bash desktop/package.sh
open dist/Spiderling.app
```

This creates a self-contained `dist/Spiderling.app` and a `dist/Spiderling-macos-<arch>.zip`. The app embeds the same browser resources and loads them from `Contents/Resources`; it does not need the repository beside it.

The [`macos-package` GitHub Actions workflow](https://github.com/Taz-dingo/spiderling/actions/workflows/package.yml) builds the preview and uploads the ZIP as a workflow artifact for inspection. Each build currently targets the runner's architecture; it is **not** a universal binary.

**Important:** the preview is signed ad hoc for bundle integrity, **not** with an Apple Developer ID and **not notarized**. Gatekeeper may block a downloaded artifact. It is intended for development/testing, not a general-audience installer; do not treat a green CI build as real-desktop visual validation.

## Tests

Install the JavaScript test dependency:

```sh
npm ci
```

Then run the suite with an existing Chrome / Chromium binary:

```sh
CHROMIUM_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" npm test
```

The test suite covers, among other things:

- straight, curved, reversal, stress, and adversarial locomotion routes;
- foot reach, stance sectors, crossing, continuity, and rendered IK error;
- stable airborne turn plans;
- stateful Brain behavior with deterministic seeds;
- desktop coordinate round-trips and pet-window placement;
- native macOS host integration.

Playwright is used only as a browser automation client for tests. The desktop product itself runs in macOS `WKWebView`.

## Multi-display support

The current host keeps simulation coordinates global while rendering the spider inside a fixed-size local native window:

```text
NSScreen topology
  → global desktop/world coordinates
  → spider world pose
  → world-to-Cocoa conversion
  → moving 360×360 pet window
```

Repeated physical `A → B → A → B` traversal has been verified on the current stacked dual-display setup. The implementation no longer relies on one giant transparent WebKit surface spanning the entire desktop.

Other hardware layouts — especially unequal backing scales, three displays, and non-rectangular gaps — still need broader real-world coverage.

## Project structure

```text
app.js                     scene, procedural body, rendering
src/brain.js               behavior state and stimulus interpretation
src/motion.js              body-level movement intent
src/gait.js                stance/swing planning, footholds, motion correction
src/self-test.js           deterministic locomotion evaluator
src/desktop-pet-v2.js      desktop-pet camera + native pose bridge
desktop/SpiderPet.swift    macOS transparent pet-window host
desktop/HostGeometry.swift desktop/world coordinate conversions
tests/                     browser, behavior, geometry, and host regressions
docs/                      architecture, verification, glossary, current state
```

## Current limitations

This is intentionally an early experimental release.

- The native desktop host currently targets **macOS only**.
- The preview `.app` is not Developer ID-signed/notarized; there is no installer, launch-at-login flow, or settings UI yet.
- The visible spider is still the procedural debug/reference model rather than a production art asset.
- Some unusual physical display topologies have not been exercised on real hardware.
- Non-rectangular display arrangements may eventually need topology-aware routing through real shared screen edges.
- Motion and behavior are still evolving; internal APIs should not be considered stable.

## Documentation

- [`docs/current.md`](docs/current.md) — current baseline, priorities, and known open problems.
- [`docs/architecture.md`](docs/architecture.md) — behavior, locomotion, animation, and desktop-host boundaries.
- [`docs/verification.md`](docs/verification.md) — reproducible automated and real-host verification.
- [`docs/glossary.md`](docs/glossary.md) — shared motion / animation terminology.
- [`docs/bionics.md`](docs/bionics.md) — biological references and modeling notes.
- [`progress.md`](progress.md) — historical experiment log; not the current task list.

## Contributing

Issues and pull requests are welcome. For motion or behavior changes, please prefer small causal changes with reproducible evidence over broad parameter sweeps. Automated tests protect geometry and continuity, but visual / perceptual changes should also be checked in the real desktop host.

For the project's coding-agent workflow and repository conventions, see [`AGENTS.md`](AGENTS.md) and [`docs/agent-workflow.md`](docs/agent-workflow.md).
