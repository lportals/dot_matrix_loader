import 'package:flutter/material.dart';

/// The shape of each individual dot in the matrix grid.
enum DotShape {
  /// A perfect circle dot.
  circle,

  /// A square dot with rounded corners.
  roundedSquare,
}

/// Visual configuration for the [DotMatrixLoader] widget.
///
/// All properties that affect appearance and timing live here.
/// Use [copyWith] to derive modified instances without mutation.
class DotMatrixStyle {
  /// Creates a [DotMatrixStyle] with sensible defaults.
  const DotMatrixStyle({
    this.columns = 5,
    this.rows = 5,
    this.dotRadius = 5.0,
    this.dotGap = 6.0,
    this.activeColor = const Color(0xFFE53935),
    this.inactiveColor = const Color(0xFF252525),
    this.dotShape = DotShape.circle,
    this.speed = 1.0,
    this.enableColorLerp = true,
    this.enableHaptics = false,
    this.loop = true,
    this.loopPause = Duration.zero,
  });

  /// Number of dot columns in the grid.
  final int columns;

  /// Number of dot rows in the grid.
  final int rows;

  /// Radius of each dot in logical pixels.
  ///
  /// For [DotShape.roundedSquare] this is the corner radius;
  /// the dot size is derived from [dotRadius] × 2.
  final double dotRadius;

  /// Gap between adjacent dots in logical pixels.
  final double dotGap;

  /// The color of a fully active (opacity = 1.0) dot.
  final Color activeColor;

  /// The color of a fully inactive (opacity = 0.0) dot.
  ///
  /// Only used when [enableColorLerp] is true; otherwise the dot is
  /// simply drawn with [activeColor] at a lower opacity.
  final Color inactiveColor;

  /// The visual shape of each dot.
  final DotShape dotShape;

  /// Animation playback speed multiplier.
  ///
  /// 1.0 = normal speed (1 200 ms per loop cycle).
  /// 2.0 = twice as fast, 0.5 = half speed.
  final double speed;

  /// When true, each dot's paint color is lerped from [inactiveColor]
  /// to [activeColor] based on its local animation progress.
  ///
  /// When false, dots are painted with [activeColor] at varying opacity.
  final bool enableColorLerp;

  /// Whether to trigger a haptic pulse at the end of each loop.
  ///
  /// Defaults to false — loaders are typically passive feedback elements.
  final bool enableHaptics;

  /// Whether the animation loops indefinitely.
  final bool loop;

  /// Pause duration inserted between loop iterations.
  final Duration loopPause;

  /// Returns the total pixel width of the dot grid.
  double get gridWidth =>
      (columns * dotRadius * 2) + ((columns - 1) * dotGap);

  /// Returns the total pixel height of the dot grid.
  double get gridHeight => (rows * dotRadius * 2) + ((rows - 1) * dotGap);

  /// Creates a copy of this style with the provided fields replaced.
  DotMatrixStyle copyWith({
    int? columns,
    int? rows,
    double? dotRadius,
    double? dotGap,
    Color? activeColor,
    Color? inactiveColor,
    DotShape? dotShape,
    double? speed,
    bool? enableColorLerp,
    bool? enableHaptics,
    bool? loop,
    Duration? loopPause,
  }) {
    return DotMatrixStyle(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      dotRadius: dotRadius ?? this.dotRadius,
      dotGap: dotGap ?? this.dotGap,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      dotShape: dotShape ?? this.dotShape,
      speed: speed ?? this.speed,
      enableColorLerp: enableColorLerp ?? this.enableColorLerp,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      loop: loop ?? this.loop,
      loopPause: loopPause ?? this.loopPause,
    );
  }
}
