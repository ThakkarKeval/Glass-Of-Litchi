import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Calculates the (begin, end) [Alignment] pair for a given angle in degrees.
///
/// Follows standard CSS linear gradient convention:
/// - 0° is to top (bottom-to-top)
/// - 90° is to right (left-to-right)
/// - 135° directs light from **top-left to bottom-right** (the classic glass angle)
/// - 180° is to bottom (top-to-bottom)
/// - 270° is to left (right-to-left)
/// - 315° is to top-right (bottom-left to top-right)
(Alignment, Alignment) alignmentPairFromDegrees(double degrees) {
  final normalized = (degrees % 360 + 360) % 360;
  final radians = (normalized - 90.0) * (math.pi / 180.0);
  final x = math.cos(radians);
  final y = math.sin(radians);
  return (Alignment(-x, -y), Alignment(x, y));
}

/// Generates a specular rim gradient incorporating Figma glass parameters:
/// - [angle]: Light angle in degrees (0° to 360°)
/// - [lightPercent]: Specular peak brightness (0% to 100%)
/// - [dispersion]: Chromatic aberration / rainbow prismatic rim (0% to 100%)
/// - [splay]: Specular highlight spread along the rim (0% to 100%)
LinearGradient createSpecularBorderGradient({
  double angle = 135.0,
  double lightPercent = 75.0,
  double dispersion = 20.0,
  double splay = 40.0,
  double? primaryOpacity,
  double? secondaryOpacity,
  Color primaryColor = Colors.white,
  Color? secondaryColor,
  Color? accentColor,
}) {
  final (begin, end) = alignmentPairFromDegrees(angle);
  final effectiveSecondaryColor = secondaryColor ?? primaryColor;

  final effectivePrimaryOpacity =
      primaryOpacity ?? (lightPercent / 100.0).clamp(0.0, 1.0);
  final effectiveSecondaryOpacity =
      secondaryOpacity ?? (effectivePrimaryOpacity * 0.48).clamp(0.0, 1.0);

  // Splay controls how far along the rim the specular highlight spreads
  final splayFactor = (splay / 100.0).clamp(0.05, 0.95);
  final stop1 = (0.14 * splayFactor).clamp(0.03, 0.22);
  final stop2 = (0.32 + 0.20 * splayFactor).clamp(0.25, 0.52);
  final stop3 = (0.68 + 0.14 * (1.0 - splayFactor)).clamp(0.65, 0.88);

  final dispersionFactor = (dispersion / 100.0).clamp(0.0, 1.0);

  if (dispersionFactor > 0.05) {
    // Chromatic dispersion creates prismatic spectral highlights:
    // Cyan/Turquoise lead -> Pure Specular White core -> Rose/Magenta trail
    final cyanFringe = Color.lerp(
      primaryColor,
      const Color(0xFF64FFDA), // Prismatic Cyan
      dispersionFactor * 0.65,
    )!.withValues(alpha: (effectivePrimaryOpacity * 0.85).clamp(0.0, 1.0));

    final whiteCore = primaryColor.withValues(
      alpha: effectivePrimaryOpacity.clamp(0.0, 1.0),
    );

    final roseFringe = Color.lerp(
      primaryColor,
      const Color(0xFFFF80AB), // Prismatic Rose
      dispersionFactor * 0.65,
    )!.withValues(alpha: (effectivePrimaryOpacity * 0.75).clamp(0.0, 1.0));

    final bounceColor = Color.lerp(
      effectiveSecondaryColor,
      const Color(0xFF82B1FF), // Prismatic Ice Blue bounce
      dispersionFactor * 0.35,
    )!.withValues(alpha: effectiveSecondaryOpacity.clamp(0.0, 1.0));

    return LinearGradient(
      begin: begin,
      end: end,
      stops: [0.0, stop1 * 0.5, stop1, stop2, stop3, 1.0],
      colors: [
        cyanFringe,
        whiteCore,
        roseFringe,
        (accentColor ?? primaryColor).withValues(alpha: 0.06),
        Colors.white.withValues(alpha: 0.02),
        bounceColor,
      ],
    );
  }

  return LinearGradient(
    begin: begin,
    end: end,
    stops: [0.0, stop1, stop2, stop3, 1.0],
    colors: [
      primaryColor.withValues(alpha: effectivePrimaryOpacity.clamp(0.0, 1.0)),
      primaryColor.withValues(
        alpha: (effectivePrimaryOpacity * 0.35).clamp(0.0, 1.0),
      ),
      (accentColor ?? primaryColor).withValues(alpha: 0.06),
      Colors.white.withValues(alpha: 0.02),
      effectiveSecondaryColor.withValues(
        alpha: effectiveSecondaryOpacity.clamp(0.0, 1.0),
      ),
    ],
  );
}

