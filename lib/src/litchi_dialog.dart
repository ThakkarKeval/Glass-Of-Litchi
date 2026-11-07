import 'dart:ui';

import 'package:flutter/material.dart';

import 'flavour.dart';
import 'litchi_card.dart';
import 'litchi_glass.dart';

/// A drop-in, frosted glass alert dialog with Apple continuous squircle curvature
/// and fruit-toned presets.
class LitchiDialog extends StatelessWidget {
  const LitchiDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.flavour = LitchiFlavour.frosted,
    this.borderRadius = const BorderRadius.all(Radius.circular(28.0)),
    this.cornerSmoothing = 0.6,
    this.padding = const EdgeInsets.all(24.0),
    this.maxWidth = 400.0,
    this.lightAngle,
    this.elevation = 16.0,
  });

  /// Optional title widget displayed at the top of the dialog.
  final Widget? title;

  /// Optional body content displayed in the center of the dialog.
  final Widget? content;

  /// Optional list of action widgets (e.g. [LitchiButton]s) displayed at the bottom.
  final List<Widget>? actions;

  /// Aesthetic flavour preset. Defaults to [LitchiFlavour.frosted].
  final LitchiFlavour flavour;

  /// Corner radius of the dialog box.
  final BorderRadiusGeometry borderRadius;

  /// Apple continuous squircle curvature factor (0.0 to 1.0, default: 0.6).
  final double cornerSmoothing;

  /// Inner padding around the dialog contents.
  final EdgeInsetsGeometry padding;

  /// Maximum layout width of the dialog.
  final double maxWidth;

  /// Incident light angle in degrees.
  final double? lightAngle;

  /// Ambient drop shadow elevation radius.
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LitchiCard(
          flavour: flavour,
          borderRadius: borderRadius,
          cornerSmoothing: cornerSmoothing,
          padding: padding,
          lightAngle: lightAngle,
          elevation: elevation,
          enableInteractiveFeedback: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  child: title!,
                ),
                const SizedBox(height: 12.0),
              ],
              if (content != null) ...[
                DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    height: 1.45,
                  ),
                  child: content!,
                ),
                const SizedBox(height: 20.0),
              ],
              if (actions != null && actions!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8.0),
                      actions![i],
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays an animated, frosted glass dialog above the current contents of the app.
///
/// Features a blurred scrim barrier and spring scale animation.
Future<T?> showLitchiDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0x66000000),
  double barrierBlur = 8.0,
  Duration transitionDuration = const Duration(milliseconds: 260),
  RouteTransitionsBuilder? transitionBuilder,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    pageBuilder: (buildContext, animation, secondaryAnimation) {
      final child = builder(buildContext);
      if (barrierBlur > 0.0) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: barrierBlur, sigmaY: barrierBlur),
          child: child,
        );
      }
      return child;
    },
    transitionBuilder: transitionBuilder ??
        (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
  );
}

/// Displays an animated, dewy frosted glass modal bottom sheet with squircle top corners.
Future<T?> showLitchiModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  LitchiFlavour flavour = LitchiFlavour.frosted,
  BorderRadiusGeometry borderRadius = const BorderRadius.vertical(
    top: Radius.circular(32.0),
  ),
  double cornerSmoothing = 0.6,
  double barrierBlur = 6.0,
  Color barrierColor = const Color(0x55000000),
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: barrierColor,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    isScrollControlled: true,
    builder: (context) {
      final content = builder(context);

      Widget sheet = LitchiGlass(
        flavour: flavour,
        borderRadius: borderRadius,
        cornerSmoothing: cornerSmoothing,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 10.0),
              Container(
                width: 38.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
              const SizedBox(height: 8.0),
              Flexible(child: content),
            ],
          ),
        ),
      );

      if (barrierBlur > 0.0) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: barrierBlur, sigmaY: barrierBlur),
          child: sheet,
        );
      }

      return sheet;
    },
  );
}
