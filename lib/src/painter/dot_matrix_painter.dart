import 'package:flutter/material.dart';
import '../models/dot_matrix_style.dart';
import '../models/dot_matrix_preset.dart';

/// [CustomPainter] that renders the NxM dot-matrix grid each animation frame.
///
/// Delegates per-dot state resolution to a [DotAnimationFrame] function,
/// which is resolved once from the active [DotMatrixPreset] and cached.
class DotMatrixPainter extends CustomPainter {
  /// Creates a [DotMatrixPainter].
  const DotMatrixPainter({
    required this.frame,
    required this.style,
    required this.t,
  });

  /// The delay-map function resolved from the active preset.
  final DotAnimationFrame frame;

  /// Visual configuration controlling dot size, gap, colors, and shape.
  final DotMatrixStyle style;

  /// Normalized animation progress in [0.0, 1.0].
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final dotDiameter = style.dotRadius * 2;
    final cellSize = dotDiameter + style.dotGap;

    // Allocate a single Paint and mutate its color per dot — avoids
    // creating one object per dot per frame (e.g. 1 500 allocs/s on 5×5@60fps).
    final paint = Paint()..style = PaintingStyle.fill;

    for (int row = 0; row < style.rows; row++) {
      for (int col = 0; col < style.columns; col++) {
        final dotState = frame(row, col, style.rows, style.columns, t);

        final opacity = dotState.opacity.clamp(0.0, 1.0);
        final scale = dotState.scale.clamp(0.0, 1.0);

        // Resolve paint color and mutate the shared Paint in-place.
        paint.color = style.enableColorLerp
            ? Color.lerp(style.inactiveColor, style.activeColor, opacity)!
            : style.activeColor.withValues(alpha: opacity);

        // Center of this dot in canvas coordinates.
        final cx = col * cellSize + style.dotRadius;
        final cy = row * cellSize + style.dotRadius;

        final scaledRadius = style.dotRadius * scale;

        if (style.dotShape == DotShape.circle) {
          canvas.drawCircle(Offset(cx, cy), scaledRadius, paint);
        } else {
          // Rounded square — corner radius is 35% of scaled radius.
          final rect = Rect.fromCenter(
            center: Offset(cx, cy),
            width: scaledRadius * 2,
            height: scaledRadius * 2,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(scaledRadius * 0.35)),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(DotMatrixPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.style != style ||
      oldDelegate.frame != frame; // was comparing oldDelegate.frame to itself
}
