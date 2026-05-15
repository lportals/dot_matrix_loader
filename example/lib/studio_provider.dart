import 'package:flutter/material.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';

/// Centralized state provider for global Studio styling (shape, rounding, theme).
class StudioProvider extends InheritedWidget {
  const StudioProvider({
    super.key,
    required this.shape,
    required this.onShapeChanged,
    required this.isDark,
    required this.onToggleTheme,
    required super.child,
  });

  final DotShape shape;
  final ValueChanged<DotShape> onShapeChanged;
  final bool isDark;
  final VoidCallback onToggleTheme;

  /// Dynamic border radius based on the current dot shape.
  /// Circular dots -> rounded UI (16dp)
  /// Square dots -> sharp UI (4dp)
  BorderRadius get borderRadius {
    return shape == DotShape.circle 
        ? BorderRadius.circular(16) 
        : BorderRadius.circular(4);
  }

  static StudioProvider of(BuildContext context) {
    final StudioProvider? result = context.dependOnInheritedWidgetOfExactType<StudioProvider>();
    assert(result != null, 'No StudioProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(StudioProvider oldWidget) {
    return shape != oldWidget.shape || isDark != oldWidget.isDark;
  }
}
