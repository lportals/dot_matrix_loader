import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../../data/models/config_data.dart';
import '../../data/models/status_example.dart';
import '../../data/repositories/preset_repository.dart';

/// ViewModel managing state and UI interaction logic for the Showcase Examples page.
class ExamplesViewModel extends ChangeNotifier {
  ExamplesViewModel({required Color defaultColor})
      : _activeSelectedColor = defaultColor;

  // ── Playground Config State ──────────────────────────────────────────
  String _activeLabel = 'Reasoning with agents...';
  String get activeLabel => _activeLabel;

  String _activePresetName = 'Orbit';
  String get activePresetName => _activePresetName;

  int _activeRows = 3;
  int get activeRows => _activeRows;

  int _activeCols = 3;
  int get activeCols => _activeCols;

  double _activeRadius = 2.2;
  double get activeRadius => _activeRadius;

  double _activeGap = 3.2;
  double get activeGap => _activeGap;

  double _activeLoaderSize = 20.0;
  double get activeLoaderSize => _activeLoaderSize;

  DotShape _activeShape = DotShape.circle;
  DotShape get activeShape => _activeShape;

  Color _activeSelectedColor;
  Color get activeSelectedColor => _activeSelectedColor;

  bool _activeGlow = false;
  bool get activeGlow => _activeGlow;

  bool _activeTrail = false;
  bool get activeTrail => _activeTrail;

  bool _isColorOverridden = false;

  // ── Filters & Search State ───────────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  bool _isCodeExpanded = false;
  bool get isCodeExpanded => _isCodeExpanded;

  bool _codeCopied = false;
  bool get codeCopied => _codeCopied;

  /// Supported status categories.
  List<String> get categories => const [
        'All',
        'AI & Neural',
        'Networking',
        'System Streams',
        'Hardware & OS',
        'Database & Search',
        'File System',
        'Security & Cryptography',
        'Media & Audio',
      ];

  /// Filters status examples by category and search query.
  List<StatusIndicatorExample> get filteredExamples {
    return PresetRepository.statusExamples.where((item) {
      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = item.label
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ── Mutation Actions ──────────────────────────────────────────────────

  /// Updates the default system primary color if it hasn't been overridden.
  void updateDefaultColor(Color color) {
    if (!_isColorOverridden && _activeSelectedColor != color) {
      _activeSelectedColor = color;
      notifyListeners();
    }
  }

  /// Sets the active playground configurations.
  void updateConfig(ConfigData data) {
    _activeLabel = data.label;
    _activePresetName = data.presetName;
    _activeRows = data.rows;
    _activeCols = data.cols;
    _activeRadius = data.radius;
    _activeGap = data.gap;
    _activeLoaderSize = data.loaderSize;
    _activeShape = data.shape;
    _activeSelectedColor = data.color;
    _activeGlow = data.enableGlow;
    _activeTrail = data.enableTrail;
    _isColorOverridden = true;
    notifyListeners();
  }

  /// Programmatic shape override synchronized with the studio.
  void updateShape(DotShape shape) {
    if (_activeShape != shape) {
      _activeShape = shape;
      notifyListeners();
    }
  }

  /// Updates the active search query.
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Updates the selected category filter.
  void updateCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Toggles visibility of the source code preview.
  void toggleCodeExpanded() {
    _isCodeExpanded = !_isCodeExpanded;
    notifyListeners();
  }

  /// Generates the clean Dart source code snippet based on the current configuration.
  String generateCodeSnippet(bool isDark) {
    final r = _activeSelectedColor.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _activeSelectedColor.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _activeSelectedColor.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final colorHex = '$r$g$b';

    final inactiveAlpha = isDark ? '1F' : '14'; // 0.08 vs 0.04 opacities
    final baseColor = isDark ? 'FFFFFF' : '000000';

    final glowPart = _activeGlow ? '\n    enableGlow: true,' : '';
    final trailPart = _activeTrail ? '\n    enableTrail: true,' : '';

    return '''DotMatrixLoader(
  preset: const $_activePresetName(),
  style: DotMatrixStyle(
    columns: $_activeCols,
    rows: $_activeRows,
    dotRadius: ${_activeRadius.toStringAsFixed(1)},
    dotGap: ${_activeGap.toStringAsFixed(1)},
    activeColor: const Color(0xFF$colorHex),
    inactiveColor: const Color(0x$inactiveAlpha$baseColor),
    dotShape: DotShape.${_activeShape.name},$glowPart$trailPart
  ),
)''';
  }

  /// Copies the currently active code snippet to the system clipboard with tactile feedback.
  Future<void> copySnippetToClipboard(bool isDark) async {
    final snippet = generateCodeSnippet(isDark);
    await Clipboard.setData(ClipboardData(text: snippet));
    _codeCopied = true;
    notifyListeners();
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(seconds: 2));
    _codeCopied = false;
    notifyListeners();
  }
}
