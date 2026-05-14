import 'dart:math' as math;

/// Immutable animated state for a single dot, resolved each frame.
class DotState {
  /// Creates a [DotState].
  ///
  /// [opacity] drives the color lerp when `enableColorLerp` is active.
  /// [scale]   drives per-dot size variation.
  const DotState({this.opacity = 1.0, this.scale = 1.0});

  /// Opacity / activity level of this dot. Range: [0.0, 1.0].
  final double opacity;

  /// Scale factor applied to this dot from its center. Range: [0.0, 1.0].
  final double scale;
}

/// Function signature for a dot-matrix delay-map.
///
/// Given a dot's [row] and [col] position within a grid of [rows] × [cols],
/// and the global normalized animation progress [t] in [0.0, 1.0],
/// returns the [DotState] that should be rendered for that dot on this frame.
typedef DotAnimationFrame = DotState Function(
  int row,
  int col,
  int rows,
  int cols,
  double t,
);

// ---------------------------------------------------------------------------
// Sealed preset hierarchy
// ---------------------------------------------------------------------------

/// Base sealed class for all dot-matrix animation presets.
///
/// Use one of the ten built-in subclasses or supply a fully custom
/// delay-map via [CustomDotAnimation].
sealed class DotMatrixPreset {
  const DotMatrixPreset();
}

/// Concentric rings expand outward from the center of the grid.
class PulseRings extends DotMatrixPreset {
  const PulseRings();
}

/// A bright trace winds outward from the center in a spiral path.
class Spiral extends DotMatrixPreset {
  const Spiral();
}

/// A breathing sine wave drifts from left to right.
class Wave extends DotMatrixPreset {
  const Wave();
}

/// A plus shape blooms outward in Manhattan steps from the center.
class CrossExpand extends DotMatrixPreset {
  const CrossExpand();
}

/// Independent drops fall column by column.
class Rain extends DotMatrixPreset {
  const Rain();
}

/// A double-pulse heartbeat rhythm radiates from the center.
class Heartbeat extends DotMatrixPreset {
  const Heartbeat();
}

/// Dots cycle in concentric orbital rings around the center.
class Orbit extends DotMatrixPreset {
  const Orbit();
}

/// Concentric sine ripples radiate outward from the center.
class Ripple extends DotMatrixPreset {
  const Ripple();
}

/// A sweep travels along the diagonal from top-left to bottom-right.
class Diagonal extends DotMatrixPreset {
  const Diagonal();
}

/// Dots bounce vertically with a row-based phase offset.
class Bounce extends DotMatrixPreset {
  const Bounce();
}

/// A sharp ring erupts from the center with an exponential decay.
class Shockwave extends DotMatrixPreset {
  const Shockwave();
}

/// A vertical column that swings left-right with a row-based lag.
class Metronome extends DotMatrixPreset {
  const Metronome();
}

/// A two-phase diagonal erase and refill pattern.
class Erosion extends DotMatrixPreset {
  const Erosion();
}

/// A ping originates from the corner, expands, bounces and returns.
class Sonar extends DotMatrixPreset {
  const Sonar();
}

/// Columns fill top-down in a staggered left-to-right theatrical reveal.
class Curtain extends DotMatrixPreset {
  const Curtain();
}

/// Two offset circular waves interfere to create moiré patterns.
class Interference extends DotMatrixPreset {
  const Interference();
}

/// A single dot races around the perimeter with non-uniform velocity.
class Ticker extends DotMatrixPreset {
  const Ticker();
}

/// Per-dot dual-oscillator FM synthesis for a deterministic organic feel.
class Genome extends DotMatrixPreset {
  const Genome();
}

/// A variable-rate columnar bottom-up fill with a dome-shaped front.
class StackFill extends DotMatrixPreset {
  const StackFill();
}

/// A full brightness sweep band that continuously rotates its angle.
class Veil extends DotMatrixPreset {
  const Veil();
}

