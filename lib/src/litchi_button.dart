import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flavour.dart';
import 'litchi_glass.dart';

/// A tactile, dewy glass button with spring-driven press physics and specular sheen.
/// Supports Figma Glass parameters and Apple continuous corner squircle smoothing.
class LitchiButton extends StatefulWidget {
  const LitchiButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.flavour = LitchiFlavour.juicy,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.cornerSmoothing = 0.6,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
    this.lightAngle,
    this.lightPercent,
    this.refraction,
    this.depth,
    this.dispersion,
    this.frost,
    this.splay,
    this.enableHaptics = true,
    this.enableBlur = true,
    this.shaderRefraction = true,
  });

  /// Factory constructor to instantiate a [LitchiButton] directly from Figma Glass properties.
  factory LitchiButton.fromFigma({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    double lightAngle = 135.0,
    double lightPercent = 75.0,
    double refraction = 20.0,
    double depth = 6.0,
    double dispersion = 20.0,
    double frost = 25.0,
    double splay = 40.0,
    double cornerSmoothing = 0.6,
    BorderRadiusGeometry borderRadius =
        const BorderRadius.all(Radius.circular(16.0)),
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
    bool enableHaptics = true,
    bool enableBlur = true,
    bool shaderRefraction = true,
  }) {
    return LitchiButton(
      key: key,
      onPressed: onPressed,
      borderRadius: borderRadius,
      cornerSmoothing: cornerSmoothing,
      padding: padding,
      lightAngle: lightAngle,
      lightPercent: lightPercent,
      refraction: refraction,
      depth: depth,
      dispersion: dispersion,
      frost: frost,
      splay: splay,
      enableHaptics: enableHaptics,
      enableBlur: enableBlur,
      shaderRefraction: shaderRefraction,
      child: child,
    );
  }

  /// Action triggered when the button is tapped. If `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Content widget inside the button (e.g. [Text], [Row], or [Icon]).
  final Widget child;

  /// Aesthetic flavour preset. Defaults to [LitchiFlavour.juicy].
  final LitchiFlavour flavour;

  /// Corner radius for the button.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous curvature squircle factor (0.0 to 1.0, default: 0.6).
  final double cornerSmoothing;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Direction of primary key light in degrees.
  final double? lightAngle;

  /// Specular peak brightness percentage (0% to 100%).
  final double? lightPercent;

  /// Optical bending index at the rim (0% to 100%).
  final double? refraction;

  /// 3D slab thickness and elevation depth (0 to 50 px).
  final double? depth;

  /// Chromatic aberration / rainbow prismatic rim intensity (0% to 100%).
  final double? dispersion;

  /// Matte diffusion / surface roughness (0% to 100%).
  final double? frost;

  /// Angular spread of the specular highlight along the perimeter (0% to 100%).
  final double? splay;

  /// Whether to invoke light haptic feedback on tap down.
  final bool enableHaptics;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

  /// Whether GPU fragment shader optical refraction and dispersion are enabled.
  final bool shaderRefraction;

  @override
  State<LitchiButton> createState() => _LitchiButtonState();
}

class _LitchiButtonState extends State<LitchiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    final effectiveFlavour = isEnabled
        ? widget.flavour
        : widget.flavour.copyWith(
            tintColor: const Color(0x10FFFFFF),
            specularOpacity: 0.1,
          );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: isEnabled ? _opacityAnimation.value : 0.5,
              child: child,
            ),
          );
        },
        child: LitchiGlass(
          flavour: effectiveFlavour,
          borderRadius: widget.borderRadius,
          cornerSmoothing: widget.cornerSmoothing,
          padding: widget.padding,
          lightAngle: widget.lightAngle,
          lightPercent: widget.lightPercent,
          refraction: widget.refraction,
          depth: widget.depth,
          dispersion: widget.dispersion,
          frost: widget.frost,
          splay: widget.splay,
          enableBlur: widget.enableBlur,
          shaderRefraction: widget.shaderRefraction,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              letterSpacing: 0.2,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
