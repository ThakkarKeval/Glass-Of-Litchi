import 'package:flutter/material.dart';

/// An ambient scope that coordinates scene lighting, squircle corner curvature,
/// and backdrop-blur batching across all nested [LitchiGlass], [LitchiCard], and [LitchiButton] widgets.
///
/// ### Why LitchiScope?
/// In standard Flutter, every individual [LitchiGlass] or [LitchiCard] creates an
/// independent [BackdropFilter]. In scrolling lists with 10+ items, this causes 10+
/// separate GPU `saveLayer` and texture sampling passes per frame, leading to jank
/// on mobile devices.
///
/// Wrapping your view tree in [LitchiScope] with `batchBlur: true` coordinates
/// the blur pipeline: child glass elements automatically transition to a fast,
/// single-pass crystal mode (preserving all specular rims, refraction bevels, and
/// squircle clipping) without redundant GPU `saveLayer` calls.
///
/// In addition, [LitchiScope] provides a unified physical lighting model
/// (consistent key light angle, brightness, dispersion, and squircle corner smoothing)
/// across the entire scene.
class LitchiScope extends InheritedWidget {
  const LitchiScope({
    super.key,
    required super.child,
    this.lightAngle,
    this.lightPercent,
    this.dispersion,
    this.cornerSmoothing = 0.6,
    this.batchBlur = false,
  });

  /// Direction of primary scene key light in degrees (0° to 360°).
  /// Inherited by child glass widgets when not explicitly overridden.
  final double? lightAngle;

  /// Specular peak brightness percentage (0% to 100%).
  /// Inherited by child glass widgets when not explicitly overridden.
  final double? lightPercent;

  /// Chromatic aberration / rainbow prismatic rim intensity (0% to 100%).
  /// Inherited by child glass widgets when not explicitly overridden.
  final double? dispersion;

  /// Apple continuous corner squircle curvature factor (0.0 to 1.0, default: 0.6).
  /// Inherited by child glass widgets when not explicitly overridden.
  final double cornerSmoothing;

  /// Whether to batch backdrop filtering for children.
  /// When `true`, nested child glass widgets bypass independent [BackdropFilter]
  /// passes and render high-performance crystal glass, maintaining 120 FPS in scrollable feeds.
  final bool batchBlur;

  /// Retrieves the nearest [LitchiScope] from the widget tree, if present.
  static LitchiScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LitchiScope>();
  }

  /// Retrieves the nearest [LitchiScope] from the widget tree, throwing if none is found.
  static LitchiScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No LitchiScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant LitchiScope oldWidget) {
    return oldWidget.lightAngle != lightAngle ||
        oldWidget.lightPercent != lightPercent ||
        oldWidget.dispersion != dispersion ||
        oldWidget.cornerSmoothing != cornerSmoothing ||
        oldWidget.batchBlur != batchBlur;
  }
}
