import 'package:dot_matrix_loader/dot_matrix_loader.dart';

/// Representation of a configured status indicator showcase item.
class StatusIndicatorExample {
  const StatusIndicatorExample({
    required this.name,
    required this.label,
    required this.activeText,
    required this.preset,
    required this.rows,
    required this.cols,
    required this.category,
    required this.description,
  });

  final String name;
  final String label;
  final String activeText;
  final DotMatrixPreset preset;
  final int rows;
  final int cols;
  final String category;
  final String description;
}
