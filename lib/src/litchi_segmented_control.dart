import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flavour.dart';
import 'litchi_glass.dart';
import 'squircle.dart';

/// Represents a single option item in a [LitchiSegmentedControl].
class LitchiSegment<T> {
  const LitchiSegment({
    required this.value,
    required this.label,
    this.icon,
    this.badgeText,
  });

  /// The unique value identified by this segment.
  final T value;

  /// The label displayed on this segment.
  final Widget label;

  /// Optional icon displayed alongside the label.
  final Widget? icon;

  /// Optional badge text (e.g. 'NEW' or item count).
  final String? badgeText;
}

/// A signature horizontal glass segmented control featuring a sliding liquid
/// squircle indicator pill with spring physics.
///
/// Features Apple continuous curvature, tactile haptics, and fruit-toned presets.
class LitchiSegmentedControl<T> extends StatefulWidget {
  const LitchiSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onValueChanged,
    this.flavour = LitchiFlavour.dewy,
    this.pillFlavour,
    this.pillColor,
    this.pillBorderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(22.0)),
    this.cornerSmoothing = 0.6,
    this.height = 44.0,
    this.padding = const EdgeInsets.all(4.0),
    this.vibrancy,
    this.enableHaptics = true,
    this.enableBlur = true,
    this.shaderRefraction = false,
  }) : assert(segments.length >= 2, 'LitchiSegmentedControl requires at least 2 segments.');

  /// The list of segments available for selection.
  final List<LitchiSegment<T>> segments;

  /// The currently selected segment value.
  final T selectedValue;

  /// Callback invoked when the user selects a segment.
  final ValueChanged<T> onValueChanged;

  /// Aesthetic flavour preset for the background container. Defaults to [LitchiFlavour.dewy].
  final LitchiFlavour flavour;

  /// Optional flavour preset for the sliding selection pill. Defaults to [LitchiFlavour.juicy].
  final LitchiFlavour? pillFlavour;

  /// Custom fill color for the sliding selection pill (overrides flavour tint).
  final Color? pillColor;

  /// Custom border color for the sliding selection pill.
  final Color? pillBorderColor;

  /// Corner radius of the control and sliding pill.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous curvature squircle smoothing factor (0.0 to 1.0, default: 0.6).
  final double cornerSmoothing;

  /// Total height of the segmented control.
  final double height;

  /// Inner padding between the glass container and the segments.
  final EdgeInsetsGeometry padding;

  /// Whether to invoke selection haptic feedback on tab changes.
  final bool enableHaptics;

  /// Whether backdrop blur is enabled.
  final bool enableBlur;

  /// Optional override for background saturation vibrancy multiplier (e.g. 1.0 to 1.5).
  final double? vibrancy;

  /// Whether GPU fragment shader optical refraction is enabled.
  final bool shaderRefraction;

  @override
  State<LitchiSegmentedControl<T>> createState() =>
      _LitchiSegmentedControlState<T>();
}

class _LitchiSegmentedControlState<T> extends State<LitchiSegmentedControl<T>> {
  int get _selectedIndex {
    final idx = widget.segments.indexWhere((s) => s.value == widget.selectedValue);
    return idx >= 0 ? idx : 0;
  }

  void _onSegmentTapped(int index, T value) {
    if (value == widget.selectedValue) return;

    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    widget.onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final segmentCount = widget.segments.length;
    final activeIndex = _selectedIndex;
    final resolvedRadius = widget.borderRadius.resolve(Directionality.of(context));

    final effectivePillFlavour = widget.pillFlavour ?? LitchiFlavour.juicy;

    return LitchiGlass(
      flavour: widget.flavour,
      borderRadius: widget.borderRadius,
      cornerSmoothing: widget.cornerSmoothing,
      height: widget.height,
      padding: widget.padding,
      vibrancy: widget.vibrancy,
      enableBlur: widget.enableBlur,
      shaderRefraction: widget.shaderRefraction,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final segmentWidth = totalWidth / segmentCount;
          final pillHeight = constraints.maxHeight;

          // Inner radius slightly smaller for the nested pill
          final pillRadius = BorderRadius.circular(
            (resolvedRadius.topLeft.x - 3.0).clamp(4.0, 100.0),
          );

          return Stack(
            children: [
              // Sliding Liquid Squircle Selection Pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: activeIndex * segmentWidth,
                top: 0,
                width: segmentWidth,
                height: pillHeight,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: widget.cornerSmoothing > 0.0
                      ? ClipPath(
                          clipper: SquircleClipper(
                            borderRadius: pillRadius,
                            smoothing: widget.cornerSmoothing,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: widget.pillColor ??
                                  effectivePillFlavour.tintColor,
                              border: Border.all(
                                color: widget.pillBorderColor ??
                                    Colors.white.withValues(alpha: 0.65),
                                width: 1.0,
                              ),
                              borderRadius: pillRadius,
                            ),
                          ),
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.pillColor ??
                                effectivePillFlavour.tintColor,
                            border: Border.all(
                              color: widget.pillBorderColor ??
                                  Colors.white.withValues(alpha: 0.65),
                              width: 1.0,
                            ),
                            borderRadius: pillRadius,
                          ),
                        ),
                ),
              ),

              // Segment Items
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(segmentCount, (index) {
                  final segment = widget.segments[index];
                  final isSelected = index == activeIndex;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      child: GestureDetector(
                        onTap: () => _onSegmentTapped(index, segment.value),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (segment.icon != null) ...[
                                IconTheme(
                                  data: IconThemeData(
                                    size: 16.0,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white60,
                                  ),
                                  child: segment.icon!,
                                ),
                                const SizedBox(width: 6.0),
                              ],
                              DefaultTextStyle(
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 13.0,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  letterSpacing: 0.1,
                                ),
                                child: segment.label,
                              ),
                              if (segment.badgeText != null) ...[
                                const SizedBox(width: 5.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    segment.badgeText!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
