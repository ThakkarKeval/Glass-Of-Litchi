import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A deep, celestial starry night sky background with twinkling stars,
/// 4-point diamond sparkles, and soft cosmic nebula glows.
///
/// Designed specifically to showcase physical glass refraction, chromatic
/// dispersion (splitting starlight along the squircle rim), and frosted diffusion.
class StarrySkyBackground extends StatelessWidget {
  const StarrySkyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _StarrySkyPainter()),
      ),
    );
  }
}

/// Backwards-compatible aliases.
typedef AmbientMeshBackground = StarrySkyBackground;
typedef ColorDotsBackground = StarrySkyBackground;

class _StarrySkyPainter extends CustomPainter {
  const _StarrySkyPainter();

  // Natural star tint palette
  static const _starColors = [
    Color(0xFFFFFFFF), // Pure brilliant white
    Color(0xFFE0F2FE), // Diamond ice blue
    Color(0xFFFEF9C3), // Warm stellar gold
    Color(0xFFFCE7F3), // Soft litchi rose starlight
    Color(0xFFE9D5FF), // Celestial violet
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Deep cosmic night sky gradient
    final spaceGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF040508),
        Color(0xFF080A12),
        Color(0xFF05060A),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = spaceGradient.createShader(rect));

    // 2. Distant cosmic nebula dust clouds (subtle, soft organic depth)
    // Rose-amber nebula (Top-right)
    final nebula1Center = Offset(size.width * 0.78, size.height * 0.22);
    final nebula1Radius = size.width * 0.70;
    canvas.drawCircle(
      nebula1Center,
      nebula1Radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF6B1D42).withValues(alpha: 0.22),
            const Color(0xFF3B1028).withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(
          Rect.fromCircle(center: nebula1Center, radius: nebula1Radius),
        ),
    );

    // Deep sapphire-indigo nebula (Bottom-left)
    final nebula2Center = Offset(size.width * 0.20, size.height * 0.72);
    final nebula2Radius = size.width * 0.75;
    canvas.drawCircle(
      nebula2Center,
      nebula2Radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1E1B4B).withValues(alpha: 0.32),
            const Color(0xFF0F172A).withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: nebula2Center, radius: nebula2Radius),
        ),
    );

    // 3. Faint constellation guide lines
    final constLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8;

    final p1 = Offset(size.width * 0.18, size.height * 0.14);
    final p2 = Offset(size.width * 0.38, size.height * 0.19);
    final p3 = Offset(size.width * 0.52, size.height * 0.12);
    final p4 = Offset(size.width * 0.74, size.height * 0.15);
    canvas.drawLine(p1, p2, constLinePaint);
    canvas.drawLine(p2, p3, constLinePaint);
    canvas.drawLine(p3, p4, constLinePaint);

    final p5 = Offset(size.width * 0.22, size.height * 0.82);
    final p6 = Offset(size.width * 0.44, size.height * 0.76);
    final p7 = Offset(size.width * 0.68, size.height * 0.84);
    canvas.drawLine(p5, p6, constLinePaint);
    canvas.drawLine(p6, p7, constLinePaint);

    // 4. Stable, deterministic starry sky
    // Grid-based distribution ensures even coverage across any device aspect ratio
    final random = math.Random(1337);
    const cellSize = 38.0;
    final rows = (size.height / cellSize).ceil();
    final cols = (size.width / cellSize).ceil();

    final starPaint = Paint();
    final haloPaint = Paint();
    final sparklePaint = Paint()..strokeWidth = 1.0;

    for (int r = 0; r <= rows; r++) {
      for (int c = 0; c <= cols; c++) {
        // Skip some cells naturally for varied galactic density
        if (random.nextDouble() > 0.72) continue;

        final cx = c * cellSize + (random.nextDouble() - 0.5) * (cellSize * 0.85);
        final cy = r * cellSize + (random.nextDouble() - 0.5) * (cellSize * 0.85);
        final starPos = Offset(cx, cy);

        final starColor = _starColors[random.nextInt(_starColors.length)];
        final brightness = random.nextDouble();

        if (brightness > 0.93) {
          // Brilliant 4-Point Diamond Sparkle Star
          final haloRadius = 4.0 + random.nextDouble() * 3.5;
          haloPaint.color = starColor.withValues(alpha: 0.22);
          canvas.drawCircle(starPos, haloRadius, haloPaint);

          // Star center core
          starPaint.color = Colors.white.withValues(alpha: 0.95);
          canvas.drawCircle(starPos, 1.6, starPaint);

          // 4-point cross diffraction spikes
          sparklePaint.color = starColor.withValues(alpha: 0.75);
          final rayLength = 5.0 + random.nextDouble() * 5.0;
          canvas.drawLine(
            Offset(starPos.dx - rayLength, starPos.dy),
            Offset(starPos.dx + rayLength, starPos.dy),
            sparklePaint,
          );
          canvas.drawLine(
            Offset(starPos.dx, starPos.dy - rayLength),
            Offset(starPos.dx, starPos.dy + rayLength),
            sparklePaint,
          );
        } else if (brightness > 0.65) {
          // Medium bright star with soft glow halo
          final haloRadius = 2.5 + random.nextDouble() * 2.0;
          haloPaint.color = starColor.withValues(alpha: 0.16);
          canvas.drawCircle(starPos, haloRadius, haloPaint);

          starPaint.color = starColor.withValues(
            alpha: 0.75 + random.nextDouble() * 0.20,
          );
          final starRadius = 1.1 + random.nextDouble() * 0.6;
          canvas.drawCircle(starPos, starRadius, starPaint);
        } else {
          // Distant pinprick star
          final alpha = 0.20 + random.nextDouble() * 0.55;
          starPaint.color = starColor.withValues(alpha: alpha);
          final starRadius = 0.6 + random.nextDouble() * 0.6;
          canvas.drawCircle(starPos, starRadius, starPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarrySkyPainter oldDelegate) => false;
}
