import 'package:flutter/material.dart';

import 'flavour.dart';
import 'litchi_glass.dart';

/// A drop-in, highly polished glass card component.
///
/// Provides ambient fruit-toned drop shadows, smooth interactive tap physics,
/// and dewy glass surfaces straight out of the box.
class LitchiCard extends StatefulWidget {
  const LitchiCard({
    super.key,
    required this.child,
    this.flavour = LitchiFlavour.dewy,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.width,
    this.height,
    this.blur,
    this.tint,
    this.onTap,
    this.elevation = 8.0,
    this.shadowColor,
    this.enableInteractiveFeedback = true,
    this.enableBlur = true,
  });

  /// The content displayed inside the card.
  final Widget child;

  /// The preset styling flavour (e.g. [LitchiFlavour.juicy], [LitchiFlavour.frosted]).
  final LitchiFlavour flavour;

  /// Corner radius of the card.
  final BorderRadiusGeometry borderRadius;

  /// Inner padding for the content.
  final EdgeInsetsGeometry padding;

  /// Outer margin surrounding the card and its ambient shadow.
  final EdgeInsetsGeometry? margin;

  /// Fixed width for the card.
  final double? width;

  /// Fixed height for the card.
  final double? height;

  /// Optional override for the blur sigma.
  final double? blur;

  /// Optional override for the tint color.
  final Color? tint;

  /// Optional tap callback. If provided, the card becomes interactive.
  final VoidCallback? onTap;

  /// Ambient shadow elevation blur radius. Set to 0 to disable shadow.
  final double elevation;

  /// Custom shadow color. Defaults to a subtle ambient glow derived from the tint.
  final Color? shadowColor;

  /// Whether to play a subtle press-down spring animation on tap.
  final bool enableInteractiveFeedback;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

  @override
  State<LitchiCard> createState() => _LitchiCardState();
}

class _LitchiCardState extends State<LitchiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enableInteractiveFeedback) {
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
    final effectiveShadowColor = widget.shadowColor ??
        widget.flavour.tintColor.withValues(
          alpha: (widget.flavour.tintColor.a * 0.7).clamp(0.04, 0.25),
        );

    Widget card = Container(
      decoration: widget.elevation > 0
          ? BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: [
                BoxShadow(
                  color: effectiveShadowColor,
                  blurRadius: widget.elevation * 2.0,
                  offset: Offset(0, widget.elevation * 0.5),
                  spreadRadius: -2.0,
                ),
              ],
            )
          : null,
      child: LitchiGlass(
        flavour: widget.flavour,
        borderRadius: widget.borderRadius,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        blur: widget.blur,
        tint: widget.tint,
        enableBlur: widget.enableBlur,
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: widget.enableInteractiveFeedback ? _scaleAnimation.value : 1.0,
            child: child,
          ),
          child: card,
        ),
      );
    }

    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    return card;
  }
}