class Radar extends DotMatrixPreset { const Radar(); }
class Scanner extends DotMatrixPreset { const Scanner(); }
class Collapse extends DotMatrixPreset { const Collapse(); }
class Static extends DotMatrixPreset { const Static(); }
class Wanderer extends DotMatrixPreset { const Wanderer(); }
class Crosshair extends DotMatrixPreset { const Crosshair(); }
class RippleIn extends DotMatrixPreset { const RippleIn(); }
class Wipe extends DotMatrixPreset { const Wipe(); }
class Twinkle extends DotMatrixPreset { const Twinkle(); }
class ZigZag extends DotMatrixPreset { const ZigZag(); }
class Equalizer extends DotMatrixPreset { const Equalizer(); }
class Gravity extends DotMatrixPreset { const Gravity(); }
class Glitch extends DotMatrixPreset { const Glitch(); }
class Diamond extends DotMatrixPreset { const Diamond(); }
class Checkerboard extends DotMatrixPreset { const Checkerboard(); }
class Breathe extends DotMatrixPreset { const Breathe(); }

/// Custom escape hatch — supply your own [DotAnimationFrame] delay map.
///
/// Example:
/// ```dart
/// CustomDotAnimation(
///   builder: (row, col, rows, cols, t) {
///     final delay = (row + col) / (rows + cols);
///     final localT = ((t - delay * 0.6).clamp(0.0, 1.0));
///     return DotState(opacity: localT, scale: 0.5 + 0.5 * localT);
///   },
/// )
/// ```
class CustomDotAnimation extends DotMatrixPreset {
  const CustomDotAnimation({required this.builder});

  /// The delay-map function for this custom animation.
  final DotAnimationFrame builder;
}

// ---------------------------------------------------------------------------
// Preset → DotAnimationFrame resolver
// ---------------------------------------------------------------------------

/// Resolves a [DotMatrixPreset] to its concrete [DotAnimationFrame] function.
///
/// Uses a Dart 3 switch expression for exhaustive, branchless dispatch.
DotAnimationFrame resolvePreset(DotMatrixPreset preset) {
  return switch (preset) {
    PulseRings()         => _pulseRings,
    Spiral()             => _spiral,
    Wave()               => _wave,
    CrossExpand()        => _crossExpand,
    Rain()               => _rain,
    Heartbeat()          => _heartbeat,
    Orbit()              => _orbit,
    Ripple()             => _ripple,
    Diagonal()           => _diagonal,
    Bounce()             => _bounce,
    Shockwave()          => _shockwave,
    Metronome()          => _metronome,
    Erosion()            => _erosion,
    Sonar()              => _sonar,
    Curtain()            => _curtain,
    Interference()       => _interference,
    Ticker()             => _ticker,
    Genome()             => _genome,
    StackFill()          => _stackFill,
    Veil()               => _veil,
    Radar()              => _radar,
    Scanner()            => _scanner,
    Collapse()           => _collapse,
    Static()             => _static,
    Wanderer()           => _wanderer,
    Crosshair()          => _crosshair,
    RippleIn()           => _rippleIn,
    Wipe()               => _wipe,
    Twinkle()            => _twinkle,
    ZigZag()             => _zigZag,
    Equalizer()          => _equalizer,
    Gravity()            => _gravity,
    Glitch()             => _glitch,
    Diamond()            => _diamond,
    Checkerboard()       => _checkerboard,
    Breathe()            => _breathe,
    CustomDotAnimation(:final builder) => builder,
  };
}

// ---------------------------------------------------------------------------
// Built-in frame functions
// ---------------------------------------------------------------------------

