import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../src/dot_matrix_animation_builder.dart';

import '../src/models/dot_matrix_style.dart';
import '../src/models/dot_matrix_preset.dart';

/// Interactive animation builder with real-time Dart code generation.
///
/// Users tweak sliders to shape a [DotAnimationFrame] and receive a
/// copy-pasteable Dart snippet that reproduces it exactly.
class BuilderPage extends StatefulWidget {
  const BuilderPage({super.key});

  @override
  State<BuilderPage> createState() => _BuilderPageState();
}

class _BuilderPageState extends State<BuilderPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // ── Parameters ────────────────────────────────────────────────────────────
  int _rows = 5;
  int _cols = 5;
  double _amplitude = 1.0;
  double _frequency = 1.0;
  double _phaseOffset = 0.0;
  double _delayStrength = 0.6;
  bool _reversed = false;
  int _basePresetIndex = 0;
  Color _activeColor = const Color(0xFFE53935);
  bool _copied = false;

  static const _basePresets = [
    'Pulse Rings',
    'Spiral',
    'Wave',
    'Cross Expand',
    'Rain',
    'Heartbeat',
    'Orbit',
    'Ripple',
    'Diagonal',
    'Bounce',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Frame builder ─────────────────────────────────────────────────────────

  DotAnimationFrame get _currentFrame {
    return (int row, int col, int rows, int cols, double t) {
      final teff = _reversed ? 1.0 - t : t;

      // Use selected base preset algorithm as a foundation
      final cx = (cols - 1) / 2.0;
      final cy = (rows - 1) / 2.0;

      double delay;
      double raw;

      switch (_basePresetIndex) {
        case 0: // Pulse Rings
          final maxD = math.sqrt(cx * cx + cy * cy);
          final d =
              math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          delay = maxD > 0 ? d / maxD * _delayStrength : 0.0;
          final localT =
              ((teff - delay) / (1 - delay).clamp(0.001, 1.0)).clamp(0.0, 1.0);
          raw = math.sin(localT * math.pi * _frequency) * _amplitude;
        case 1: // Spiral
          final angle = math.atan2(row - cy, col - cx);
          final maxD = math.sqrt(cx * cx + cy * cy);
          final d =
              math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          final normAngle = (angle + math.pi) / (2 * math.pi);
          delay = (normAngle * 0.5 + (maxD > 0 ? d / maxD : 0) * 0.5) *
              _delayStrength;
          final localT = ((teff - delay) / (1 - delay).clamp(0.001, 1.0))
              .clamp(0.0, 1.0);
          raw = math.sin(localT * math.pi * _frequency) * _amplitude;
        case 2: // Wave
          final phase = col / cols + _phaseOffset;
          raw = ((math.sin(teff * 2 * math.pi * _frequency -
                          phase * 2 * math.pi) +
                      1) /
                  2) *
              _amplitude;
          delay = 0;
        case 3: // Cross Expand
          final maxM = (cx.ceil() + cy.ceil()).toDouble();
          final manhattan =
              ((col - cx).abs() + (row - cy).abs());
          delay = maxM > 0 ? manhattan / maxM * _delayStrength : 0.0;
          final localT = ((teff - delay) / (1 - delay).clamp(0.001, 1.0))
              .clamp(0.0, 1.0);
          raw = math.sin(localT * math.pi * _frequency) * _amplitude;
        case 4: // Rain
          final phase =
              [0.0, 0.31, 0.62, 0.17, 0.48, 0.79][col % 6] + _phaseOffset;
          final drop = ((teff + phase) % 1.0);
          final rowT = row / (rows - 1);
          raw = (1.0 - ((rowT - drop).abs() * 3.0 / _amplitude))
              .clamp(0.0, 1.0);
          delay = 0;
        case 5: // Heartbeat
          final maxD = math.sqrt(cx * cx + cy * cy);
          final d =
              math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          delay = maxD > 0 ? d / maxD * 0.3 * _delayStrength : 0.0;
          final localT =
              (teff - delay).clamp(0.0, 1.0);
          final beat = (math.sin(localT * 2 * math.pi * _frequency) +
                  0.4 * math.sin(localT * 4 * math.pi * _frequency)) /
              1.4;
          raw = ((beat + 1) / 2 * _amplitude).clamp(0.0, 1.0);
        case 6: // Orbit
          final d =
              math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          final angle = math.atan2(row - cy, col - cx);
          final rotated =
              angle - teff * 2 * math.pi * _frequency * (1 + d * 0.3);
          raw = ((math.cos(rotated * 2 + _phaseOffset * math.pi) + 1) /
                  2 *
                  _amplitude)
              .clamp(0.0, 1.0);
          delay = 0;
        case 7: // Ripple
          final d =
              math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          raw = ((math.sin(d * _frequency * 2 -
                          teff * 2 * math.pi +
                          _phaseOffset * math.pi) +
                      1) /
                  2 *
                  _amplitude)
              .clamp(0.0, 1.0);
          delay = 0;
        case 8: // Diagonal
          delay = (row + col) /
              ((rows - 1) + (cols - 1)) *
              _delayStrength;
          final localT = ((teff - delay) / (1 - delay).clamp(0.001, 1.0))
              .clamp(0.0, 1.0);
          raw = math.sin(localT * math.pi * _frequency) * _amplitude;
        default: // Bounce
          final phase = col / cols + _phaseOffset;
          final localT = (teff + phase) % 1.0;
          raw =
              (math.sin(localT * math.pi * _frequency)).clamp(0.0, 1.0) *
              _amplitude;
          delay = 0;
      }

      final v = raw.clamp(0.0, 1.0);
      return DotState(opacity: v, scale: 0.3 + 0.7 * v);
    };
  }

  // ── Code generation ───────────────────────────────────────────────────────

  String get _generatedCode {
    final presetName = _basePresets[_basePresetIndex];
    final r = _activeColor.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _activeColor.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _activeColor.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final colorHex = '$r$g$b';

    return '''DotMatrixAnimationBuilder(
  frame: (row, col, rows, cols, t) {
    // Based on: $presetName
    // Amplitude: ${_amplitude.toStringAsFixed(2)}, Frequency: ${_frequency.toStringAsFixed(2)}
    // Phase offset: ${_phaseOffset.toStringAsFixed(2)}, Delay: ${_delayStrength.toStringAsFixed(2)}
    // Reversed: $_reversed
    final teff = ${_reversed ? '1.0 - t' : 't'};
    final cx = (cols - 1) / 2.0;
    final cy = (rows - 1) / 2.0;
    final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
    final maxDist = math.sqrt(cx * cx + cy * cy);
    final delay = maxDist > 0 ? dist / maxDist * ${_delayStrength.toStringAsFixed(2)} : 0.0;
    final localT = ((teff - delay) / (1 - delay).clamp(0.001, 1.0)).clamp(0.0, 1.0);
    final v = math.sin(localT * math.pi * ${_frequency.toStringAsFixed(2)}) * ${_amplitude.toStringAsFixed(2)};
    return DotState(opacity: v.clamp(0.0, 1.0), scale: 0.3 + 0.7 * v.clamp(0.0, 1.0));
  },
  style: DotMatrixStyle(
    rows: $_rows,
    columns: $_cols,
    activeColor: const Color(0xFF$colorHex),
    inactiveColor: const Color(0xFF1C1C1C),
  ),
)''';
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _generatedCode));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Title bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                const Text(
                  'Builder',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'LIVE PREVIEW',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.3),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Live preview ────────────────────────────────────────────────
          Center(
            child: DotMatrixAnimationBuilder(
              frame: _currentFrame,
              style: DotMatrixStyle(
                rows: _rows,
                columns: _cols,
                dotRadius: 6.5,
                dotGap: 7,
                activeColor: _activeColor,
                inactiveColor: const Color(0xFF1C1C1C),
              ),
              externalAnimation: _controller,
            ),
          ),
          const SizedBox(height: 28),

          // ── Controls ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Base preset selector
                  _SectionLabel('Base Preset'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _basePresets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final active = _basePresetIndex == i;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _basePresetIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: active
                                  ? _activeColor
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _basePresets[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid size
                  _SectionLabel('Grid Size'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledSlider(
                          label: 'Rows',
                          value: _rows.toDouble(),
                          min: 3,
                          max: 10,
                          divisions: 7,
                          displayValue: '$_rows',
                          activeColor: _activeColor,
                          onChanged: (v) =>
                              setState(() => _rows = v.round()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _LabeledSlider(
                          label: 'Cols',
                          value: _cols.toDouble(),
                          min: 3,
                          max: 10,
                          divisions: 7,
                          displayValue: '$_cols',
                          activeColor: _activeColor,
                          onChanged: (v) =>
                              setState(() => _cols = v.round()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Animation params
                  _SectionLabel('Parameters'),
                  const SizedBox(height: 8),
                  _LabeledSlider(
                    label: 'Amplitude',
                    value: _amplitude,
                    min: 0.1,
                    max: 2.0,
                    displayValue: _amplitude.toStringAsFixed(2),
                    activeColor: _activeColor,
                    onChanged: (v) => setState(() => _amplitude = v),
                  ),
                  const SizedBox(height: 8),
                  _LabeledSlider(
                    label: 'Frequency',
                    value: _frequency,
                    min: 0.5,
                    max: 4.0,
                    displayValue: _frequency.toStringAsFixed(2),
                    activeColor: _activeColor,
                    onChanged: (v) => setState(() => _frequency = v),
                  ),
                  const SizedBox(height: 8),
                  _LabeledSlider(
                    label: 'Phase Offset',
                    value: _phaseOffset,
                    min: 0.0,
                    max: 1.0,
                    displayValue: _phaseOffset.toStringAsFixed(2),
                    activeColor: _activeColor,
                    onChanged: (v) => setState(() => _phaseOffset = v),
                  ),
                  const SizedBox(height: 8),
                  _LabeledSlider(
                    label: 'Delay Strength',
                    value: _delayStrength,
                    min: 0.0,
                    max: 1.0,
                    displayValue: _delayStrength.toStringAsFixed(2),
                    activeColor: _activeColor,
                    onChanged: (v) =>
                        setState(() => _delayStrength = v),
                  ),
                  const SizedBox(height: 12),

                  // Reverse + color
                  Row(
                    children: [
                      const Text(
                        'Reversed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _reversed = !_reversed),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 24,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _reversed
                                ? _activeColor
                                : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            alignment: _reversed
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Color picker row
                  _SectionLabel('Active Color'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final c in [
                        const Color(0xFFE53935),
                        const Color(0xFF42A5F5),
                        const Color(0xFF66BB6A),
                        const Color(0xFFFFA726),
                        const Color(0xFFAB47BC),
                        Colors.white,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _activeColor = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _activeColor == c
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: _activeColor == c
                                    ? [
                                        BoxShadow(
                                          color:
                                              c.withValues(alpha: 0.5),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Code output panel
                  _CodeOutputPanel(
                    code: _generatedCode,
                    copied: _copied,
                    onCopy: _copyCode,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.activeColor,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 5),
              activeTrackColor: activeColor,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: Colors.white,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            displayValue,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeOutputPanel extends StatelessWidget {
  const _CodeOutputPanel({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  final String code;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  'GENERATED CODE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCopy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: copied
                          ? const Color(0xFF1E3A1E)
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: copied
                          ? const Text(
                              '✓ Copied',
                              key: ValueKey('copied'),
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF66BB6A),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              'Copy',
                              key: const ValueKey('copy'),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          // Code content
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFCDD3DE),
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
