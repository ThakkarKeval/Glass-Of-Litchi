import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// GPU fragment shader pipeline for optical refraction and dispersion in [glass_of_litchi].
///
/// On devices running Impeller (modern Android & iOS), this pipeline drives
/// true pixel bending, edge-bevel refraction, and chromatic aberration (color fringing)
/// behind the glass surface.
///
/// On platforms or devices where fragment shaders are unavailable, it gracefully
/// falls back to standard hardware Gaussian blur and canvas specular gradients.
class LitchiShaderPipeline {
  LitchiShaderPipeline._();

  /// The shared singleton instance.
  static final LitchiShaderPipeline instance = LitchiShaderPipeline._();

  /// Known package asset paths for the refraction fragment shader.
  static const List<String> _shaderAssetPaths = [
    'packages/glass_of_litchi/shaders/refraction.frag',
    'shaders/refraction.frag',
  ];

  ui.FragmentProgram? _program;
  Future<bool>? _loadFuture;
  bool _loadFailed = false;

  /// Notifier triggered when the shader program is successfully compiled on the GPU.
  final ValueNotifier<ui.FragmentProgram?> programNotifier =
      ValueNotifier<ui.FragmentProgram?>(null);

  /// Whether the shader program is compiled and ready for rendering.
  bool get isReady => _program != null;

  /// Whether shader loading failed or is unsupported in the current environment.
  bool get hasFailed => _loadFailed;

  /// Current compiled [ui.FragmentProgram], or `null` if not yet loaded.
  ui.FragmentProgram? get program => _program;

  /// Pre-compiles and caches the refraction fragment shader.
  ///
  /// Call this in `main()` before [runApp] for instant shader availability on frame 0:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await LitchiShaderPipeline.instance.ensureLoaded();
  ///   runApp(const MyApp());
  /// }
  /// ```
  Future<bool> ensureLoaded() {
    if (_program != null) return Future.value(true);

    // Concurrent callers (e.g. a precacheShaders() in main() racing with the
    // first LitchiGlass build) must await the same in-flight attempt instead
    // of each getting an immediate `false` that looks like a real failure.
    final inFlight = _loadFuture;
    if (inFlight != null) return inFlight;

    final future = _load();
    _loadFuture = future;
    return future;
  }

  Future<bool> _load() async {
    for (final assetPath in _shaderAssetPaths) {
      try {
        final program = await ui.FragmentProgram.fromAsset(assetPath);
        _program = program;
        _warmup(program);
        _loadFailed = false;
        _loadFuture = null;
        programNotifier.value = program;
        return true;
      } catch (_) {
        // Try next fallback path
      }
    }

    _loadFailed = true;
    _loadFuture = null;
    return false;
  }

  /// Forces the GPU driver to compile the Pipeline State Object (PSO) offscreen,
  /// eliminating first-frame draw hitching.
  void _warmup(ui.FragmentProgram program) {
    try {
      final shader = program.fragmentShader();
      shader.setFloat(2, 0.5);
      shader.setFloat(3, 0.5);
      shader.setFloat(4, 20.0);
      shader.setFloat(5, 0.785);
      shader.setFloat(6, 0.5);
      shader.setFloat(7, 24.0);
      shader.setFloat(8, 1.02);
      shader.setFloat(9, 0.0);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..imageFilter = ui.ImageFilter.shader(shader);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 2, 2), paint);
      final picture = recorder.endRecording();
      final img = picture.toImageSync(2, 2);
      img.dispose();
      picture.dispose();
    } catch (_) {
      // In headless test environments or unsupported platforms, warmup is safely skipped.
    }
  }

  /// Creates a combined or standalone [ui.ImageFilter] applying optical refraction.
  ///
  /// - [baseBlur]: Optional Gaussian blur filter to compose with the shader.
  /// - [refraction]: Distortion strength (0.0 to 1.0).
  /// - [dispersion]: Chromatic aberration fringing (0.0 to 1.0).
  /// - [bevelWidth]: Edge rim width in device pixels (4.0 to 80.0 px).
  /// - [lightAngle]: Incident lighting angle in degrees.
  /// - [specular]: Specular highlight glint intensity (0.0 to 1.0).
  /// - [cornerRadius]: Corner radius in device pixels for rounded-box SDF.
  /// - [magnification]: Subtle central lens magnification (1.0 to 1.15).
  /// - [noise]: Micro-surface roughness / film grain noise (0.0 to 100.0).
  ui.ImageFilter? createRefractionFilter({
    ui.ImageFilter? baseBlur,
    double refraction = 0.5,
    double dispersion = 0.5,
    double bevelWidth = 20.0,
    double lightAngle = 45.0,
    double specular = 0.5,
    double cornerRadius = 24.0,
    double magnification = 1.02,
    double noise = 0.0,
  }) {
    final program = _program;
    if (program == null) return baseBlur;

    try {
      final shader = program.fragmentShader();

      // Slots 0 & 1: uSize (vec2) is populated automatically by ImageFilter.shader

      // Slot 2: uRefraction (0.0 to 1.0)
      shader.setFloat(2, refraction.clamp(0.0, 1.0));

      // Slot 3: uDispersion (0.0 to 1.0)
      shader.setFloat(3, dispersion.clamp(0.0, 1.0));

      // Slot 4: uBevelWidth (rim in pixels)
      shader.setFloat(4, bevelWidth.clamp(4.0, 80.0));

      // Slot 5: uLightAngle (in radians)
      final radians = lightAngle * (math.pi / 180.0);
      shader.setFloat(5, radians);

      // Slot 6: uSpecular
      shader.setFloat(6, specular.clamp(0.0, 1.0));

      // Slot 7: uCornerRadius (pixels)
      shader.setFloat(7, cornerRadius.clamp(0.0, 120.0));

      // Slot 8: uMagnification
      shader.setFloat(8, magnification.clamp(1.0, 1.15));

      // Slot 9: uNoise
      shader.setFloat(9, (noise / 100.0).clamp(0.0, 1.0));

      final shaderFilter = ui.ImageFilter.shader(shader);

      if (baseBlur != null) {
        // Refract the original backdrop before diffusion. Feeding a padded,
        // downsampled blur texture into the runtime shader can misalign its
        // coordinates under a translated clip on Impeller.
        return ui.ImageFilter.compose(outer: baseBlur, inner: shaderFilter);
      }
      return shaderFilter;
    } catch (_) {
      // In case of platform shader incompatibility or headless test runner,
      // gracefully fall back to base blur.
      return baseBlur;
    }
  }
}
