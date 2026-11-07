import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Precomputed path parameters for a single squircle corner based on Figma's
/// mathematical derivation (cubic Bézier ramp-up, circular arc, cubic Bézier ramp-down).
class _CornerPathParams {
  final double a;
  final double b;
  final double c;
  final double d;
  final double p;
  final double arcMeasure;
  final double r;

  const _CornerPathParams({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.p,
    required this.arcMeasure,
    required this.r,
  });

  static _CornerPathParams compute({
    required double radius,
    required double smoothing,
    required double budget,
  }) {
    if (radius <= 0.0 || budget <= 0.0) {
      return const _CornerPathParams(
        a: 0.0,
        b: 0.0,
        c: 0.0,
        d: 0.0,
        p: 0.0,
        arcMeasure: 0.0,
        r: 0.0,
      );
    }

    final clampedRadius = math.min(radius, budget);
    final maxSmoothing = clampedRadius > 0
        ? (budget / clampedRadius - 1.0).clamp(0.0, 1.0)
        : 0.0;
    final s = math.min(smoothing, maxSmoothing).clamp(0.0, 1.0);

    final p = math.min((1.0 + s) * clampedRadius, budget);
    final arcMeasure = 90.0 * (1.0 - s);
    final arcSectionLength =
        math.sin((arcMeasure / 2.0) * math.pi / 180.0) *
        clampedRadius *
        math.sqrt2;
    final angleAlpha = (90.0 - arcMeasure) / 2.0;

    final p3ToP4Distance =
        clampedRadius * math.tan((angleAlpha / 2.0) * math.pi / 180.0);
    final angleBeta = 45.0 * s;

    final c = p3ToP4Distance * math.cos(angleBeta * math.pi / 180.0);
    final d = c * math.tan(angleBeta * math.pi / 180.0);
    final b = (p - arcSectionLength - c - d) / 3.0;
    final a = 2.0 * b;

    return _CornerPathParams(
      a: a,
      b: b,
      c: c,
      d: d,
      p: p,
      arcMeasure: arcMeasure,
      r: clampedRadius,
    );
  }
}

/// Generates a smooth, continuous curvature (superellipse / squircle) [Path]
/// matching Apple iOS and Figma continuous corner curvature (G2 continuity).
///
/// Implements the exact 3-segment piecewise geometry (entry cubic Bézier,
/// central circular arc, exit cubic Bézier) formalised by Figma and Apple:
/// - When [smoothing] is `0.0`, the path reduces identically to a standard circular [RRect].
/// - When [smoothing] is `0.6` (the default), it produces the exact continuous curvature
///   seen in Apple iOS and visionOS system glass surfaces.
/// - When [smoothing] is `1.0`, the circular arc smoothly reduces to zero, forming a
///   pure continuous Bézier curve without any curvature discontinuity.
class SquirclePath {
  const SquirclePath._();

  static final Map<int, Path> _cache = {};
  static const int _maxCacheEntries = 128;

