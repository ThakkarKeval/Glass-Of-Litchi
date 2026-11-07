import 'package:flutter/material.dart';

import 'flavour.dart';
import 'litchi_glass.dart';
import 'squircle.dart';

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
    this.noise,
    this.specularOpacity,
    this.secondarySpecularOpacity,
    this.onTap,
    this.elevation = 8.0,
    this.shadowColor,
    this.enableInteractiveFeedback = true,
    this.enableDynamicLight = true,
    this.enableHoverEffect = true,
    this.enableBlur = true,
    this.shaderRefraction = false,
    this.groupBackdrop = false,
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
    double noise = 0.0,
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
    bool enableDynamicLight = true,
    bool enableHoverEffect = true,
    bool enableBlur = true,
    bool shaderRefraction = false,
    bool groupBackdrop = false,
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
      noise: noise,
      tint: tintColor,
      elevation: depth * 1.2,
      onTap: onTap,
      shadowColor: shadowColor,
      enableInteractiveFeedback: enableInteractiveFeedback,
      enableDynamicLight: enableDynamicLight,
      enableHoverEffect: enableHoverEffect,
      enableBlur: enableBlur,
      shaderRefraction: shaderRefraction,
      groupBackdrop: groupBackdrop,
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

  /// Optional override for the micro-surface roughness / film grain noise (0% to 100%).
  final double? noise;

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

  /// Whether dynamic lighting shimmers across the glass surface and rim as
  /// touch or cursor pointer position moves.
  final bool enableDynamicLight;

  /// Whether to track mouse hover movement on desktop and web to cast specular glints.
  final bool enableHoverEffect;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

  /// Whether GPU fragment shader optical refraction and dispersion are enabled.
  ///
  /// See [LitchiGlass.shaderRefraction] for a known limitation when this
  /// widget scrolls inside a `ListView`/`CustomScrollView`.
  final bool shaderRefraction;

  /// Opts blur-only glass into the nearest [BackdropGroup].
  /// Use only for non-overlapping peers; nested glass should remain ungrouped.
  /// Ignored while shader refraction is enabled.
  final bool groupBackdrop;

  @override
  State<LitchiCard> createState() => _LitchiCardState();
}