/// Pre-configured styling flavours for [LitchiGlass] and [LitchiCard] that map
/// directly to popular Figma Glass effect parameters.
class LitchiFlavour {
  const LitchiFlavour({
    required this.name,
    this.lightAngle = 135.0,
    this.lightPercent = 75.0,
    this.refraction = 20.0,
    this.depth = 8.0,
    this.dispersion = 20.0,
    this.frost = 25.0,
    this.splay = 40.0,
    this.blurSigma = 18.0,
    this.tintColor = const Color(0x1AFFFFFF),
    this.borderGradient,
    this.borderWidth = 1.2,
    this.innerSheen = true,
    this.specularOpacity = 0.6,
    this.secondarySpecularOpacity = 0.35,
    this.noise = 0.0,
    this.fallbackColor = const Color(0xCC1E1E24),
  });

  /// Creates a [LitchiFlavour] directly from Figma Glass effect properties.
  factory LitchiFlavour.fromFigma({
    String name = 'Figma Glass',
    double lightAngle = 135.0,
    double lightPercent = 75.0,
    double refraction = 20.0,
    double depth = 8.0,
    double dispersion = 20.0,
    double frost = 25.0,
    double splay = 40.0,
    double noise = 0.0,
    Color tintColor = const Color(0x1AFFFFFF),
    double borderWidth = 1.2,
    bool innerSheen = true,
    Color fallbackColor = const Color(0xCC1E1E24),
  }) {
    final specular = (lightPercent / 100.0).clamp(0.0, 1.0);
    final blur = (frost / 100.0 * 40.0).clamp(0.0, 60.0);

    return LitchiFlavour(
      name: name,
      lightAngle: lightAngle,
      lightPercent: lightPercent,
      refraction: refraction,
      depth: depth,
      dispersion: dispersion,
      frost: frost,
      splay: splay,
      blurSigma: blur,
      tintColor: tintColor,
      borderWidth: borderWidth,
      innerSheen: innerSheen,
      specularOpacity: specular,
      secondarySpecularOpacity: specular * 0.5,
      noise: noise,
      fallbackColor: fallbackColor,
    );
  }

  /// The descriptive name of the flavour.
  final String name;

  /// Direction of primary key light in degrees (0° to 360°, default: 135.0).
  final double lightAngle;

  /// Specular highlight brightness intensity percentage (0% to 100%).
  final double lightPercent;

  /// Optical bending index at the rim (0% to 100%).
  final double refraction;

  /// 3D slab thickness and elevation depth (0 to 50 px).
  final double depth;

  /// Chromatic aberration / rainbow prismatic rim intensity (0% to 100%).
  final double dispersion;

  /// Matte diffusion / surface roughness (0% to 100%).
  final double frost;

  /// Angular spread of the specular highlight along the perimeter (0% to 100%).
  final double splay;

  /// Gaussian blur intensity in pixels (sigmaX and sigmaY).
  final double blurSigma;

  /// Translucent tint color applied over the backdrop.
  final Color tintColor;

  /// Specular gradient applied to the outer rim border.
  final Gradient? borderGradient;

  /// Thickness of the outer glass rim border.
  final double borderWidth;

  /// Whether to render a subtle ambient light sheen across the glass surface.
  final bool innerSheen;

  /// Opacity of the primary specular highlight rim at the incident edge.
  final double specularOpacity;

  /// Opacity of the secondary bounce highlight rim at the opposite edge.
  final double secondarySpecularOpacity;

  /// Micro-surface roughness / film grain noise percentage (0% to 100%).
  final double noise;

  /// Solid or semi-opaque fallback color when blur is disabled (e.g. on low-end devices).
  final Color fallbackColor;

  /// Resolves the effective specular border gradient using Figma parameters.
  Gradient resolveBorderGradient({
    double? angle,
    double? lightPct,
    double? disp,
    double? sply,
  }) {
    if (borderGradient != null &&
        angle == null &&
        lightPct == null &&
        disp == null &&
        sply == null) {
      return borderGradient!;
    }

    return createSpecularBorderGradient(
      angle: angle ?? lightAngle,
      lightPercent: lightPct ?? lightPercent,
      dispersion: disp ?? dispersion,
      splay: sply ?? splay,
      primaryOpacity: specularOpacity,
      secondaryOpacity: secondarySpecularOpacity,
    );
  }