  /// Creates a continuous squircle [Path] for the given [rect], [borderRadius],
  /// and [smoothing] (0.0 to 1.0).
  ///
  /// Results are memoized in an internal cache to avoid recomputing cubic
  /// Bézier equations during 120 FPS animations and scrolling.
  static Path create({
    required Rect rect,
    required BorderRadius borderRadius,
    double smoothing = 0.6,
  }) {
    final clampedSmoothing = smoothing.clamp(0.0, 1.0);

    if (clampedSmoothing <= 0.0) {
      final path = Path();
      path.addRRect(borderRadius.toRRect(rect));
      return path;
    }

    final key = Object.hash(
      (rect.left * 10).round(),
      (rect.top * 10).round(),
      (rect.width * 10).round(),
      (rect.height * 10).round(),
      (borderRadius.topLeft.x * 10).round(),
      (borderRadius.topRight.x * 10).round(),
      (borderRadius.bottomRight.x * 10).round(),
      (borderRadius.bottomLeft.x * 10).round(),
      (clampedSmoothing * 100).round(),
    );

    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final width = rect.width;
    final height = rect.height;
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    final maxBudget = math.min(width, height) / 2.0;

    final tr = _CornerPathParams.compute(
      radius: borderRadius.topRight.x,
      smoothing: clampedSmoothing,
      budget: maxBudget,
    );
    final br = _CornerPathParams.compute(
      radius: borderRadius.bottomRight.x,
      smoothing: clampedSmoothing,
      budget: maxBudget,
    );
    final bl = _CornerPathParams.compute(
      radius: borderRadius.bottomLeft.x,
      smoothing: clampedSmoothing,
      budget: maxBudget,
    );
    final tl = _CornerPathParams.compute(
      radius: borderRadius.topLeft.x,
      smoothing: clampedSmoothing,
      budget: maxBudget,
    );

    final path = Path();

    // Start on top edge at beginning of Top-Right corner transition
    path.moveTo(right - tr.p, top);

    // --- TOP-RIGHT CORNER ---
    if (tr.r > 0.0) {
      path.cubicTo(
        right - tr.p + tr.a,
        top,
        right - tr.p + tr.a + tr.b,
        top,
        right - tr.p + tr.a + tr.b + tr.c,
        top + tr.d,
      );
      if (tr.arcMeasure > 0.001) {
        path.arcToPoint(
          Offset(right - tr.d, top + tr.p - tr.a - tr.b - tr.c),
          radius: Radius.circular(tr.r),
        );
      }
      path.cubicTo(
        right,
        top + tr.p - tr.a - tr.b,
        right,
        top + tr.p - tr.a,
        right,
        top + tr.p,
      );
    } else {
      path.lineTo(right, top);
    }

    // Right edge
    path.lineTo(right, bottom - br.p);

    // --- BOTTOM-RIGHT CORNER ---
    if (br.r > 0.0) {
      path.cubicTo(
        right,
        bottom - br.p + br.a,
        right,
        bottom - br.p + br.a + br.b,
        right - br.d,
        bottom - br.p + br.a + br.b + br.c,
      );
      if (br.arcMeasure > 0.001) {
        path.arcToPoint(
          Offset(right - br.p + br.a + br.b + br.c, bottom - br.d),
          radius: Radius.circular(br.r),
        );
      }
      path.cubicTo(
        right - br.p + br.a + br.b,
        bottom,
        right - br.p + br.a,
        bottom,
        right - br.p,
        bottom,
      );
    } else {
      path.lineTo(right, bottom);
    }

    // Bottom edge
    path.lineTo(left + bl.p, bottom);

    // --- BOTTOM-LEFT CORNER ---
    if (bl.r > 0.0) {
      path.cubicTo(
        left + bl.p - bl.a,
        bottom,
        left + bl.p - bl.a - bl.b,
        bottom,
        left + bl.p - bl.a - bl.b - bl.c,
        bottom - bl.d,
      );
      if (bl.arcMeasure > 0.001) {
        path.arcToPoint(
          Offset(left + bl.d, bottom - bl.p + bl.a + bl.b + bl.c),
          radius: Radius.circular(bl.r),
        );
      }
      path.cubicTo(
        left,
        bottom - bl.p + bl.a + bl.b,
        left,
        bottom - bl.p + bl.a,
        left,
        bottom - bl.p,
      );
    } else {
      path.lineTo(left, bottom);
    }

    // Left edge
    path.lineTo(left, top + tl.p);

    // --- TOP-LEFT CORNER ---
    if (tl.r > 0.0) {
      path.cubicTo(
        left,
        top + tl.p - tl.a,
        left,
        top + tl.p - tl.a - tl.b,
        left + tl.d,
        top + tl.p - tl.a - tl.b - tl.c,
      );
      if (tl.arcMeasure > 0.001) {
        path.arcToPoint(
          Offset(left + tl.p - tl.a - tl.b - tl.c, top + tl.d),
          radius: Radius.circular(tl.r),
        );
      }
      path.cubicTo(
        left + tl.p - tl.a - tl.b,
        top,
        left + tl.p - tl.a,
        top,
        left + tl.p,
        top,
      );
    } else {
      path.lineTo(left, top);
    }

    path.close();

    if (_cache.length >= _maxCacheEntries) {
      // Evict the oldest entry instead of wiping the whole cache, so a single
      // continuously-animating consumer (e.g. a sliding tab pill) doesn't
      // repeatedly blow away unrelated cached shapes every frame.
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = path;

    return path;
  }
}

/// Custom clipper that clips widgets along an authentic Figma / Apple squircle path.
class SquircleClipper extends CustomClipper<Path> {
  const SquircleClipper({required this.borderRadius, this.smoothing = 0.6});

  final BorderRadius borderRadius;
  final double smoothing;

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    return SquirclePath.create(
      rect: rect,
      borderRadius: borderRadius,
      smoothing: smoothing,
    );
  }

  @override
  bool shouldReclip(covariant SquircleClipper oldClipper) {
    return oldClipper.borderRadius != borderRadius ||
        oldClipper.smoothing != smoothing;
  }
}
