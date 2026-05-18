import 'package:flutter/material.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';

/// Encapsulates playground parameters for custom indicator setups.
class ConfigData {
  ConfigData({
    required this.label,
    required this.presetName,
    required this.rows,
    required this.cols,
    required this.radius,
    required this.gap,
    required this.shape,
    required this.color,
  });

  final String label;
  final String presetName;
  final int rows;
  final int cols;
  final double radius;
  final double gap;
  final DotShape shape;
  final Color color;
}
