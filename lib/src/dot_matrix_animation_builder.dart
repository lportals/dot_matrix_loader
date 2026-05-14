import 'package:flutter/material.dart';
import 'models/dot_matrix_style.dart';
import 'models/dot_matrix_preset.dart';
import 'dot_matrix_loader.dart';

/// Convenience widget for authoring and displaying custom dot-matrix animations.
///
/// Wraps [DotMatrixLoader] with a [CustomDotAnimation] preset so callers
/// can supply a [DotAnimationFrame] function directly without boilerplate.
///
/// ## Usage
/// ```dart
/// DotMatrixAnimationBuilder(
///   frame: (row, col, rows, cols, t) {
///     final delay = (row + col) / (rows + cols);
///     final localT = ((t - delay * 0.6).clamp(0.0, 1.0));
///     return DotState(opacity: localT, scale: 0.5 + 0.5 * localT);
///   },
///   style: DotMatrixStyle(
///     activeColor: Color(0xFFE53935),
///     rows: 7,
///     columns: 7,
///   ),
/// )
/// ```
class DotMatrixAnimationBuilder extends StatelessWidget {
  /// Creates a [DotMatrixAnimationBuilder].
  const DotMatrixAnimationBuilder({
    super.key,
    required this.frame,
    this.style = const DotMatrixStyle(),
    this.isActive = true,
    this.externalAnimation,
  });

  /// The delay-map function that drives per-dot animation state.
  final DotAnimationFrame frame;

  /// Visual configuration for the dot grid.
  final DotMatrixStyle style;

  /// Whether the animation is actively playing.
  final bool isActive;

  /// Optional shared [Animation] — see [DotMatrixLoader.externalAnimation].
  final Animation<double>? externalAnimation;

  @override
  Widget build(BuildContext context) {
    return DotMatrixLoader(
      preset: CustomDotAnimation(builder: frame),
      style: style,
      isActive: isActive,
      externalAnimation: externalAnimation,
    );
  }
}
