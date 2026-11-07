import 'package:flutter/material.dart';

import 'flavour.dart';
import 'litchi_glass.dart';

/// A dewy, organic glass text field with glowing specular focus rims
/// and Apple continuous squircle curvature.
///
/// Supports direct Figma Glass styling parameters, prefix/suffix widgets,
/// and smooth focus animations.
class LitchiTextField extends StatefulWidget {
  const LitchiTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.hintStyle,
    this.style,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.flavour = LitchiFlavour.dewy,
    this.focusedFlavour,
    this.borderRadius = const BorderRadius.all(Radius.circular(20.0)),
    this.cornerSmoothing = 0.6,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 13.0,
    ),
    this.lightAngle,
    this.lightPercent,
    this.refraction,
    this.depth,
    this.dispersion,
    this.frost,
    this.splay,
    this.noise,
    this.enableBlur = true,
    this.shaderRefraction = false,
  });

  /// Factory constructor to instantiate a [LitchiTextField] directly from Figma Glass properties.
  factory LitchiTextField.fromFigma({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? hintText,
    TextStyle? hintStyle,
    TextStyle? style,
    Widget? prefix,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool autofocus = false,
    double lightAngle = 135.0,
    double lightPercent = 75.0,
    double refraction = 20.0,
    double depth = 6.0,
    double dispersion = 20.0,
    double frost = 22.0,
    double splay = 40.0,
    double noise = 0.0,
    double cornerSmoothing = 0.6,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(20.0),
    ),
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 13.0,
    ),
    bool enableBlur = true,
    bool shaderRefraction = false,
  }) {
    return LitchiTextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      hintStyle: hintStyle,
      style: style,
      prefix: prefix,
      suffix: suffix,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      borderRadius: borderRadius,
      cornerSmoothing: cornerSmoothing,
      contentPadding: contentPadding,
      lightAngle: lightAngle,
      lightPercent: lightPercent,
      refraction: refraction,
      depth: depth,
      dispersion: dispersion,
      frost: frost,
      splay: splay,
      noise: noise,
      enableBlur: enableBlur,
      shaderRefraction: shaderRefraction,
    );
  }

  /// Text editing controller managing the input value.
  final TextEditingController? controller;

  /// Focus node controlling keyboard focus.
  final FocusNode? focusNode;

  /// Placeholder hint text displayed when the input is empty.
  final String? hintText;

  /// Optional style for the hint text.
  final TextStyle? hintStyle;

  /// Optional style for the entered text.
  final TextStyle? style;

  /// Widget placed before the input field (e.g. search icon).
  final Widget? prefix;

  /// Widget placed after the input field (e.g. clear button).
  final Widget? suffix;

  /// Whether to obscure text for password entry.
  final bool obscureText;

  /// The keyboard type (e.g. email, phone, number).
  final TextInputType? keyboardType;

  /// The keyboard action button (e.g. search, done, next).
  final TextInputAction? textInputAction;

  /// Callback invoked on text changes.
  final ValueChanged<String>? onChanged;

  /// Callback invoked when the user submits text from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Whether the text field is interactive.
  final bool enabled;

  /// Whether to autofocus this text field when mounted.
  final bool autofocus;

  /// Flavour preset when unfocused. Defaults to [LitchiFlavour.dewy].
  final LitchiFlavour flavour;

  /// Optional flavour preset when focused. Defaults to a brighter, glowing rim.
  final LitchiFlavour? focusedFlavour;

  /// Corner radius for the squircle text box.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous squircle curvature factor (0.0 to 1.0, default: 0.6).
  final double cornerSmoothing;

  /// Padding around the input text.
  final EdgeInsetsGeometry contentPadding;

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

  /// Optional override for the micro-surface roughness / film grain noise (0% to 100%).
  final double? noise;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

  /// Whether GPU fragment shader optical refraction is enabled.
  final bool shaderRefraction;

  @override
  State<LitchiTextField> createState() => _LitchiTextFieldState();
}

class _LitchiTextFieldState extends State<LitchiTextField> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _isFocused = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant LitchiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
        _ownsFocusNode = false;
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
      } else {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      }
      _isFocused = _focusNode.hasFocus;
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted && _isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFocusedFlavour = widget.focusedFlavour ??
        widget.flavour.copyWith(
          borderWidth: (widget.flavour.borderWidth * 1.5).clamp(1.5, 3.0),
          specularOpacity: 0.95,
          tintColor: widget.flavour.tintColor.withValues(
            alpha: (widget.flavour.tintColor.a * 1.35).clamp(0.12, 0.40),
          ),
        );

    final effectiveFlavour =
        _isFocused ? effectiveFocusedFlavour : widget.flavour;

    final defaultTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
    );

    final defaultHintStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.45),
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: LitchiGlass(
        flavour: effectiveFlavour,
        borderRadius: widget.borderRadius,
        cornerSmoothing: widget.cornerSmoothing,
        padding: widget.contentPadding,
        lightAngle: widget.lightAngle,
        lightPercent: widget.lightPercent,
        refraction: widget.refraction,
        depth: widget.depth,
        dispersion: widget.dispersion,
        frost: widget.frost,
        splay: widget.splay,
        noise: widget.noise,
        enableBlur: widget.enableBlur,
        shaderRefraction: widget.shaderRefraction,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.prefix != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 20.0,
                  color: _isFocused
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                ),
                child: widget.prefix!,
              ),
              const SizedBox(width: 10.0),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                style: widget.style ?? defaultTextStyle,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: widget.hintStyle ?? defaultHintStyle,
                ),
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: 10.0),
              IconTheme(
                data: IconThemeData(
                  size: 20.0,
                  color: _isFocused
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                ),
                child: widget.suffix!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