class _LitchiCardState extends State<LitchiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _springAnimation;
  Offset _touchLocalPosition = Offset.zero;
  Offset _hoverLocalPosition = Offset.zero;
  bool _isHovered = false;
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

  Widget _buildGlassPanel(
    BuildContext context, {
    required double lightAngle,
    required BorderRadius resolvedRadius,
    required double effectiveElevation,
    required Color effectiveShadowColor,
  }) {
    // Directional shadow cast opposite to the light source
    final (shadowDir, _) = alignmentPairFromDegrees(lightAngle + 180.0);
    final shadowOffset = Offset(
      shadowDir.x * (effectiveElevation * 0.45),
      shadowDir.y * (effectiveElevation * 0.55),
    );

    Widget innerCard = LitchiGlass(
      flavour: widget.flavour,
      borderRadius: widget.borderRadius,
      cornerSmoothing: widget.cornerSmoothing,
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      blur: widget.blur,
      tint: widget.tint,
      lightAngle: lightAngle,
      lightPercent: widget.lightPercent,
      refraction: widget.refraction,
      depth: widget.depth,
      dispersion: widget.dispersion,
      frost: widget.frost,
      splay: widget.splay,
      noise: widget.noise,
      specularOpacity: widget.specularOpacity,
      secondarySpecularOpacity: widget.secondarySpecularOpacity,
      enableBlur: widget.enableBlur,
      shaderRefraction: widget.shaderRefraction,
      groupBackdrop: widget.groupBackdrop,
      child: widget.child,
    );

    // Apply ambient drop shadow: excludes glass interior to avoid dark bleed-through
    if (effectiveElevation > 0) {
      innerCard = CustomPaint(
        painter: _SquircleShadowPainter(
          borderRadius: resolvedRadius,
          cornerSmoothing: widget.cornerSmoothing,
          shadowColor: effectiveShadowColor,
          blurRadius: effectiveElevation * 2.2,
          offset: shadowOffset,
        ),
        child: innerCard,
      );
    }

    return innerCard;
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

    final resolvedRadius =
        widget.borderRadius.resolve(Directionality.of(context));

    Widget card = AnimatedBuilder(
      animation: _springAnimation,
      builder: (context, _) {
        final t = _springAnimation.value;
        final isInteracting = t > 0.0 || _isHovered;
        final interactionT = t > 0.0 ? t : (_isHovered ? 0.65 : 0.0);

        final cardWidth = _cardSize.width > 0
            ? _cardSize.width
            : (widget.width ?? 300.0);
        final cardHeight = _cardSize.height > 0
            ? _cardSize.height
            : (widget.height ?? 160.0);

        final pos = t > 0.0 ? _touchLocalPosition : _hoverLocalPosition;
        final nx = cardWidth > 0
            ? ((pos.dx / cardWidth) * 2.0 - 1.0).clamp(-1.0, 1.0)
            : 0.0;
        final ny = cardHeight > 0
            ? ((pos.dy / cardHeight) * 2.0 - 1.0).clamp(-1.0, 1.0)
            : 0.0;

        final dynamicLightAngle =
            (widget.enableDynamicLight && isInteracting)
                ? (effectiveAngle + (nx * 26.0 - ny * 18.0) * interactionT)
                : effectiveAngle;

        final panel = _buildGlassPanel(
          context,
          lightAngle: dynamicLightAngle,
          resolvedRadius: resolvedRadius,
          effectiveElevation: effectiveElevation,
          effectiveShadowColor: effectiveShadowColor,
        );

        if (!widget.enableInteractiveFeedback && !_isHovered) {
          return panel;
        }

        final tiltFactor = t > 0.0 ? (0.04 * t) : (_isHovered ? 0.016 : 0.0);
        final s = 1.0 - (0.02 * t);
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-ny * tiltFactor)
          ..rotateY(nx * tiltFactor)
          ..scaleByDouble(s, s, 1.0, 1.0);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: panel,
        );
      },
    );

    if (widget.onTap != null) {
      card = Listener(
        onPointerDown: (event) {
          if (widget.enableInteractiveFeedback) {
            final renderBox = context.findRenderObject() as RenderBox?;
            if (renderBox != null && renderBox.hasSize) {
              _cardSize = renderBox.size;
            }
            setState(() {
              _touchLocalPosition = event.localPosition;
            });
            _controller.forward();
          }
        },
        onPointerMove: (event) {
          if (widget.enableInteractiveFeedback) {
            setState(() {
              _touchLocalPosition = event.localPosition;
            });
          }
        },
        onPointerUp: (_) {
          if (widget.enableInteractiveFeedback) {
            _controller.reverse();
          }
        },
        onPointerCancel: (_) {
          if (widget.enableInteractiveFeedback) {
            _controller.reverse();
          }
        },
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: card,
        ),
      );
    }

    if (widget.enableHoverEffect) {
      card = MouseRegion(
        onEnter: (event) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            _cardSize = renderBox.size;
          }
          setState(() {
            _isHovered = true;
            _hoverLocalPosition = event.localPosition;
          });
        },
        onHover: (event) {
          setState(() {
            _hoverLocalPosition = event.localPosition;
          });
        },
        onExit: (_) {
          if (_isHovered) {
            setState(() {
              _isHovered = false;
            });
          }
        },
        child: card,
      );
    }

    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    return card;
  }
}

/// Custom painter for rendering an ambient drop shadow that follows an authentic
/// Apple squircle silhouette instead of a standard circular rounded rectangle.
class _SquircleShadowPainter extends CustomPainter {
  const _SquircleShadowPainter({
    required this.borderRadius,
    required this.cornerSmoothing,
    required this.shadowColor,
    required this.blurRadius,
    required this.offset,
  });

  final BorderRadius borderRadius;
  final double cornerSmoothing;
  final Color shadowColor;
  final double blurRadius;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    if (blurRadius <= 0.0 || shadowColor.a <= 0.0) return;

    final cardRect = Offset.zero & size;
    final cardPath = SquirclePath.create(
      rect: cardRect,
      borderRadius: borderRadius,
      smoothing: cornerSmoothing,
    );

    final shadowRect = (offset & size).deflate(1.5);
    final shadowPath = SquirclePath.create(
      rect: shadowRect,
      borderRadius: borderRadius,
      smoothing: cornerSmoothing,
    );

    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    // Clip out the card interior so the drop shadow never bleeds through the translucent glass
    final outerClipRect = cardRect.inflate(blurRadius * 3.0 + offset.distance);
    final clipHolePath = Path.combine(
      PathOperation.difference,
      Path()..addRect(outerClipRect),
      cardPath,
    );

    canvas.save();
    canvas.clipPath(clipHolePath);
    canvas.drawPath(shadowPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SquircleShadowPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.cornerSmoothing != cornerSmoothing ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.blurRadius != blurRadius ||
        oldDelegate.offset != offset;
  }
}
