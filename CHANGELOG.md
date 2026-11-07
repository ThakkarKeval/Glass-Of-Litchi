## 0.0.1

* Initial release: `LitchiGlass`, `LitchiCard`, `LitchiButton`, and `LitchiTabBar` with
  Figma-parameter-compatible glass effects (light angle, refraction, dispersion, frost, splay).
* Added interactive control suite:
  * `LitchiChip`: Spring-animated glass tag/filter pill with squircle curvature.
  * `LitchiSegmentedControl`: Inline segmented switch with a sliding liquid squircle selection pill.
  * `LitchiTextField`: Dewy translucent text input with glowing specular focus rims.
  * `LitchiDialog`, `showLitchiDialog`, and `showLitchiModalBottomSheet`: Frosted glass modal overlays with blurred scrim and spring transitions.
* Optical, Shader & Visual Enhancements:
  * Procedural micro-surface roughness / film grain noise in GLSL shader and canvas fallback to prevent OLED banding and add authentic sandblasted texture (`noise: 0% to 100%`).
  * Dynamic incident lighting on `LitchiCard`: specular highlights and caustic glints shimmer in real time following cursor movement (desktop/web) and touch-flex physics.
  * GPU Pipeline State Object (PSO) offscreen warmup in `precacheShaders()` to eliminate first-draw compilation hitching.
  * Flavour interpolation via `LitchiFlavour.lerp()`, with `operator ==` and `hashCode` support for smooth glass transitions and animations.
* GPU fragment shader pipeline for optical refraction and chromatic dispersion on Impeller,
  with automatic fallback to Gaussian blur when shaders are unavailable.
* `LitchiScope` for scene-wide lighting, squircle corner smoothing, and `liteMode` to avoid
  redundant per-item backdrop blur passes in scrolling lists.
* Apple/Figma-style continuous squircle corner curvature (`SquirclePath`, `SquircleClipper`).
* Apple-aligned local refraction by default: `shaderRefraction` now defaults to `false` across all
  glass components, ensuring glass strictly refracts whatever is directly beneath itself with
  native hardware Gaussian blur, eliminating cross-card background bleed and scroll ghosting.
* Corrected fragment shader UV mapping to 1:1 fragment-space, eliminating screen-wide center zoom.
* Apple/visionOS Vibrancy Effect (`vibrancy`):
  * Hardware-accelerated color saturation matrix (`createVibrancyMatrix`) composed directly with `BackdropFilter`, boosting background colors so artwork, photos, and starfields pop vibrantly through frosted glass.
* 3 new signature luxury presets:
  * `LitchiFlavour.liquidMercury`: Ultra-reflective liquid chrome/mercury with metallic refraction and crisp specular peaks.
  * `LitchiFlavour.polarIce`: High-dispersion glacial ice crystal with electric cerulean chromatic fringing.
  * `LitchiFlavour.smokedQuartz`: Velvety dark obsidian and bronze glass tailored for OLED dark modes.
