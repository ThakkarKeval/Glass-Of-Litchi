import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flavour.dart';
import 'litchi_glass.dart';

/// A tactile, dewy glass button with spring-driven press physics and specular sheen.
class LitchiButton extends StatefulWidget {
  const LitchiButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.flavour = LitchiFlavour.juicy,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
    this.enableHaptics = true,
    this.enableBlur = true,
  });

  /// Action triggered when the button is tapped. If `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Content widget inside the button (e.g. [Text], [Row], or [Icon]).
  final Widget child;

  /// Aesthetic flavour preset. Defaults to [LitchiFlavour.juicy].
  final LitchiFlavour flavour;

  /// Corner radius for the button.
  final BorderRadiusGeometry borderRadius;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Whether to invoke light haptic feedback on tap down.
  final bool enableHaptics;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

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
          padding: widget.padding,
          enableBlur: widget.enableBlur,
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