  /// Creates a copy of this flavour with the given fields replaced.
  LitchiFlavour copyWith({
    String? name,
    double? lightAngle,
    double? lightPercent,
    double? refraction,
    double? depth,
    double? dispersion,
    double? frost,
    double? splay,
    double? blurSigma,
    Color? tintColor,
    Gradient? borderGradient,
    double? borderWidth,
    bool? innerSheen,
    double? specularOpacity,
    double? secondarySpecularOpacity,
    double? noise,
    Color? fallbackColor,
  }) {
    return LitchiFlavour(
      name: name ?? this.name,
      lightAngle: lightAngle ?? this.lightAngle,
      lightPercent: lightPercent ?? this.lightPercent,
      refraction: refraction ?? this.refraction,
      depth: depth ?? this.depth,
      dispersion: dispersion ?? this.dispersion,
      frost: frost ?? this.frost,
      splay: splay ?? this.splay,
      blurSigma: blurSigma ?? this.blurSigma,
      tintColor: tintColor ?? this.tintColor,
      borderGradient: borderGradient ?? this.borderGradient,
      borderWidth: borderWidth ?? this.borderWidth,
      innerSheen: innerSheen ?? this.innerSheen,
      specularOpacity: specularOpacity ?? this.specularOpacity,
      secondarySpecularOpacity:
          secondarySpecularOpacity ?? this.secondarySpecularOpacity,
      noise: noise ?? this.noise,
      fallbackColor: fallbackColor ?? this.fallbackColor,
    );
  }

