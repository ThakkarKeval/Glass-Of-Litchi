import 'package:flutter/material.dart';

/// Pre-configured styling flavours for [LitchiGlass] and [LitchiCard].
///
/// Instead of tweaking dozens of low-level blur and gradient parameters,
/// [LitchiFlavour] offers organic, fruit-inspired glass aesthetics.
class LitchiFlavour {
  const LitchiFlavour({
    required this.name,
    this.blurSigma = 16.0,
    this.tintColor = const Color(0x1AFFFFFF),
    this.borderGradient,
    this.borderWidth = 1.2,
    this.innerSheen = true,
    this.specularOpacity = 0.45,
    this.fallbackColor = const Color(0xCC1E1E24),
  });

  /// The descriptive name of the flavour.
  final String name;

  /// Gaussian blur intensity (sigmaX and sigmaY).
  final double blurSigma;

  /// Translucent tint color applied over the backdrop.
  final Color tintColor;

  /// Specular gradient applied to the outer rim border.
  final Gradient? borderGradient;

  /// Thickness of the outer glass rim border.
  final double borderWidth;

  /// Whether to render a subtle ambient light sheen from the top edge.
  final bool innerSheen;

  /// Opacity of the specular highlight sheen (0.0 to 1.0).
  final double specularOpacity;

  /// Solid or semi-opaque fallback color when blur is disabled (e.g. on low-end devices).
  final Color fallbackColor;

  /// Creates a copy of this flavour with the given fields replaced.
  LitchiFlavour copyWith({
    String? name,
    double? blurSigma,
    Color? tintColor,
    Gradient? borderGradient,
    double? borderWidth,
    bool? innerSheen,
    double? specularOpacity,
    Color? fallbackColor,
  }) {
    return LitchiFlavour(
      name: name ?? this.name,
      blurSigma: blurSigma ?? this.blurSigma,
      tintColor: tintColor ?? this.tintColor,
      borderGradient: borderGradient ?? this.borderGradient,
      borderWidth: borderWidth ?? this.borderWidth,
      innerSheen: innerSheen ?? this.innerSheen,
      specularOpacity: specularOpacity ?? this.specularOpacity,
      fallbackColor: fallbackColor ?? this.fallbackColor,
    );
  }

  /// Fresh, crisp morning dew with high translucency and subtle white sheen.
  static const LitchiFlavour dewy = LitchiFlavour(
    name: 'Dewy',
    blurSigma: 18.0,
    tintColor: Color(0x18FFFFFF),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x80FFFFFF),
        Color(0x1AFFFFFF),
        Color(0x05FFFFFF),
        Color(0x40FFFFFF),
      ],
      stops: [0.0, 0.4, 0.7, 1.0],
    ),
    borderWidth: 1.2,
    specularOpacity: 0.5,
    fallbackColor: Color(0xD91E1E26),
  );

  /// Vibrant, succulent lychee fruit tint with soft pink ambient warmth.
  static const LitchiFlavour juicy = LitchiFlavour(
    name: 'Juicy',
    blurSigma: 22.0,
    tintColor: Color(0x2BFF537A),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x99FFA3B8),
        Color(0x33FF6584),
        Color(0x15FFFFFF),
        Color(0x66FFA3B8),
      ],
      stops: [0.0, 0.35, 0.75, 1.0],
    ),
    borderWidth: 1.4,
    specularOpacity: 0.6,
    fallbackColor: Color(0xEB2A1820),
  );

  /// Velvety, frosted glass with a milky, smooth dispersion and muted edges.
  static const LitchiFlavour frosted = LitchiFlavour(
    name: 'Frosted',
    blurSigma: 30.0,
    tintColor: Color(0x33FFFFFF),
    borderGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x66FFFFFF),
        Color(0x14FFFFFF),
      ],
    ),
    borderWidth: 1.0,
    specularOpacity: 0.35,
    fallbackColor: Color(0xEE252530),
  );

  /// Ultra-clear optical crystal with razor-sharp specular rim and minimal diffusion.
  static const LitchiFlavour crystal = LitchiFlavour(
    name: 'Crystal',
    blurSigma: 10.0,
    tintColor: Color(0x0DFFFFFF),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xB3FFFFFF),
        Color(0x1FFFFFFF),
        Color(0x0AFFFFFF),
        Color(0x80FFFFFF),
      ],
    ),
    borderWidth: 1.5,
    specularOpacity: 0.7,
    fallbackColor: Color(0xCC1A1A22),
  );

  /// Creamy, sweet lychee dessert aesthetic with soft milky undertones.
  static const LitchiFlavour milkyLitchi = LitchiFlavour(
    name: 'Milky Litchi',
    blurSigma: 26.0,
    tintColor: Color(0x36FFF0F4),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x99FFFFFF),
        Color(0x33FFCCD8),
        Color(0x1AFFFFFF),
        Color(0x66FFFFFF),
      ],
    ),
    borderWidth: 1.3,
    specularOpacity: 0.55,
    fallbackColor: Color(0xEE2A1E24),
  );

  /// Romantic, dusky rose petal glass with a delicate blush glow.
  static const LitchiFlavour roseTint = LitchiFlavour(
    name: 'Rose Tint',
    blurSigma: 20.0,
    tintColor: Color(0x28E05688),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x8CF48FB1),
        Color(0x26AD1457),
        Color(0x10FFFFFF),
        Color(0x66F48FB1),
      ],
    ),
    borderWidth: 1.2,
    specularOpacity: 0.5,
    fallbackColor: Color(0xEA2A1522),
  );

  /// Warm, sunset-kissed citrus glaze with golden nectar accents.
  static const LitchiFlavour goldenCitrus = LitchiFlavour(
    name: 'Golden Citrus',
    blurSigma: 20.0,
    tintColor: Color(0x24FFB300),
    borderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x99FFE082),
        Color(0x2BFF8F00),
        Color(0x15FFFFFF),
        Color(0x66FFE082),
      ],
    ),
    borderWidth: 1.2,
    specularOpacity: 0.55,
    fallbackColor: Color(0xEA2A2214),
  );
}
