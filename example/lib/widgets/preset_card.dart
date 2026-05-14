import 'package:flutter/material.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';



/// Data passed to each [PresetCard] widget.
class PresetCardData {
  const PresetCardData({
    required this.preset,
    required this.name,
    required this.description,
    required this.tag,
    required this.category,
  });

  final DotMatrixPreset preset;
  final String name;
  final String description;
  final String tag;
  final String category;
}

/// A single preset card in the showcase gallery.
///
/// Shares the parent's [sharedAnimation] for zero-overhead rendering.
class PresetCard extends StatefulWidget {
  const PresetCard({
    super.key,
    required this.entry,
    required this.sharedAnimation,
    required this.activeColor,
    this.rows = 5,
    this.cols = 5,
    this.onTap,
  });

  final PresetCardData entry;
  final Animation<double> sharedAnimation;
  final Color activeColor;
  final VoidCallback? onTap;

  /// Number of rows in the dot grid preview.
  final int rows;

  /// Number of columns in the dot grid preview.
  final int cols;

  @override
  State<PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<PresetCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);
    final previewBg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFEAEAEA);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final inactiveDot = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFDDDDDD);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot preview area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: previewBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: DotMatrixLoader(
                        preset: widget.entry.preset,
                        style: DotMatrixStyle(
                          activeColor: widget.activeColor,
                          inactiveColor: inactiveDot,
                          rows: widget.rows,
                          columns: widget.cols,
                          dotRadius: 5.5,
                          dotGap: 6,
                        ),
                        externalAnimation: widget.sharedAnimation,
                      ),
                    ),
                  ),
                ),
              ),
              // Info section
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.entry.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.entry.tag,
                            style: TextStyle(
                              fontSize: 9,
                              color: onSurface.withValues(alpha: 0.35),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.entry.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: onSurface.withValues(alpha: 0.35),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
