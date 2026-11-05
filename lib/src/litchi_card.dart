import 'package:flutter/material.dart';

import 'flavour.dart';
import 'litchi_glass.dart';

/// A drop-in, highly polished glass card component with Apple squircle curvature
/// and spring-driven tactile touch-flex physics.
///
/// Supports direct 1:1 mapping with Figma Glass effect parameters:
/// [lightAngle], [lightPercent], [refraction], [depth], [dispersion], [frost], [splay], [cornerSmoothing].
class LitchiCard extends StatefulWidget {
  const LitchiCard({
    super.key,
    required this.child,
    this.flavour = LitchiFlavour.dewy,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.cornerSmoothing = 0.6,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.width,
    this.height,
    this.blur,
    this.tint,
    this.lightAngle,
    this.lightPercent,
    this.refraction,
    this.depth,
    this.dispersion,
    this.frost,
    this.splay,
    this.specularOpacity,
    this.secondarySpecularOpacity,
    this.onTap,
    this.elevation = 8.0,
    this.shadowColor,
    this.enableInteractiveFeedback = true,
    this.enableBlur = true,
  });

  /// Factory constructor to instantiate a [LitchiCard] directly from Figma Glass effect properties.
  factory LitchiCard.fromFigma({
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
    EdgeInsetsGeometry padding = const EdgeInsets.all(20.0),
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    Color? shadowColor,
    bool enableInteractiveFeedback = true,
    bool enableBlur = true,
  }) {
    return LitchiCard(
      key: key,
      borderRadius: borderRadius,
      cornerSmoothing: cornerSmoothing,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      lightAngle: lightAngle,
      lightPercent: lightPercent,
      refraction: refraction,
      depth: depth,
      dispersion: dispersion,
      frost: frost,
      splay: splay,
      tint: tintColor,
      elevation: depth * 1.2,
      onTap: onTap,
      shadowColor: shadowColor,
      enableInteractiveFeedback: enableInteractiveFeedback,
      enableBlur: enableBlur,
      child: child,
    );
  }

  /// The content displayed inside the card.
  final Widget child;

  /// The preset styling flavour (e.g. [LitchiFlavour.juicy], [LitchiFlavour.frosted]).
  final LitchiFlavour flavour;

  /// Corner radius of the card.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous curvature squircle smoothing factor (0.0 to 1.0, default: 0.6).
  final double cornerSmoothing;

  /// Inner padding for the content.
  final EdgeInsetsGeometry padding;

  /// Outer margin surrounding the card and its ambient shadow.
  final EdgeInsetsGeometry? margin;

  /// Fixed width for the card.
  final double? width;

  /// Fixed height for the card.
  final double? height;

  /// Optional override for the blur sigma in pixels (if set, overrides [frost]).
  final double? blur;

  /// Optional override for the tint color.
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

  /// Optional override for the primary specular highlight opacity.
  final double? specularOpacity;

  /// Optional override for the secondary bounce specular highlight opacity.
  final double? secondarySpecularOpacity;

  /// Optional tap callback. If provided, the card becomes interactive.
  final VoidCallback? onTap;

  /// Ambient shadow elevation blur radius. Set to 0 to disable shadow.
  final double elevation;

  /// Custom shadow color. Defaults to a subtle ambient glow derived from the tint.
  final Color? shadowColor;

  /// Whether to play tactile spring touch-flex physics and tilt on press.
  final bool enableInteractiveFeedback;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

  @override
  State<LitchiCard> createState() => _LitchiCardState();
}

class _LitchiCardState extends State<LitchiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _springAnimation;
  Offset _touchLocalPosition = Offset.zero;
  Size _cardSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 320),
    );
    _springAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enableInteractiveFeedback) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        _cardSize = renderBox.size;
      }
      setState(() {
        _touchLocalPosition = details.localPosition;
      });
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null && widget.enableInteractiveFeedback) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null && widget.enableInteractiveFeedback) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAngle = widget.lightAngle ?? widget.flavour.lightAngle;
    final effectiveDepth = widget.depth ?? widget.flavour.depth;
    final effectiveElevation =
        widget.elevation > 0 ? widget.elevation : (effectiveDepth * 1.2);

    final effectiveShadowColor = widget.shadowColor ??
        widget.flavour.tintColor.withValues(
          alpha: (widget.flavour.tintColor.a * 0.75).clamp(0.04, 0.28),
        );

    // Directional shadow cast opposite to the light source
    final (shadowDir, _) = alignmentPairFromDegrees(effectiveAngle + 180.0);
    final shadowOffset = Offset(
      shadowDir.x * (effectiveElevation * 0.45),
      shadowDir.y * (effectiveElevation * 0.55),
    );

    final innerCard = Container(
      decoration: effectiveElevation > 0
          ? BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: [
                BoxShadow(
                  color: effectiveShadowColor,
                  blurRadius: effectiveElevation * 2.2,
                  offset: shadowOffset,
                  spreadRadius: -2.0,
                ),
              ],
            )
          : null,
      child: LitchiGlass(
        flavour: widget.flavour,
        borderRadius: widget.borderRadius,
        cornerSmoothing: widget.cornerSmoothing,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        blur: widget.blur,
        tint: widget.tint,
        lightAngle: widget.lightAngle,
        lightPercent: widget.lightPercent,
        refraction: widget.refraction,
        depth: widget.depth,
        dispersion: widget.dispersion,
        frost: widget.frost,
        splay: widget.splay,
        specularOpacity: widget.specularOpacity,
        secondarySpecularOpacity: widget.secondarySpecularOpacity,
        enableBlur: widget.enableBlur,
        child: widget.child,
      ),
    );

    Widget card = innerCard;

    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _springAnimation,
          builder: (context, child) {
            if (!widget.enableInteractiveFeedback) return child!;

            final t = _springAnimation.value;
            final cardWidth = _cardSize.width > 0
                ? _cardSize.width
                : (widget.width ?? 300.0);
            final cardHeight = _cardSize.height > 0
                ? _cardSize.height
                : (widget.height ?? 160.0);

            // Compute normalized relative touch position (-1.0 to 1.0)
            final nx = cardWidth > 0
                ? ((_touchLocalPosition.dx / cardWidth) * 2.0 - 1.0)
                    .clamp(-1.0, 1.0)
                : 0.0;
            final ny = cardHeight > 0
                ? ((_touchLocalPosition.dy / cardHeight) * 2.0 - 1.0)
                    .clamp(-1.0, 1.0)
                : 0.0;

            final s = 1.0 - (0.02 * t);
            // Subtle 3D perspective touch flex tilt
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-ny * 0.04 * t)
              ..rotateY(nx * 0.04 * t)
              ..scaleByDouble(s, s, 1.0, 1.0);

            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: innerCard,
        ),
      );
    }

    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    return card;
  }
}
