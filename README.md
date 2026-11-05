# 🍹 Glass of Litchi (`glass_of_litchi`)

A dewy, organic glassmorphism and liquid glass UI kit for Flutter.

Instead of sterile, cold blur wrappers or hyper-complex shader configuration manuals, **Glass of Litchi** delivers **artisanal, fruit-toned glass aesthetics** with opinionated, gorgeous defaults and zero setup.

---

## ✨ Features

* **Organic Fruit Flavours:** Pre-configured aesthetic presets (`dewy`, `juicy`, `frosted`, `crystal`, `milkyLitchi`, `roseTint`, `goldenCitrus`).
* **Tactile Specular Highlights:** Multi-stop rim lighting gradients and ambient overhead specular sheen.
* **Drop-in Component Suite:** Ready-to-use [`LitchiCard`](class://glass_of_litchi#LitchiCard) and [`LitchiButton`](class://glass_of_litchi#LitchiButton) with spring-driven interactive physics and ambient tinted drop shadows.
* **High-FPS Fallback Strategy:** Automatic smooth rendering fallback when blur is disabled or on low-end hardware.
* **100% Universal Flutter:** Works out of the box on Android, iOS, Web, macOS, Windows, and Linux.

---

## 🚀 Getting Started

Add `glass_of_litchi` to your `pubspec.yaml`:

```yaml
dependencies:
  glass_of_litchi: ^0.0.1
```

Import the package:

```dart
import 'package:glass_of_litchi/glass_of_litchi.dart';
```

---

## 🎨 Quick Usage

### 1. Ready-to-use Glass Card (with Dual-Edge Angle)
```dart
LitchiCard(
  flavour: LitchiFlavour.juicy,
  // 135° = Classic top-left to bottom-right dual-rim reflection
  lightAngle: 135.0, 
  onTap: () => print('Juicy glass tapped!'),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text('Lychee Spritz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('Dewy, tactile, and translucent.'),
    ],
  ),
)
```

### 2. Copy Directly from Figma Glass (1:1 Match)
Match all standard Figma Glass effect options and Apple squircle continuous curvature directly:
```dart
LitchiCard.fromFigma(
  lightAngle: 135.0,        // 0° to 360° (direction of key light)
  lightPercent: 85.0,       // 0% to 100% (specular peak brightness)
  refraction: 25.0,         // 0% to 100% (inner optical bevel bending)
  depth: 10.0,              // 0 to 50 px (3D slab thickness & drop shadow)
  dispersion: 35.0,         // 0% to 100% (chromatic rainbow rim fringing)
  frost: 26.0,              // 0% to 100% (matte blur roughness)
  splay: 50.0,              // 0% to 100% (specular highlight arc spread)
  cornerSmoothing: 0.6,     // 0.0 to 1.0 (Apple G2 continuous squircle)
  child: const Text('Exact Figma Clone'),
)
```

### 3. High-Performance 1-Pass Batching with `LitchiScope`
Eliminate the multi-`BackdropFilter` GPU bottleneck in scrolling feeds:
```dart
LitchiScope(
  batchBlur: true,           // Single coordinated pass — 120 FPS in scroll views
  cornerSmoothing: 0.6,      // Unified Apple continuous curvature
  lightAngle: 135.0,         // Unified scene lighting
  child: ListView(
    children: [
      LitchiCard(...),
      LitchiCard(...),
    ],
  ),
)
```

### 4. Tactile Glass Button
```dart
LitchiButton.fromFigma(
  lightAngle: 135.0,
  lightPercent: 90.0,
  cornerSmoothing: 0.6,
  onPressed: () {},
  child: const Text('Refresh'),
)
```

### 5. Core Primitive
```dart
LitchiGlass.fromFigma(
  lightAngle: 135.0,
  frost: 25.0,
  dispersion: 20.0,
  cornerSmoothing: 0.6,
  child: const Text('Custom Container'),
)
```

---

## 🍓 Preset Flavours

| Flavour | Characteristics | Typical Use Case |
| :--- | :--- | :--- |
| `dewy` | Crisp, high translucency, subtle white sheen | Floating action bars, navbar headers |
| `juicy` | Succulent lychee tint with soft pink ambient warmth | Highlighted cards, hero CTAs, banners |
| `frosted` | Velvety matte frost with wide Gaussian dispersion | Background sheets, overlays, dialogs |
| `crystal` | Ultra-clear refraction rim with minimal diffusion | Badges, pills, chip selectors |
| `milkyLitchi`| Creamy dessert undertone, semi-opaque | Dark mode contrast, readable reading cards |
| `roseTint` | Dusky rose petal glow | Romantic or luxury lifestyle accents |
| `goldenCitrus` | Sun-kissed golden citrus glaze | Warning alerts, rewards, sunny highlights |

---

## 📜 License

MIT License. Crafted with ❤️ by Cavern Labs.
