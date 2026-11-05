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

### 1. Ready-to-use Glass Card
```dart
LitchiCard(
  flavour: LitchiFlavour.juicy,
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

### 2. Tactile Glass Button
```dart
LitchiButton(
  flavour: LitchiFlavour.dewy,
  onPressed: () {},
  child: const Text('Refresh'),
)
```

### 3. Core Primitive
```dart
LitchiGlass(
  flavour: LitchiFlavour.crystal,
  borderRadius: BorderRadius.circular(16),
  padding: const EdgeInsets.all(16),
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
