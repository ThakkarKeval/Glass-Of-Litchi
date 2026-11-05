import 'dart:ui';
import 'package:flutter/material.dart';

import 'flavour.dart';

/// The core primitive widget for the **Glass of Litchi** UI design system.
///
/// Combines hardware-accelerated Gaussian backdrop filtering, multi-stop
/// specular rim gradients, an inner ambient light sheen, and organic fruit-toned
/// tinting into a single, high-performance widget.
class LitchiGlass extends StatelessWidget {
  const LitchiGlass({
    super.key,
    required this.child,
    this.flavour = LitchiFlavour.dewy,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.blur,
    this.tint,
    this.borderGradient,
    this.borderWidth,
    this.enableBlur = true,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The widget positioned inside the glass container.
  final Widget child;

  /// The aesthetic preset defining blur, tint, and specular highlights.
  final LitchiFlavour flavour;

  /// Corner radius of the glass panel. Defaults to 24px rounded corners.
  final BorderRadiusGeometry borderRadius;

  /// Optional fixed width for the glass panel.
  final double? width;

  /// Optional fixed height for the glass panel.
  final double? height;

  /// Inner padding around the [child].
  final EdgeInsetsGeometry? padding;

  /// Outer margin surrounding the glass panel.
  final EdgeInsetsGeometry? margin;

  /// Optional override for the blur sigma specified in [flavour].
  final double? blur;

  /// Optional override for the tint color specified in [flavour].
  final Color? tint;

  /// Optional override for the border rim gradient.
  final Gradient? borderGradient;

  /// Optional override for the rim border thickness.
  final double? borderWidth;

  /// Whether backdrop blur is active. If set to `false`, a graceful opaque
  /// [LitchiFlavour.fallbackColor] is used instead to guarantee maximum FPS.
  final bool enableBlur;

  /// The clipping behavior applied to the child and background layers.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final effectiveBlur = blur ?? flavour.blurSigma;
    final effectiveTint = tint ?? flavour.tintColor;
    final effectiveBorderGradient = borderGradient ?? flavour.borderGradient;
    final effectiveBorderWidth = borderWidth ?? flavour.borderWidth;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    // Apply inner ambient specular sheen if enabled
    if (flavour.innerSheen && flavour.specularOpacity > 0.0) {
      content = Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45],
                    colors: [
                      Colors.white.withValues(
                        alpha: (flavour.specularOpacity * 0.25).clamp(0.0, 1.0),
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          content,
        ],
      );
    }

    Widget glassPanel;

    if (enableBlur && effectiveBlur > 0.0) {
      glassPanel = ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            color: effectiveTint,
            child: content,
          ),
        ),
      );
    } else {
      glassPanel = ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: Container(
          color: flavour.fallbackColor,
          child: content,
        ),
      );
    }

    // Outer specular gradient border rim
    if (effectiveBorderGradient != null && effectiveBorderWidth > 0.0) {
      glassPanel = CustomPaint(
        foregroundPainter: _LitchiBorderPainter(
          borderRadius: borderRadius.resolve(Directionality.of(context)),
          gradient: effectiveBorderGradient,
          strokeWidth: effectiveBorderWidth,
        ),
        child: glassPanel,
      );
    }

    if (margin != null) {
      glassPanel = Padding(padding: margin!, child: glassPanel);
    }

    return glassPanel;
  }
}

/// Custom painter for seamless, high-fidelity gradient borders that avoid
/// clipping artifacts and sub-pixel gap issues.
class _LitchiBorderPainter extends CustomPainter {
  const _LitchiBorderPainter({
    required this.borderRadius,
    required this.gradient,
    required this.strokeWidth,
  });

  final BorderRadius borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeWidth <= 0.0) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect).deflate(strokeWidth / 2.0);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _LitchiBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
