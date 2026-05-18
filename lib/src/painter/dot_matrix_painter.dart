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
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Calculate the ideal grid dimensions based on absolute style values
    final totalGridWidth = style.gridWidth;
    final totalGridHeight = style.gridHeight;

    // 2. Calculate scale factor to fit the grid into the available size
    // We maintain aspect ratio by taking the minimum scale.
    final scaleFactor = (size.width / totalGridWidth).clamp(0.0, double.infinity);
    final scaleFactorY = (size.height / totalGridHeight).clamp(0.0, double.infinity);
    final finalScale = scaleFactor < scaleFactorY ? scaleFactor : scaleFactorY;

    // 3. Center the grid in the available space
    final offsetX = (size.width - totalGridWidth * finalScale) / 2;
    final offsetY = (size.height - totalGridHeight * finalScale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(finalScale);

    final dotRadius = style.dotRadius;
    final dotGap = style.dotGap;
    final dotDiameter = dotRadius * 2;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int row = 0; row < style.rows; row++) {
      for (int col = 0; col < style.columns; col++) {
        final dotState = frame(row, col, style.rows, style.columns, t);

        final opacity = dotState.opacity.clamp(0.0, 1.0);
        final scale = dotState.scale.clamp(0.0, 1.0);

        paint.color = style.enableColorLerp
            ? Color.lerp(style.inactiveColor, style.activeColor, opacity)!
            : style.activeColor.withValues(alpha: opacity);

        // Calculate absolute center position
        final cx = dotRadius + col * (dotDiameter + dotGap);
        final cy = dotRadius + row * (dotDiameter + dotGap);

        final currentRadius = dotRadius * scale;

        if (style.dotShape == DotShape.circle) {
          canvas.drawCircle(Offset(cx, cy), currentRadius, paint);
        } else {
          final rect = Rect.fromCenter(
            center: Offset(cx, cy),
            width: currentRadius * 2,
            height: currentRadius * 2,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(currentRadius * 0.18)),
            paint,
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DotMatrixPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.style != style ||
      oldDelegate.frame != frame; // was comparing oldDelegate.frame to itself
}
