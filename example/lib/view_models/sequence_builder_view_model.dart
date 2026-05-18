import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../data/models/custom_sequence.dart';
import '../data/repositories/custom_sequence_repository.dart';

/// ViewModel managing stateful lists of animation frames, grids, timelines, and haptic exports.
class SequenceBuilderViewModel extends ChangeNotifier {
  SequenceBuilderViewModel({
    required Color defaultColor,
    CustomSequenceRepository? sequenceRepository,
  })  : _activeColor = defaultColor,
        _repository = sequenceRepository ?? CustomSequenceRepository() {
    final saved = _repository.getSavedSequence();
    if (saved != null) {
      _rows = saved.rows;
      _cols = saved.cols;
      _frames.clear();
      for (final frame in saved.frames) {
        _frames.add(_cloneFrame(frame));
      }
      _currentIndex = 0;
    } else {
      _frames.add(_createEmptyFrame(_rows, _cols));
    }
  }

  final CustomSequenceRepository _repository;

  // ── Grid & Frame Sequence States ─────────────────────────────────────
  int _rows = 4;
  int get rows => _rows;

  int _cols = 4;
  int get cols => _cols;

  final List<List<List<bool>>> _frames = [];
  List<List<List<bool>>> get frames => _frames;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Color _activeColor;
  Color get activeColor => _activeColor;

  bool _copied = false;
  bool get copied => _copied;

  /// Exposes the list of high-fidelity pre-made sequence templates from the repository.
  List<CustomSequence> get templates => _repository.getDefaultSequences();

  // ── Frame Utility Helpers ────────────────────────────────────────────

  List<List<bool>> _createEmptyFrame(int r, int c) {
    return List.generate(r, (_) => List.generate(c, (_) => false));
  }

  List<List<bool>> _cloneFrame(List<List<bool>> source) {
    return source.map((row) => List<bool>.from(row)).toList();
  }

  // ── Mutation Actions ──────────────────────────────────────────────────

  /// Loads a predefined sequence template.
  void loadTemplate(CustomSequence sequence) {
    HapticFeedback.mediumImpact();
    _rows = sequence.rows;
    _cols = sequence.cols;
    _frames.clear();
    for (final frame in sequence.frames) {
      _frames.add(_cloneFrame(frame));
    }
    _currentIndex = 0;
    saveCurrentSequence();
    notifyListeners();
  }

  /// Saves the current sequence state back to the repository cache.
  void saveCurrentSequence() {
    _repository.saveSequence(
      CustomSequence(
        name: 'Custom Sequence',
        rows: _rows,
        cols: _cols,
        frames: _frames.map((frame) => _cloneFrame(frame)).toList(),
      ),
    );
  }

  /// Updates active matrix color selection.
  void updateActiveColor(Color color) {
    if (_activeColor == color) return;
    _activeColor = color;
    saveCurrentSequence();
    notifyListeners();
  }

  /// Appends a new blank frame right after the current active index.
  void addFrame() {
    HapticFeedback.lightImpact();
    _frames.insert(_currentIndex + 1, _createEmptyFrame(_rows, _cols));
    _currentIndex++;
    saveCurrentSequence();
    notifyListeners();
  }

  /// Duplicates the active frame into the sequence timeline.
  void duplicateFrame() {
    HapticFeedback.lightImpact();
    _frames.insert(_currentIndex + 1, _cloneFrame(_frames[_currentIndex]));
    _currentIndex++;
    saveCurrentSequence();
    notifyListeners();
  }

  /// Removes the currently viewed frame from the sequence.
  void deleteFrame() {
    if (_frames.length == 1) return;
    HapticFeedback.lightImpact();
    _frames.removeAt(_currentIndex);
    if (_currentIndex >= _frames.length) {
      _currentIndex = _frames.length - 1;
    }
    saveCurrentSequence();
    notifyListeners();
  }

  /// Toggles a specific pixel index activation state.
  void toggleDot(int r, int c) {
    HapticFeedback.selectionClick();
    _frames[_currentIndex][r][c] = !_frames[_currentIndex][r][c];
    saveCurrentSequence();
    notifyListeners();
  }

  /// Clears out all current sequences and resets to a single empty frame.
  void clearSequence() {
    _frames.clear();
    _frames.add(_createEmptyFrame(_rows, _cols));
    _currentIndex = 0;
    saveCurrentSequence();
    notifyListeners();
  }

  /// Resets grid sizes and wipes all frame sequences cleanly.
  void changeGridSize(int r, int c) {
    _rows = r;
    _cols = c;
    _frames.clear();
    _frames.add(_createEmptyFrame(_rows, _cols));
    _currentIndex = 0;
    saveCurrentSequence();
    notifyListeners();
  }

  /// Sets the active timeline viewed index.
  void selectFrame(int index) {
    if (index >= 0 && index < _frames.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Reorders frame list sequence positions.
  void reorderFrames(int oldIndex, int newIndex) {
    HapticFeedback.lightImpact();
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _frames.removeAt(oldIndex);
    _frames.insert(newIndex, item);

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
      _currentIndex--;
    } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
      _currentIndex++;
    }
    saveCurrentSequence();
    notifyListeners();
  }

  // ── Code Generation & Exports ────────────────────────────────────────

  /// Compiles a dynamic SequenceAnimation loader instantiation snippet.
  String generateCode(DotShape shape) {
    final r = _activeColor.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _activeColor.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _activeColor.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final colorHex = '$r$g$b';

    final sb = StringBuffer();
    sb.writeln('DotMatrixLoader(');
    sb.writeln('  preset: SequenceAnimation(');
    sb.writeln('    frames: [');
    for (var frame in _frames) {
      sb.writeln('      [');
      for (var row in frame) {
        sb.write('        [');
        sb.write(row.map((b) => b.toString()).join(', '));
        sb.writeln('],');
      }
      sb.writeln('      ],');
    }
    sb.writeln('    ],');
    sb.writeln('  ),');
    sb.writeln('  style: DotMatrixStyle(');
    sb.writeln('    rows: $_rows,');
    sb.writeln('    columns: $_cols,');
    sb.writeln('    activeColor: const Color(0xFF$colorHex),');
    sb.writeln('    inactiveColor: const Color(0xFF1C1C1C),');
    sb.writeln('    dotShape: DotShape.${shape.name},');
    sb.writeln('  ),');
    sb.writeln(')');
    return sb.toString();
  }

  /// Copies sequence codes into systemic clipboards.
  Future<void> copyCode(DotShape shape) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: generateCode(shape)));
    _copied = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _copied = false;
    notifyListeners();
  }
}