DotState _pulseRings(int row, int col, int rows, int cols, double t) {
  final cx = cols ~/ 2;
  final cy = rows ~/ 2;
  final dx = (col - cx).abs();
  final dy = (row - cy).abs();
  
  final dist = math.max(dx, dy);
  final maxDist = math.max(math.max(cx, cols - 1 - cx), math.max(cy, rows - 1 - cy));
  final totalSteps = maxDist + 1;
  
  if (totalSteps == 0) return const DotState(opacity: 1.0, scale: 1.0);
  
  final delay = dist / totalSteps;
  final delta = (t - delay + 1.0) % 1.0;
  final v = math.pow(math.max(0.0, 1.0 - delta * totalSteps.toDouble()), 2).toDouble();
  
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _spiral(int row, int col, int rows, int cols, double t) {
  final cx = cols ~/ 2;
  final cy = rows ~/ 2;
  final dx = col - cx;
  final dy = row - cy;
  
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
  
  final maxDx = math.max(cx, cols - 1 - cx);
  final maxDy = math.max(cy, rows - 1 - cy);
  final maxD = math.max(maxDx, maxDy);
  final totalSteps = (2 * maxD + 1) * (2 * maxD + 1);
  if (totalSteps == 0) return const DotState(opacity: 1.0, scale: 1.0);
  
  final delay = index / totalSteps;
  final progress = (t - delay) * totalSteps;
  final v = progress.clamp(0.0, 1.0);
  
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _wave(int row, int col, int rows, int cols, double t) {
  final freq = 1.5;
  final phase = col / cols;
  final v = (math.sin((t * 2 * math.pi) - (phase * 2 * math.pi * freq) +
          (row / rows * math.pi * 0.5)) +
      1) /
      2;
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _crossExpand(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final maxManhattan = ((cx).ceil() + (cy).ceil()).toDouble();
  final manhattan = ((col - cx).abs() + (row - cy).abs());
  final delay = maxManhattan > 0 ? manhattan / maxManhattan : 0.0;
  final localT = ((t - delay * 0.6) / (1 - delay * 0.6)).clamp(0.0, 1.0);
  final v = math.sin(localT * math.pi);
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _rain(int row, int col, int rows, int cols, double t) {
  // Each column has a seeded phase offset based on col index
  final phaseSeeds = [0.0, 0.31, 0.62, 0.17, 0.48, 0.79, 0.05, 0.36, 0.67, 0.23];
  final phase = phaseSeeds[col % phaseSeeds.length];
  final drop = ((t + phase) % 1.0);
  final rowT = row / (rows - 1);
  final v = (1.0 - ((rowT - drop).abs() * 3.0)).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _heartbeat(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final maxDist = math.sqrt(cx * cx + cy * cy);
  final dist = math.sqrt(
    math.pow(col - cx, 2) + math.pow(row - cy, 2),
  );
  final delay = maxDist > 0 ? dist / maxDist * 0.3 : 0.0;
  final localT = (t - delay).clamp(0.0, 1.0);
  // Double-pulse: sin + 0.4 * sin(2x)
  final beat = (math.sin(localT * 2 * math.pi) +
          0.4 * math.sin(localT * 4 * math.pi)) /
      1.4;
  final v = ((beat + 1) / 2).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _orbit(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(
    math.pow(col - cx, 2) + math.pow(row - cy, 2),
  );
  final angle = math.atan2(row - cy, col - cx);
  // Each ring orbits at a different speed
  final ringSpeed = 1.0 + (dist * 0.3);
  final rotatedAngle = angle - t * 2 * math.pi * ringSpeed;
  final v = ((math.cos(rotatedAngle * 2) + 1) / 2);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _ripple(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(
    math.pow(col - cx, 2) + math.pow(row - cy, 2),
  );
  final freq = 2.5;
  final v = ((math.sin(dist * freq - t * 2 * math.pi) + 1) / 2);
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _diagonal(int row, int col, int rows, int cols, double t) {
  final delay = (row + col) / ((rows - 1) + (cols - 1));
  final localT = ((t - delay * 0.5) / (1 - delay * 0.5)).clamp(0.0, 1.0);
  final v = math.sin(localT * math.pi);
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _bounce(int row, int col, int rows, int cols, double t) {
  final phase = col / cols;
  final localT = (t + phase) % 1.0;
  final rowPhase = (1.0 - row / (rows - 1).clamp(1, rows)) * 0.2;
  final v = (math.sin((localT + rowPhase) * math.pi)).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _shockwave(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
  final maxDist = math.sqrt(cx * cx + cy * cy);
  final normDist = maxDist > 0 ? dist / maxDist : 0.0;
  final front = t - normDist * 0.8;
  final localT = front.clamp(0.0, 1.0);
  final v = (math.exp(-localT * 4) * math.sin(localT * math.pi)).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _metronome(int row, int col, int rows, int cols, double t) {
  final swingX = (cols - 1) / 2.0 * (1.0 + math.cos(t * 2 * math.pi)) / 2.0;
  final dist = (col - swingX - row * 0.15).abs();
  final v = math.pow((1.0 - dist * 0.8).clamp(0.0, 1.0), 2).toDouble();
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _erosion(int row, int col, int rows, int cols, double t) {
  final diagIdx = (row + col) / ((rows - 1).clamp(1, rows) + (cols - 1).clamp(1, cols));
  double opacity = 0.0;
  if (t < 0.6) {
    final localT = t / 0.6;
    final edge0 = diagIdx - 0.1;
    final edge1 = diagIdx + 0.1;
    final x = edge0 == edge1 ? (localT >= edge0 ? 1.0 : 0.0) : ((localT - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    final smooth = x * x * (3 - 2 * x);
    opacity = 1.0 - smooth;
  } else {
    final localT = (t - 0.6) / 0.4;
    final edge0 = diagIdx - 0.1;
    final edge1 = diagIdx + 0.1;
    final x = edge0 == edge1 ? (localT >= edge0 ? 1.0 : 0.0) : ((localT - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    final smooth = x * x * (3 - 2 * x);
    opacity = smooth;
  }
  return DotState(opacity: opacity, scale: 0.3 + 0.7 * opacity);
}

DotState _sonar(int row, int col, int rows, int cols, double t) {
  final dist = math.sqrt(col * col + row * row);
  final maxDist = math.sqrt(math.pow(cols - 1, 2) + math.pow(rows - 1, 2));
  final normDist = maxDist > 0 ? dist / maxDist : 0.0;
  final pingT = t < 0.5 ? t * 2 : (1 - t) * 2;
  final delta = (pingT - normDist).abs();
  final v = math.max(0.0, 1.0 - delta * 6.0).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _curtain(int row, int col, int rows, int cols, double t) {
  final colStart = (cols > 1 ? col / (cols - 1) : 0.0) * 0.8;
  final rowStart = colStart + (rows > 1 ? row / (rows - 1) : 0.0) * 0.15;
  final edge0 = rowStart;
  final x = ((t - edge0) / 0.05).clamp(0.0, 1.0);
  final v = x * x * (3 - 2 * x);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _interference(int row, int col, int rows, int cols, double t) {
  final dist1 = math.sqrt(col * col + row * row);
  final dist2 = math.sqrt(math.pow(cols - 1 - col, 2) + math.pow(rows - 1 - row, 2));
  final maxDist = math.sqrt(math.pow(cols - 1, 2) + math.pow(rows - 1, 2));
  final norm1 = maxDist > 0 ? dist1 / maxDist : 0.0;
  final norm2 = maxDist > 0 ? dist2 / maxDist : 0.0;
  final v1 = math.sin(norm1 * math.pi * 3 - t * 2 * math.pi);
  final v2 = math.sin(norm2 * math.pi * 3 - t * 2 * math.pi * 1.1);
  final v = (((v1 + v2) / 2.0 + 1.0) / 2.0).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _ticker(int row, int col, int rows, int cols, double t) {
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
    return const DotState(opacity: 0.0, scale: 0.0);
  }
  
  final perimeterPos = pos / totalPerimeter;
  final delta = (t - perimeterPos + 1.0) % 1.0;
  final v = math.max(0.0, 1.0 - delta * 5.0).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _genome(int row, int col, int rows, int cols, double t) {
  final phase = ((row * 7 + col * 13) % 17) / 17.0;
  final freq1 = 1.0 + ((row * 3 + col * 5) % 7) / 14.0;
  final val = (math.sin(t * 2 * math.pi * freq1 + phase * 2 * math.pi) + 
               math.sin(t * 2 * math.pi * (freq1 + 0.3) + phase * math.pi)) / 2.0;
  final v = ((val + 1.0) / 2.0).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _stackFill(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final centerDist = cx > 0 ? (col - cx).abs() / cx : 0.0;
  final colSpeed = 0.5 + 0.5 * (1.0 - centerDist);
  final fillLevel = math.min(1.0, t * colSpeed / 0.8);
  final rowNorm = rows > 1 ? 1.0 - row / (rows - 1) : 1.0;
  final v = rowNorm <= fillLevel ? 1.0 : 0.0;
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _veil(int row, int col, int rows, int cols, double t) {
  final angle = t * 2 * math.pi;
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final projection = (col - cx) * math.cos(angle) + (row - cy) * math.sin(angle);
  final maxProjection = math.sqrt(cx * cx + cy * cy);
  final normalizedProj = maxProjection > 0 ? (projection / maxProjection + 1.0) / 2.0 : 0.5;
  final v = (math.sin(normalizedProj * math.pi)).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _radar(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final angle = math.atan2(row - cy, col - cx);
  final normAngle = (angle + math.pi) / (2 * math.pi);
  final delta = (t - normAngle + 1.0) % 1.0;
  final v = math.max(0.0, 1.0 - delta * 4.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _scanner(int row, int col, int rows, int cols, double t) {
  final scanRow = rows > 1 ? (math.sin(t * 2 * math.pi) + 1.0) / 2.0 * (rows - 1) : 0.0;
  final dist = (row - scanRow).abs();
  final v = math.max(0.0, 1.0 - dist * 1.5).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _collapse(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
  final maxDist = math.sqrt(cx * cx + cy * cy);
  final normDist = maxDist > 0 ? dist / maxDist : 0.0;
  final activeRadius = (1.0 - t);
  final diff = (normDist - activeRadius).abs();
  final v = math.max(0.0, 1.0 - diff * 5.0).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _static(int row, int col, int rows, int cols, double t) {
  final frame = (t * 20).floor();
  final hash = (row * 31 + col * 17 + frame * 13) % 100;
  final v = hash > 80 ? 1.0 : 0.0;
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _wanderer(int row, int col, int rows, int cols, double t) {
  final targetX = (math.sin(t * 2 * math.pi * 3) + 1.0) / 2.0 * (cols - 1);
  final targetY = (math.sin(t * 2 * math.pi * 4) + 1.0) / 2.0 * (rows - 1);
  final dist = math.sqrt(math.pow(col - targetX, 2) + math.pow(row - targetY, 2));
  final v = math.max(0.0, 1.0 - dist * 1.2).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _crosshair(int row, int col, int rows, int cols, double t) {
  final cx = (math.sin(t * 2 * math.pi) + 1.0) / 2.0 * (cols - 1);
  final cy = (math.cos(t * 2 * math.pi) + 1.0) / 2.0 * (rows - 1);
  final vX = math.max(0.0, 1.0 - (col - cx).abs() * 1.5);
  final vY = math.max(0.0, 1.0 - (row - cy).abs() * 1.5);
  final v = math.max(vX, vY).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _rippleIn(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
  final v = ((math.sin(dist * 2.5 + t * 2 * math.pi) + 1) / 2).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _wipe(int row, int col, int rows, int cols, double t) {
  final angle = t * math.pi * 2;
  final dotProj = col * math.cos(angle) + row * math.sin(angle);
  final midProj = (cols - 1)/2.0 * math.cos(angle) + (rows - 1)/2.0 * math.sin(angle);
  final v = (dotProj > midProj) ? 1.0 : 0.0;
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _twinkle(int row, int col, int rows, int cols, double t) {
  final phase = (row * 13 + col * 7) % 23 / 23.0;
  final speed = 1.0 + ((row * 5 + col * 11) % 7) / 7.0;
  final rawV = (math.sin(t * 2 * math.pi * speed + phase * 2 * math.pi) + 1.0) / 2.0;
  final v = math.pow(rawV, 4).toDouble().clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _equalizer(int row, int col, int rows, int cols, double t) {
  final freq1 = 1.0 + (col % 3) * 0.5;
  final freq2 = 1.5 + (col % 2) * 0.7;
  final phase = col * 0.5;
  
  final h = (math.sin(t * math.pi * 2 * freq1 + phase) + 
             math.sin(t * math.pi * 2 * freq2 - phase)) / 2.0;
             
  final normalizedHeight = (h + 1.0) / 2.0;
  final activeHeight = normalizedHeight * rows;
  final rowFromBottom = rows - 1 - row;
  
  double v = 0.0;
  if (rowFromBottom <= activeHeight) {
    v = 1.0;
  } else if (rowFromBottom - activeHeight < 1.0) {
    v = 1.0 - (rowFromBottom - activeHeight);
  }
  
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _gravity(int row, int col, int rows, int cols, double t) {
  final phase = col / cols;
  final localT = (t + phase) % 1.0;
  final bounceY = math.pow(math.sin(localT * math.pi), 1.5); 
  final targetRow = (1.0 - bounceY) * (rows - 1);
  final dist = (row - targetRow).abs();
  final v = math.max(0.0, 1.0 - dist * 1.5).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _glitch(int row, int col, int rows, int cols, double t) {
  final frame = (t * 15).floor();
  final shift = ((row * 17 + frame * 31) % 5) - 2;
  final virtualCol = col + shift;
  final noise = ((virtualCol * 13 + row * 7 + frame * 23) % 100);
  final v = noise > 85 ? 0.0 : 1.0;
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _diamond(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0;
  final cy = (rows - 1) / 2.0;
  final manhattan = (col - cx).abs() + (row - cy).abs();
  final maxDist = cx + cy;
  final normDist = maxDist > 0 ? manhattan / maxDist : 0.0;
  final delta = (t - normDist + 1.0) % 1.0;
  final v = math.pow(math.max(0.0, 1.0 - delta * 4.0), 2).toDouble();
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _checkerboard(int row, int col, int rows, int cols, double t) {
  final isEven = (row + col) % 2 == 0;
  final phase = isEven ? 0.0 : 0.5;
  final val = (math.sin((t + phase) * 2 * math.pi) + 1.0) / 2.0;
  return DotState(opacity: val, scale: 0.3 + 0.7 * val);
}

DotState _breathe(int row, int col, int rows, int cols, double t) {
  final sine = (math.sin(t * 2 * math.pi - math.pi / 2) + 1.0) / 2.0;
  final val = math.pow(sine, 2.5).toDouble();
  return DotState(opacity: val, scale: 0.3 + 0.7 * val);
}

DotState _zigZag(int row, int col, int rows, int cols, double t) {
  final totalDots = rows * cols;
  if (totalDots == 0) return const DotState(opacity: 0.0, scale: 0.0);
  final litIndex = (t * totalDots).floor();
  final c = (row % 2 == 0) ? col : (cols - 1 - col);
  final myIndex = row * cols + c;
  final diff = litIndex - myIndex;
  final v = (diff >= 0 && diff < 4) ? (1.0 - diff * 0.25).clamp(0.0, 1.0) : 0.0;
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}
