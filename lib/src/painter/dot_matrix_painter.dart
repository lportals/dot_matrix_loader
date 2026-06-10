import 'dart:math' as math;
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

        double opacity = dotState.opacity.clamp(0.0, 1.0);
        double scale = dotState.scale.clamp(0.0, 1.0);

        if (style.enableTrail) {
          const trailSteps = 5;
          const decayFactor = 0.65;
          const timeStep = 0.05;
          for (int i = 1; i <= trailSteps; i++) {
            final rawTPrev = t - i * timeStep;
            final tPrev = rawTPrev < 0 ? rawTPrev + 1.0 : rawTPrev;
            final prevDotState = frame(row, col, style.rows, style.columns, tPrev);
            final prevOpacity = prevDotState.opacity.clamp(0.0, 1.0) * math.pow(decayFactor, i);
            if (prevOpacity > opacity) {
              opacity = prevOpacity;
              scale = math.max(scale, prevDotState.scale.clamp(0.0, 1.0) * math.pow(decayFactor, i));
            }
          }
        }

        final dotColor = style.enableColorLerp
            ? Color.lerp(style.inactiveColor, style.activeColor, opacity)!
            : style.activeColor.withValues(alpha: opacity);

        // Calculate absolute center position
        final cx = dotRadius + col * (dotDiameter + dotGap);
        final cy = dotRadius + row * (dotDiameter + dotGap);

        // Draw background inactive dot first (representing physical off-state)
        // so the panel grid structure remains visible.
        if (style.inactiveColor.a > 0.0) {
          final bgPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = style.inactiveColor;
          if (style.dotShape == DotShape.circle) {
            canvas.drawCircle(Offset(cx, cy), dotRadius, bgPaint);
          } else {
            final rect = Rect.fromCenter(
              center: Offset(cx, cy),
              width: dotRadius * 2,
              height: dotRadius * 2,
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, Radius.circular(dotRadius * 0.18)),
              bgPaint,
            );
          }
        }

        final currentRadius = dotRadius * scale;

        // Draw soft glow first if enabled
        if (style.enableGlow && opacity > 0.05) {
          final glowPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = dotColor.withValues(alpha: opacity * 0.25)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, dotRadius * 0.8);

          if (style.dotShape == DotShape.circle) {
            canvas.drawCircle(Offset(cx, cy), currentRadius * 1.4, glowPaint);
          } else {
            final rect = Rect.fromCenter(
              center: Offset(cx, cy),
              width: currentRadius * 2.8,
              height: currentRadius * 2.8,
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, Radius.circular(currentRadius * 0.25)),
              glowPaint,
            );
          }
        }

        // Draw the main dot on top
        paint.color = dotColor;
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
