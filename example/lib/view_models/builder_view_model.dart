import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../../data/repositories/preset_repository.dart';

/// ViewModel managing parameters, speed controllers, and exports for the Single Preset Builder page.
class BuilderViewModel extends ChangeNotifier {
  BuilderViewModel({
    required String initialPresetName,
    required Color initialColor,
    required int initialRows,
    required int initialCols,
    required double initialSpeed,
  })  : _presetName = initialPresetName,
        _activeColor = initialColor,
        _rows = initialRows,
        _cols = initialCols,
        _speed = initialSpeed;

  // ── Style Parameter States ───────────────────────────────────────────
  String _presetName;
  String get presetName => _presetName;

  Color _activeColor;
  Color get activeColor => _activeColor;

  double _dotRadius = 2.5;
  double get dotRadius => _dotRadius;

  double _dotGap = 6.0;
  double get dotGap => _dotGap;

  double _loaderSize = 48.0;
  double get loaderSize => _loaderSize;

  double _speed = 1.0;
  double get speed => _speed;

  int _rows = 5;
  int get rows => _rows;

  int _cols = 5;
  int get cols => _cols;

  bool _enableColorLerp = true;
  bool get enableColorLerp => _enableColorLerp;

  bool _copied = false;
  bool get copied => _copied;

  /// Returns the corresponding DotMatrixPreset class instance.
  DotMatrixPreset get preset =>
      PresetRepository.presetsByDisplayName[_presetName] ?? const PulseRings();

  // ── Mutation Actions ──────────────────────────────────────────────────

  /// Sets the active preset.
  void updatePreset(String name) {
    if (PresetRepository.presetsByDisplayName.containsKey(name)) {
      _presetName = name;
      notifyListeners();
    }
  }

  /// Sets the primary active color.
  void updateColor(Color color) {
    if (_activeColor == color) return;
    _activeColor = color;
    notifyListeners();
  }

  /// Sets the rows count in the matrix.
  void updateRows(int r) {
    _rows = r;
    notifyListeners();
  }

  /// Sets the columns count in the matrix.
  void updateCols(int c) {
    _cols = c;
    notifyListeners();
  }

  /// Sets the individual dot radius.
  void updateRadius(double r) {
    _dotRadius = r;
    notifyListeners();
  }

  /// Sets the gap distance between dots.
  void updateGap(double g) {
    _dotGap = g;
    notifyListeners();
  }

  /// Sets the total physical display layout size.
  void updateLoaderSize(double s) {
    _loaderSize = s;
    notifyListeners();
  }

  /// Sets the color interpolation mode.
  void toggleColorLerp(bool value) {
    _enableColorLerp = value;
    notifyListeners();
  }

  /// Sets animation controller speed and updates its duration dynamically.
  void updateSpeed(double v, AnimationController controller) {
    _speed = v;
    controller.duration = Duration(milliseconds: (1200 / v).round());
    if (controller.isAnimating) {
      controller.repeat();
    }
    notifyListeners();
  }

  // ── Code Generation & Clipboard ──────────────────────────────────────

  /// Compiles a fully functional standard Loader instantiation code block.
  String generateCode(DotShape shape) {
    final r = _activeColor.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _activeColor.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _activeColor.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final colorHex = '0xFF$r$g$b';

    final sb = StringBuffer()
      ..writeln('DotMatrixLoader(')
      ..writeln('  preset: const $_presetName(),');

    sb.writeln('  style: DotMatrixStyle(');
    if (_rows != 5) sb.writeln('    rows: $_rows,');
    if (_cols != 5) sb.writeln('    columns: $_cols,');
    sb.writeln('    activeColor: const Color($colorHex),');
    if (_dotRadius != 2.5) {
      sb.writeln('    dotRadius: ${_dotRadius.toStringAsFixed(1)},');
    }
    if (_dotGap != 6.0) {
      sb.writeln('    dotGap: ${_dotGap.toStringAsFixed(1)},');
    }
    if (_speed != 1.0) {
      sb.writeln('    speed: ${_speed.toStringAsFixed(2)},');
    }
    if (shape != DotShape.circle) {
      sb.writeln('    dotShape: DotShape.roundedSquare,');
    }
    if (!_enableColorLerp) {
      sb.writeln('    enableColorLerp: false,');
    }
    sb.writeln('  ),');
    if (_loaderSize != 100.0) {
      sb.writeln('  size: ${_loaderSize.toStringAsFixed(1)},');
    }
    sb.writeln(')');

    return sb.toString();
  }

  /// Copies the generated snippet with haptic feedback responses.
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
