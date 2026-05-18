/// Represents a frame-by-frame dot matrix animation sequence.
class CustomSequence {
  const CustomSequence({
    required this.name,
    required this.rows,
    required this.cols,
    required this.frames,
  });

  /// Name of the sequence/preset.
  final String name;

  /// Number of grid rows.
  final int rows;

  /// Number of grid columns.
  final int cols;

  /// A 3D list representation [frame][row][column] of active pixel dots.
  final List<List<List<bool>>> frames;

  /// Creates a copy of this sequence with an empty frames structure.
  factory CustomSequence.empty(String name, int rows, int cols) {
    final emptyFrame = List.generate(
      rows,
      (_) => List.generate(cols, (_) => false),
    );
    return CustomSequence(
      name: name,
      rows: rows,
      cols: cols,
      frames: [emptyFrame],
    );
  }
}
