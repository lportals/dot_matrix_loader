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
  const BuilderPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

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
    'Shockwave',
    'Metronome',
    'Erosion',
    'Sonar',
    'Curtain',
    'Interference',
    'Ticker',
    'Genome',
    'Stack Fill',
    'Veil',
    'Radar',
    'Scanner',
    'Collapse',
    'Static',
    'Wanderer',
    'Crosshair',
    'Ripple In',
    'Wipe',
    'Twinkle',
    'ZigZag',
    'Equalizer',
    'Gravity',
    'Glitch',
    'Diamond',
    'Checkerboard',
    'Breathe',
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
          final dx = (col - cx.toInt()).abs();
          final dy = (row - cy.toInt()).abs();
          final dist = math.max(dx, dy);
          final maxDx = math.max(cx.toInt(), cols - 1 - cx.toInt());
          final maxDy = math.max(cy.toInt(), rows - 1 - cy.toInt());
          final maxDist = math.max(maxDx, maxDy);
          final totalSteps = maxDist + 1;
          
          if (totalSteps == 0) {
            raw = 1.0;
            delay = 0;
            break;
          }
          final idxDelay = dist / totalSteps;
          final delta = (teff * _frequency - idxDelay * _delayStrength + 1.0) % 1.0;
          final v = math.pow(math.max(0.0, 1.0 - delta * totalSteps.toDouble()), 2).toDouble();
          raw = v * _amplitude;
          delay = 0;
        case 1: // Spiral
          final dx = col - cx.toInt();
          final dy = row - cy.toInt();
          final d = math.max(dx.abs(), dy.abs());
          int index = 0;
          if (d > 0) {
            final base = (2 * d - 1) * (2 * d - 1);
            if (dx == d && dy > -d) {
              index = base + (dy + d - 1);
            } else if (dy == d && dx < d) {
              index = base + 2 * d + ((d - 1) - dx);
            } else if (dx == -d && dy < d) {
              index = base + 4 * d + ((d - 1) - dy);
            } else {
              index = base + 6 * d + (dx + d - 1);
            }
          }
          final maxDx = math.max(cx.toInt(), cols - 1 - cx.toInt());
          final maxDy = math.max(cy.toInt(), rows - 1 - cy.toInt());
          final maxD = math.max(maxDx, maxDy);
          final totalSteps = (2 * maxD + 1) * (2 * maxD + 1);
          if (totalSteps == 0) {
            raw = 1.0;
            delay = 0;
            break;
          }
          final idxDelay = index / totalSteps;
          final localT = (teff * _frequency - idxDelay * _delayStrength);
          final progress = localT * totalSteps;
          raw = progress.clamp(0.0, 1.0) * _amplitude;
          delay = 0;
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
              ((rows - 1).clamp(1, rows) + (cols - 1).clamp(1, cols)) *
              _delayStrength;
          final localT = ((teff - delay) / (1 - delay).clamp(0.001, 1.0))
              .clamp(0.0, 1.0);
          raw = math.sin(localT * math.pi * _frequency) * _amplitude;
        case 9: // Bounce
          final phase = col / cols + _phaseOffset;
          final localT = (teff + phase) % 1.0;
          raw =
              (math.sin(localT * math.pi * _frequency)).clamp(0.0, 1.0) *
              _amplitude;
          delay = 0;
        case 10: // Shockwave
          final maxD = math.sqrt(cx * cx + cy * cy);
          final d = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          delay = maxD > 0 ? d / maxD * _delayStrength : 0.0;
          final localT = (teff - delay).clamp(0.0, 1.0);
          raw = math.exp(-localT * 4) * math.sin(localT * math.pi * _frequency) * _amplitude;
        case 11: // Metronome
          final swingX = cx * (1.0 + math.cos(teff * 2 * math.pi * _frequency)) / 2.0;
          final dist = (col - swingX - row * 0.15 * _delayStrength).abs();
          raw = math.pow((1.0 - dist * 0.8).clamp(0.0, 1.0), 2).toDouble() * _amplitude;
          delay = 0;
        case 12: // Erosion
          final diagIdx = (row + col) / ((rows - 1).clamp(1, rows) + (cols - 1).clamp(1, cols));
          if (teff < 0.6) {
            final localT = teff / 0.6;
            final edge0 = diagIdx - 0.1;
            final edge1 = diagIdx + 0.1;
            final x = edge0 == edge1 ? (localT >= edge0 ? 1.0 : 0.0) : ((localT - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
            raw = (1.0 - x * x * (3 - 2 * x)) * _amplitude;
          } else {
            final localT = (teff - 0.6) / 0.4;
            final edge0 = diagIdx - 0.1;
            final edge1 = diagIdx + 0.1;
            final x = edge0 == edge1 ? (localT >= edge0 ? 1.0 : 0.0) : ((localT - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
            raw = x * x * (3 - 2 * x) * _amplitude;
          }
          delay = 0;
        case 13: // Sonar
          final d = math.sqrt(col * col + row * row);
          final maxD = math.sqrt(math.pow(cols - 1, 2) + math.pow(rows - 1, 2));
          final normD = maxD > 0 ? d / maxD : 0.0;
          final pingT = teff < 0.5 ? teff * 2 : (1 - teff) * 2;
          final delta = (pingT - normD).abs();
          raw = math.max(0.0, 1.0 - delta * 6.0 * _frequency).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 14: // Curtain
          final colStart = (cols > 1 ? col / (cols - 1) : 0.0) * 0.8;
          final rowStart = colStart + (rows > 1 ? row / (rows - 1) : 0.0) * 0.15;
          final x = ((teff - rowStart) / 0.05).clamp(0.0, 1.0);
          raw = x * x * (3 - 2 * x) * _amplitude;
          delay = 0;
        case 15: // Interference
          final d1 = math.sqrt(col * col + row * row);
          final d2 = math.sqrt(math.pow(cols - 1 - col, 2) + math.pow(rows - 1 - row, 2));
          final maxD = math.sqrt(math.pow(cols - 1, 2) + math.pow(rows - 1, 2));
          final norm1 = maxD > 0 ? d1 / maxD : 0.0;
          final norm2 = maxD > 0 ? d2 / maxD : 0.0;
          final v1 = math.sin(norm1 * math.pi * 3 - teff * 2 * math.pi * _frequency);
          final v2 = math.sin(norm2 * math.pi * 3 - teff * 2 * math.pi * _frequency * 1.1);
          raw = (((v1 + v2) / 2.0 + 1.0) / 2.0).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 16: // Ticker
          int pos = 0;
          int totalPerimeter = (cols * 2) + ((rows - 2) * 2);
          if (totalPerimeter <= 0) totalPerimeter = 1;
          if (row == 0) {
            pos = col;
          } else if (col == cols - 1) {
            pos = cols - 1 + row;
          } else if (row == rows - 1) {
            pos = cols - 1 + rows - 1 + (cols - 1 - col);
          } else if (col == 0) {
            pos = cols - 1 + rows - 1 + cols - 1 + (rows - 1 - row);
          } else {
            raw = 0.0;
            delay = 0;
            break;
          }
          
          final perimeterPos = pos / totalPerimeter;
          final delta = (teff * _frequency - perimeterPos + 1.0) % 1.0;
          raw = math.max(0.0, 1.0 - delta * 5.0).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 17: // Genome
          final phase = ((row * 7 + col * 13) % 17) / 17.0;
          final freq1 = 1.0 + ((row * 3 + col * 5) % 7) / 14.0;
          final val = (math.sin(teff * 2 * math.pi * freq1 * _frequency + phase * 2 * math.pi) + 
                       math.sin(teff * 2 * math.pi * (freq1 + 0.3) * _frequency + phase * math.pi)) / 2.0;
          raw = ((val + 1.0) / 2.0).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 18: // Stack Fill
          final centerDist = cx > 0 ? (col - cx).abs() / cx : 0.0;
          final colSpeed = 0.5 + 0.5 * (1.0 - centerDist);
          final fillLevel = math.min(1.0, teff * colSpeed / 0.8 * _frequency);
          final rowNorm = rows > 1 ? 1.0 - row / (rows - 1) : 1.0;
          raw = (rowNorm <= fillLevel ? 1.0 : 0.0) * _amplitude;
          delay = 0;
        case 19: // Veil
          final angle = teff * 2 * math.pi * _frequency;
          final projection = (col - cx) * math.cos(angle) + (row - cy) * math.sin(angle);
          final maxProjection = math.sqrt(cx * cx + cy * cy);
          final normalizedProj = maxProjection > 0 ? (projection / maxProjection + 1.0) / 2.0 : 0.5;
          raw = (math.sin(normalizedProj * math.pi)).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 20: // Radar
          final angle = math.atan2(row - cy, col - cx);
          final normAngle = (angle + math.pi) / (2 * math.pi);
          final delta = (teff * _frequency - normAngle * _delayStrength + 1.0) % 1.0;
          raw = math.max(0.0, 1.0 - delta * 4.0) * _amplitude;
          delay = 0;
        case 21: // Scanner
          final scanRow = rows > 1 ? (math.sin(teff * 2 * math.pi * _frequency) + 1.0) / 2.0 * (rows - 1) : 0.0;
          final d = (row - scanRow).abs();
          raw = math.max(0.0, 1.0 - d * 1.5 * _delayStrength).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 22: // Collapse
          final d = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          final maxD = math.sqrt(cx * cx + cy * cy);
          final normDist = maxD > 0 ? d / maxD : 0.0;
          final activeRadius = (1.0 - teff * _frequency);
          final diff = (normDist - activeRadius).abs();
          raw = math.max(0.0, 1.0 - diff * 5.0 * _delayStrength).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 23: // Static
          final frame = (teff * 20 * _frequency).floor();
          final hash = (row * 31 + col * 17 + frame * 13) % 100;
          raw = (hash > 80 ? 1.0 : 0.0) * _amplitude;
          delay = 0;
        case 24: // Wanderer
          final targetX = (math.sin(teff * 2 * math.pi * 3 * _frequency) + 1.0) / 2.0 * (cols - 1);
          final targetY = (math.sin(teff * 2 * math.pi * 4 * _frequency) + 1.0) / 2.0 * (rows - 1);
          final d = math.sqrt(math.pow(col - targetX, 2) + math.pow(row - targetY, 2));
          raw = math.max(0.0, 1.0 - d * 1.2 * _delayStrength).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 25: // Crosshair
          final targetX = (math.sin(teff * 2 * math.pi * _frequency) + 1.0) / 2.0 * (cols - 1);
          final targetY = (math.cos(teff * 2 * math.pi * _frequency) + 1.0) / 2.0 * (rows - 1);
          final vX = math.max(0.0, 1.0 - (col - targetX).abs() * 1.5 * _delayStrength);
          final vY = math.max(0.0, 1.0 - (row - targetY).abs() * 1.5 * _delayStrength);
          raw = math.max(vX, vY).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 26: // Ripple In
          final d = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
          final val = ((math.sin(d * 2.5 * _delayStrength + teff * 2 * math.pi * _frequency) + 1) / 2).clamp(0.0, 1.0);
          raw = val * _amplitude;
          delay = 0;
        case 27: // Wipe
          final angle = teff * math.pi * 2 * _frequency;
          final dotProj = col * math.cos(angle) + row * math.sin(angle);
          final midProj = cx * math.cos(angle) + cy * math.sin(angle);
          raw = (dotProj > midProj ? 1.0 : 0.0) * _amplitude;
          delay = 0;
        case 28: // Twinkle
          final phase = (row * 13 + col * 7) % 23 / 23.0;
          final speed = 1.0 + ((row * 5 + col * 11) % 7) / 7.0;
          final rawV = (math.sin(teff * 2 * math.pi * speed * _frequency + phase * 2 * math.pi) + 1.0) / 2.0;
          raw = math.pow(rawV, 4).toDouble().clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 29: // ZigZag
          final totalDots = rows * cols;
          if (totalDots == 0) {
            raw = 0.0; delay = 0; break;
          }
          final litIndex = (teff * _frequency * totalDots).floor();
          final c = (row % 2 == 0) ? col : (cols - 1 - col);
          final myIndex = row * cols + c;
          final diff = litIndex - myIndex;
          raw = (diff >= 0 && diff < 4) ? (1.0 - diff * 0.25).clamp(0.0, 1.0) * _amplitude : 0.0;
          delay = 0;
        case 30: // Equalizer
          final freq1 = 1.0 + (col % 3) * 0.5;
          final freq2 = 1.5 + (col % 2) * 0.7;
          final phase = col * 0.5 * _delayStrength;
          final h = (math.sin(teff * math.pi * 2 * freq1 * _frequency + phase) + 
                     math.sin(teff * math.pi * 2 * freq2 * _frequency - phase)) / 2.0;
          final normalizedHeight = (h + 1.0) / 2.0;
          final activeHeight = normalizedHeight * rows;
          final rowFromBottom = rows - 1 - row;
          if (rowFromBottom <= activeHeight) {
            raw = 1.0;
          } else if (rowFromBottom - activeHeight < 1.0) {
            raw = 1.0 - (rowFromBottom - activeHeight);
          } else {
            raw = 0.0;
          }
          raw *= _amplitude;
          delay = 0;
        case 31: // Gravity
          final phase = col / cols;
          final localT = (teff * _frequency + phase * _delayStrength) % 1.0;
          final bounceY = math.pow(math.sin(localT * math.pi), 1.5); 
          final targetRow = (1.0 - bounceY) * (rows - 1);
          final d = (row - targetRow).abs();
          raw = math.max(0.0, 1.0 - d * 1.5).clamp(0.0, 1.0) * _amplitude;
          delay = 0;
        case 32: // Glitch
          final frame = (teff * 15 * _frequency).floor();
          final shift = ((row * 17 + frame * 31) % 5) - 2;
          final virtualCol = col + shift;
          final noise = ((virtualCol * 13 + row * 7 + frame * 23) % 100);
          raw = (noise > 85 ? 0.0 : 1.0) * _amplitude;
          delay = 0;
        case 33: // Diamond
          final manhattan = (col - cx).abs() + (row - cy).abs();
          final maxD = cx + cy;
          final normDist = maxD > 0 ? manhattan / maxD : 0.0;
          final delta = (teff * _frequency - normDist * _delayStrength + 1.0) % 1.0;
          raw = math.pow(math.max(0.0, 1.0 - delta * 4.0), 2).toDouble() * _amplitude;
          delay = 0;
        case 34: // Checkerboard
          final isEven = (row + col) % 2 == 0;
          final phase = isEven ? 0.0 : 0.5 * _delayStrength;
          raw = ((math.sin((teff * _frequency + phase) * 2 * math.pi) + 1.0) / 2.0) * _amplitude;
          delay = 0;
        default: // 35: Breathe
          final sine = (math.sin(teff * 2 * math.pi * _frequency - math.pi / 2) + 1.0) / 2.0;
          raw = math.pow(sine, 2.5).toDouble() * _amplitude;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final previewInactive =
        isDark ? const Color(0xFF1C1C1C) : const Color(0xFFDDDDDD);

    return SafeArea(
      child: Column(
        children: [
          // ── Title bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Text(
                  'Builder',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'LIVE PREVIEW',
                  style: TextStyle(
                    fontSize: 10,
                    color: onSurface.withValues(alpha: 0.3),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onToggleTheme,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: onSurface.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        widget.isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        key: ValueKey(widget.isDark),
                        size: 16,
                        color: onSurface.withValues(alpha: 0.55),
                      ),
                    ),
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
                inactiveColor: previewInactive,
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
                          max: 5,
                          divisions: 2,
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
                          max: 5,
                          divisions: 2,
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
                      Text(
                        'Reversed',
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.6),
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
                                : onSurface.withValues(alpha: 0.12),
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
                              decoration: BoxDecoration(
                                color: onSurface,
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
                        isDark ? Colors.white : Colors.black,
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
                                      ? onSurface
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
        color: onSurface.withValues(alpha: 0.3),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: onSurface.withValues(alpha: 0.5),
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
              inactiveTrackColor: onSurface.withValues(alpha: 0.1),
              thumbColor: onSurface,
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
              color: onSurface.withValues(alpha: 0.45),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final panelBg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFE8E8E8);
    final borderColor = onSurface.withValues(alpha: 0.07);
    final dividerColor = onSurface.withValues(alpha: 0.05);

    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
                    color: onSurface.withValues(alpha: 0.3),
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
                          : onSurface.withValues(alpha: 0.07),
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
                                color: onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: dividerColor),
          // Code content
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              code,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? const Color(0xFFCDD3DE)
                    : const Color(0xFF2D3748),
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
