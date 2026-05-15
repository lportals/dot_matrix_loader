import 'package:flutter/material.dart';
import '../src/dot_matrix_loader.dart';
import '../src/models/dot_matrix_style.dart';
import '../src/models/dot_matrix_preset.dart';

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
  });

  final PresetCardData entry;
  final Animation<double> sharedAnimation;
  final Color activeColor;

  @override
  State<PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<PresetCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot preview area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: DotMatrixLoader(
                      preset: widget.entry.preset,
                      style: DotMatrixStyle(
                        activeColor: widget.activeColor,
                        inactiveColor: const Color(0xFF1C1C1C),
                        dotRadius: 5.5,
                        dotGap: 6,
                      ),
                      externalAnimation: widget.sharedAnimation,
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
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.entry.tag,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withValues(alpha: 0.35),
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
                        color: Colors.white.withValues(alpha: 0.35),
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
