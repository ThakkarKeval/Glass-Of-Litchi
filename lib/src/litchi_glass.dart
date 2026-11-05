import 'dart:ui';
import 'package:flutter/material.dart';

import 'flavour.dart';
import 'litchi_scope.dart';
import 'squircle.dart';

/// The core primitive widget for the **Glass of Litchi** UI design system.
///
/// Supports direct 1:1 mapping with Figma Glass effect parameters:
/// - [lightAngle]: Direction of incident light (0° to 360°)
/// - [lightPercent]: Specular peak brightness (0% to 100%)
/// - [refraction]: Optical inner bevel index (0% to 100%)
/// - [depth]: 3D slab thickness and elevation shadow (0 to 50 px)
/// - [dispersion]: Chromatic aberration / rainbow prismatic rim (0% to 100%)
/// - [frost]: Matte blur diffusion / roughness (0% to 100%)
/// - [splay]: Specular highlight spread along the rim (0% to 100%)
/// - [cornerSmoothing]: Apple iOS/visionOS continuous squircle curvature (0.0 to 1.0, default: 0.6)
class LitchiGlass extends StatelessWidget {
  const LitchiGlass({
    super.key,
    required this.child,
    this.flavour = LitchiFlavour.dewy,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.cornerSmoothing = 0.6,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.blur,
    this.tint,
    this.lightAngle,
    this.lightPercent,
    this.refraction,
    this.depth,
    this.dispersion,
    this.frost,
    this.splay,
    this.borderGradient,
    this.borderWidth,
    this.specularOpacity,
    this.secondarySpecularOpacity,
    this.enableBlur = true,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Factory constructor to instantiate directly from Figma Glass effect properties.
  factory LitchiGlass.fromFigma({
    Key? key,
    required Widget child,
    double lightAngle = 135.0,
    double lightPercent = 75.0,
    double refraction = 20.0,
    double depth = 8.0,
    double dispersion = 20.0,
    double frost = 25.0,
    double splay = 40.0,
    double cornerSmoothing = 0.6,
    Color tintColor = const Color(0x1AFFFFFF),
    BorderRadiusGeometry borderRadius =
        const BorderRadius.all(Radius.circular(24.0)),
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderWidth = 1.2,
    bool enableBlur = true,
  }) {
    return LitchiGlass(
      key: key,
      borderRadius: borderRadius,
      cornerSmoothing: cornerSmoothing,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      lightAngle: lightAngle,
      lightPercent: lightPercent,
      refraction: refraction,
      depth: depth,
      dispersion: dispersion,
      frost: frost,
      splay: splay,
      tint: tintColor,
      borderWidth: borderWidth,
      enableBlur: enableBlur,
      child: child,
    );
  }

  /// The widget positioned inside the glass container.
  final Widget child;

  /// The aesthetic preset defining blur, tint, and specular highlights.
  final LitchiFlavour flavour;

  /// Corner radius of the glass panel. Defaults to 24px rounded corners.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous curvature (squircle) smoothing factor (0.0 = standard RRect, 0.6 = iOS G2 continuity, 1.0 = superellipse).
  final double? cornerSmoothing;

  /// Optional fixed width for the glass panel.
  final double? width;

  /// Optional fixed height for the glass panel.
  final double? height;

  /// Inner padding around the [child].
  final EdgeInsetsGeometry? padding;

  /// Outer margin surrounding the glass panel.
  final EdgeInsetsGeometry? margin;

  /// Optional override for the blur sigma in pixels (if set, overrides [frost]).
  final double? blur;

  /// Optional override for the tint color specified in [flavour].
  final Color? tint;

  /// Direction of primary key light in degrees (0° to 360°, default: 135.0).
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

  /// Optional override for the border rim gradient.
  final Gradient? borderGradient;

  /// Optional override for the rim border thickness.
  final double? borderWidth;

  /// Optional override for the primary specular highlight opacity at the incident rim.
  final double? specularOpacity;

  /// Optional override for the secondary bounce specular highlight opacity.
  final double? secondarySpecularOpacity;

  /// Whether backdrop blur is active. If set to `false`, a graceful opaque
  /// [LitchiFlavour.fallbackColor] is used instead to guarantee maximum FPS.
  final bool enableBlur;

  /// The clipping behavior applied to the child and background layers.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final scope = LitchiScope.maybeOf(context);

    final effectiveFrost = frost ?? flavour.frost;
    final effectiveBlur =
        blur ?? (frost != null ? (effectiveFrost / 100.0 * 40.0) : flavour.blurSigma);
    final effectiveTint = tint ?? flavour.tintColor;
    final effectiveAngle = lightAngle ?? scope?.lightAngle ?? flavour.lightAngle;
    final effectiveLightPct = lightPercent ?? scope?.lightPercent ?? flavour.lightPercent;
    final effectiveRefraction = refraction ?? flavour.refraction;
    final effectiveDepth = depth ?? flavour.depth;
    final effectiveDispersion = dispersion ?? scope?.dispersion ?? flavour.dispersion;
    final effectiveSplay = splay ?? flavour.splay;
    final effectiveBorderWidth = borderWidth ?? flavour.borderWidth;
    final effectiveSmoothing =
        (cornerSmoothing ?? scope?.cornerSmoothing ?? 0.6).clamp(0.0, 1.0);

    // If scoped liteMode is active, child bypasses individual BackdropFilter to save GPU fill rate
    final effectiveEnableBlur =
        (scope?.effectiveLiteMode == true) ? false : enableBlur;

    final effectiveSpecular = specularOpacity ??
        (lightPercent != null
            ? (effectiveLightPct / 100.0).clamp(0.0, 1.0)
            : flavour.specularOpacity);

    final effectiveSecSpecular = secondarySpecularOpacity ??
        (lightPercent != null
            ? (effectiveSpecular * 0.48).clamp(0.0, 1.0)
            : flavour.secondarySpecularOpacity);

    // Resolve border gradient: if custom gradient or figma options set, resolve dynamically
    final Gradient? effectiveBorderGradient;
    if (borderGradient != null) {
      effectiveBorderGradient = borderGradient;
    } else if (lightAngle != null ||
        lightPercent != null ||
        dispersion != null ||
        splay != null ||
        scope?.lightAngle != null ||
        scope?.dispersion != null) {
      effectiveBorderGradient = createSpecularBorderGradient(
        angle: effectiveAngle,
        lightPercent: effectiveLightPct,
        dispersion: effectiveDispersion,
        splay: effectiveSplay,
        primaryOpacity: effectiveSpecular,
        secondaryOpacity: effectiveSecSpecular,
      );
    } else {
      effectiveBorderGradient = flavour.resolveBorderGradient(
        angle: effectiveAngle,
        lightPct: effectiveLightPct,
        disp: effectiveDispersion,
        sply: effectiveSplay,
      );
    }

    final resolvedRadius = borderRadius.resolve(Directionality.of(context));

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    // Apply inner ambient specular sheen aligned with the light angle
    if (flavour.innerSheen && effectiveSpecular > 0.0) {
      final (sheenBegin, sheenEnd) = alignmentPairFromDegrees(effectiveAngle);
      final sheenWidget = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: effectiveSmoothing == 0.0 ? borderRadius : null,
          gradient: LinearGradient(
            begin: sheenBegin,
            end: sheenEnd,
            stops: const [0.0, 0.45],
            colors: [
              Colors.white.withValues(
                alpha: (effectiveSpecular * 0.09).clamp(0.0, 1.0),
              ),
              Colors.transparent,
            ],
          ),
        ),
      );

      content = Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: effectiveSmoothing > 0.0
                  ? ClipPath(
                      clipper: SquircleClipper(
                        borderRadius: resolvedRadius,
                        smoothing: effectiveSmoothing,
                      ),
                      child: sheenWidget,
                    )
                  : sheenWidget,
            ),
          ),
          content,
        ],
      );
    }

    Widget glassPanel;

    if (effectiveEnableBlur && effectiveBlur > 0.0) {
      final blurWidget = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: Container(
          color: effectiveTint,
          child: content,
        ),
      );

      if (effectiveSmoothing > 0.0) {
        glassPanel = ClipPath(
          clipper: SquircleClipper(
            borderRadius: resolvedRadius,
            smoothing: effectiveSmoothing,
          ),
          clipBehavior: clipBehavior,
          child: blurWidget,
        );
      } else {
        glassPanel = ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: clipBehavior,
          child: blurWidget,
        );
      }
    } else {
      final solidWidget = Container(
        color: (scope?.effectiveLiteMode == true) ? effectiveTint : flavour.fallbackColor,
        child: content,
      );

      if (effectiveSmoothing > 0.0) {
        glassPanel = ClipPath(
          clipper: SquircleClipper(
            borderRadius: resolvedRadius,
            smoothing: effectiveSmoothing,
          ),
          clipBehavior: clipBehavior,
          child: solidWidget,
        );
      } else {
        glassPanel = ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: clipBehavior,
          child: solidWidget,
        );
      }
    }

    // Outer specular gradient border rim with refraction & depth bevels
    if (effectiveBorderGradient != null && effectiveBorderWidth > 0.0) {
      glassPanel = CustomPaint(
        foregroundPainter: _LitchiBorderPainter(
          borderRadius: resolvedRadius,
          cornerSmoothing: effectiveSmoothing,
          gradient: effectiveBorderGradient,
          strokeWidth: effectiveBorderWidth,
          refraction: effectiveRefraction,
          depth: effectiveDepth,
          lightAngle: effectiveAngle,
          specularOpacity: effectiveSpecular,
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

/// Custom painter for seamless, high-fidelity gradient borders incorporating
/// Apple squircle continuous curvature and Figma optical parameters.
class _LitchiBorderPainter extends CustomPainter {
  const _LitchiBorderPainter({
    required this.borderRadius,
    this.cornerSmoothing = 0.6,
    required this.gradient,
    required this.strokeWidth,
    this.refraction = 0.0,
    this.depth = 0.0,
    this.lightAngle = 135.0,
    this.specularOpacity = 0.6,
  });

  final BorderRadius borderRadius;
  final double cornerSmoothing;
  final Gradient gradient;
  final double strokeWidth;
  final double refraction;
  final double depth;
  final double lightAngle;
  final double specularOpacity;

  BorderRadius _deflateRadius(BorderRadius br, double delta) {
    return BorderRadius.only(
      topLeft: Radius.circular((br.topLeft.x - delta).clamp(0.0, double.infinity)),
      topRight: Radius.circular((br.topRight.x - delta).clamp(0.0, double.infinity)),
      bottomRight: Radius.circular((br.bottomRight.x - delta).clamp(0.0, double.infinity)),
      bottomLeft: Radius.circular((br.bottomLeft.x - delta).clamp(0.0, double.infinity)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (strokeWidth <= 0.0) return;

    final rect = Offset.zero & size;
    final halfStroke = strokeWidth / 2.0;
    final rimRect = rect.deflate(halfStroke);

    // 1. Primary Specular Rim
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    if (cornerSmoothing > 0.0) {
      final rimPath = SquirclePath.create(
        rect: rimRect,
        borderRadius: _deflateRadius(borderRadius, halfStroke),
        smoothing: cornerSmoothing,
      );
      canvas.drawPath(rimPath, paint);
    } else {
      final rrect = borderRadius.toRRect(rect).deflate(halfStroke);
      canvas.drawRRect(rrect, paint);
    }

    // 2. Refraction Inner Bevel (simulates optical bending through glass thickness)
    if (refraction > 0.0) {
      final refractionOffset = strokeWidth + (refraction / 100.0) * 2.5;
      if (rect.width > refractionOffset * 2 && rect.height > refractionOffset * 2) {
        final innerRect = rect.deflate(refractionOffset);
        final (begin, end) = alignmentPairFromDegrees(lightAngle + 180.0);
        final refractionGradient = LinearGradient(
          begin: begin,
          end: end,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            Colors.white.withValues(
              alpha: (specularOpacity * 0.16 * (refraction / 100.0)).clamp(0.0, 0.22),
            ),
            Colors.transparent,
            Colors.white.withValues(
              alpha: (specularOpacity * 0.08 * (refraction / 100.0)).clamp(0.0, 0.14),
            ),
          ],
        );

        final innerPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..shader = refractionGradient.createShader(rect);

        if (cornerSmoothing > 0.0) {
          final innerPath = SquirclePath.create(
            rect: innerRect,
            borderRadius: _deflateRadius(borderRadius, refractionOffset),
            smoothing: cornerSmoothing,
          );
          canvas.drawPath(innerPath, innerPaint);
        } else {
          final innerRRect = borderRadius.toRRect(rect).deflate(refractionOffset);
          canvas.drawRRect(innerRRect, innerPaint);
        }
      }
    }

    // 3. Depth Bevel / Thickness Shadow (simulates 3D slab thickness on shadow side)
    if (depth > 0.0) {
      final (shadowBegin, _) = alignmentPairFromDegrees(lightAngle + 180.0);
      final depthOffset = (depth / 50.0 * 2.0).clamp(0.5, 2.5);
      final depthRect = rect.deflate(depthOffset);

      final depthPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = LinearGradient(
          begin: shadowBegin,
          end: Alignment(-shadowBegin.x, -shadowBegin.y),
          stops: const [0.0, 0.4, 1.0],
          colors: [
            Colors.black.withValues(
              alpha: (0.16 * (depth / 30.0)).clamp(0.0, 0.35),
            ),
            Colors.transparent,
            Colors.transparent,
          ],
        ).createShader(rect);

      if (cornerSmoothing > 0.0) {
        final depthPath = SquirclePath.create(
          rect: depthRect,
          borderRadius: _deflateRadius(borderRadius, depthOffset),
          smoothing: cornerSmoothing,
        );
        canvas.drawPath(depthPath, depthPaint);
      } else {
        final depthRRect = borderRadius.toRRect(rect).deflate(depthOffset);
        canvas.drawRRect(depthRRect, depthPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LitchiBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.cornerSmoothing != cornerSmoothing ||
        oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.refraction != refraction ||
        oldDelegate.depth != depth ||
        oldDelegate.lightAngle != lightAngle ||
        oldDelegate.specularOpacity != specularOpacity;
  }
}