  /// Linearly interpolates between two [LitchiFlavour] presets.
  static LitchiFlavour? lerp(LitchiFlavour? a, LitchiFlavour? b, double t) {
    if (identical(a, b)) return a;
    if (a == null) return b;
    if (b == null) return a;

    return LitchiFlavour(
      name: t < 0.5 ? a.name : b.name,
      lightAngle: ui.lerpDouble(a.lightAngle, b.lightAngle, t) ?? a.lightAngle,
      lightPercent:
          ui.lerpDouble(a.lightPercent, b.lightPercent, t) ?? a.lightPercent,
      refraction: ui.lerpDouble(a.refraction, b.refraction, t) ?? a.refraction,
      depth: ui.lerpDouble(a.depth, b.depth, t) ?? a.depth,
      dispersion: ui.lerpDouble(a.dispersion, b.dispersion, t) ?? a.dispersion,
      frost: ui.lerpDouble(a.frost, b.frost, t) ?? a.frost,
      splay: ui.lerpDouble(a.splay, b.splay, t) ?? a.splay,
      blurSigma: ui.lerpDouble(a.blurSigma, b.blurSigma, t) ?? a.blurSigma,
      tintColor: Color.lerp(a.tintColor, b.tintColor, t) ?? a.tintColor,
      borderGradient: Gradient.lerp(a.borderGradient, b.borderGradient, t),
      borderWidth:
          ui.lerpDouble(a.borderWidth, b.borderWidth, t) ?? a.borderWidth,
      innerSheen: t < 0.5 ? a.innerSheen : b.innerSheen,
      specularOpacity:
          ui.lerpDouble(a.specularOpacity, b.specularOpacity, t) ??
          a.specularOpacity,
      secondarySpecularOpacity:
          ui.lerpDouble(
            a.secondarySpecularOpacity,
            b.secondarySpecularOpacity,
            t,
          ) ??
          a.secondarySpecularOpacity,
      noise: ui.lerpDouble(a.noise, b.noise, t) ?? a.noise,
      fallbackColor:
          Color.lerp(a.fallbackColor, b.fallbackColor, t) ?? a.fallbackColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LitchiFlavour &&
        other.name == name &&
        other.lightAngle == lightAngle &&
        other.lightPercent == lightPercent &&
        other.refraction == refraction &&
        other.depth == depth &&
        other.dispersion == dispersion &&
        other.frost == frost &&
        other.splay == splay &&
        other.blurSigma == blurSigma &&
        other.tintColor == tintColor &&
        other.borderGradient == borderGradient &&
        other.borderWidth == borderWidth &&
        other.innerSheen == innerSheen &&
        other.specularOpacity == specularOpacity &&
        other.secondarySpecularOpacity == secondarySpecularOpacity &&
        other.noise == noise &&
        other.fallbackColor == fallbackColor;
  }

  @override
  int get hashCode => Object.hash(
    name,
    lightAngle,
    lightPercent,
    refraction,
    depth,
    dispersion,
    frost,
    splay,
    blurSigma,
    tintColor,
    borderGradient,
    borderWidth,
    innerSheen,
    specularOpacity,
    secondarySpecularOpacity,
    noise,
    fallbackColor,
  );

  /// Fresh, crisp morning dew with high translucency, crystalline clarity, and subtle rainbow rim.
  static const LitchiFlavour dewy = LitchiFlavour(
    name: 'Dewy',
    lightAngle: 135.0,
    lightPercent: 75.0,
    refraction: 20.0,
    depth: 8.0,
    dispersion: 25.0,
    frost: 22.0,
    splay: 45.0,
    blurSigma: 18.0,
    tintColor: Color(0x0EFFFFFF),
    borderWidth: 1.0,
    specularOpacity: 0.48,
    secondarySpecularOpacity: 0.22,
    noise: 0.0,
    fallbackColor: Color(0xD912151D),
  );

  /// Vibrant, succulent lychee fruit tint with rose-gold prismatic sheen.
  static const LitchiFlavour juicy = LitchiFlavour(
    name: 'Juicy',
    lightAngle: 135.0,
    lightPercent: 85.0,
    refraction: 25.0,
    depth: 10.0,
    dispersion: 35.0,
    frost: 26.0,
    splay: 50.0,
    blurSigma: 22.0,
    tintColor: Color(0x2BFF537A),
    borderWidth: 1.4,
    specularOpacity: 0.75,
    secondarySpecularOpacity: 0.45,
    noise: 4.0,
    fallbackColor: Color(0xEB2A1820),
  );

  /// Velvety, frosted glass with wide light splay and high matte diffusion.
  static const LitchiFlavour frosted = LitchiFlavour(
    name: 'Frosted',
    lightAngle: 135.0,
    lightPercent: 65.0,
    refraction: 15.0,
    depth: 6.0,
    dispersion: 10.0,
    frost: 50.0,
    splay: 65.0,
    blurSigma: 30.0,
    tintColor: Color(0x33FFFFFF),
    borderWidth: 1.1,
    specularOpacity: 0.55,
    secondarySpecularOpacity: 0.3,
    noise: 14.0,
    fallbackColor: Color(0xEE252530),
  );

  /// Ultra-clear optical crystal with high refraction and razor-sharp splay.
  static const LitchiFlavour crystal = LitchiFlavour(
    name: 'Crystal',
    lightAngle: 135.0,
    lightPercent: 90.0,
    refraction: 40.0,
    depth: 12.0,
    dispersion: 45.0,
    frost: 10.0,
    splay: 25.0,
    blurSigma: 10.0,
    tintColor: Color(0x0DFFFFFF),
    borderWidth: 1.5,
    specularOpacity: 0.85,
    secondarySpecularOpacity: 0.5,
    noise: 0.0,
    fallbackColor: Color(0xCC1A1A22),
  );

  /// Creamy, sweet lychee dessert aesthetic with soft milky undertones.
  static const LitchiFlavour milkyLitchi = LitchiFlavour(
    name: 'Milky Litchi',
    lightAngle: 135.0,
    lightPercent: 80.0,
    refraction: 22.0,
    depth: 9.0,
    dispersion: 20.0,
    frost: 35.0,
    splay: 50.0,
    blurSigma: 26.0,
    tintColor: Color(0x36FFF0F4),
    borderWidth: 1.3,
    specularOpacity: 0.7,
    secondarySpecularOpacity: 0.4,
    noise: 6.0,
    fallbackColor: Color(0xEE2A1E24),
  );

  /// Romantic, dusky rose petal glass with dual-rim rose specular highlights.
  static const LitchiFlavour roseTint = LitchiFlavour(
    name: 'Rose Tint',
    lightAngle: 135.0,
    lightPercent: 78.0,
    refraction: 22.0,
    depth: 8.0,
    dispersion: 30.0,
    frost: 25.0,
    splay: 45.0,
    blurSigma: 20.0,
    tintColor: Color(0x28E05688),
    borderWidth: 1.2,
    specularOpacity: 0.65,
    secondarySpecularOpacity: 0.4,
    noise: 4.0,
    fallbackColor: Color(0xEA2A1522),
  );

  /// Warm, sunset-kissed citrus glaze with golden nectar accents on corners.
  static const LitchiFlavour goldenCitrus = LitchiFlavour(
    name: 'Golden Citrus',
    lightAngle: 135.0,
    lightPercent: 82.0,
    refraction: 24.0,
    depth: 9.0,
    dispersion: 30.0,
    frost: 25.0,
    splay: 45.0,
    blurSigma: 20.0,
    tintColor: Color(0x24FFB300),
    borderWidth: 1.2,
    specularOpacity: 0.7,
    secondarySpecularOpacity: 0.45,
    noise: 4.0,
    fallbackColor: Color(0xEA2A2214),
  );
}
