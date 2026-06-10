import 'dart:math' as math;

/// Immutable animated state for a single dot, resolved each frame.
class DotState {
  const DotState({this.opacity = 1.0, this.scale = 1.0});
  final double opacity;
  final double scale;
}

typedef DotAnimationFrame = DotState Function(
  int row,
  int col,
  int rows,
  int cols,
  double t,
);

sealed class DotMatrixPreset {
  const DotMatrixPreset();
}

class PulseRings extends DotMatrixPreset { const PulseRings(); }
class Spiral extends DotMatrixPreset { const Spiral(); }
class Wave extends DotMatrixPreset { const Wave(); }
class CrossExpand extends DotMatrixPreset { const CrossExpand(); }
class Rain extends DotMatrixPreset { const Rain(); }
class Heartbeat extends DotMatrixPreset { const Heartbeat(); }
class Orbit extends DotMatrixPreset { const Orbit(); }
class Ripple extends DotMatrixPreset { const Ripple(); }
class Diagonal extends DotMatrixPreset { const Diagonal(); }
class Bounce extends DotMatrixPreset { const Bounce(); }
class Shockwave extends DotMatrixPreset { const Shockwave(); }
class Metronome extends DotMatrixPreset { const Metronome(); }
class Erosion extends DotMatrixPreset { const Erosion(); }
class Sonar extends DotMatrixPreset { const Sonar(); }
class Curtain extends DotMatrixPreset { const Curtain(); }
class Interference extends DotMatrixPreset { const Interference(); }
class Ticker extends DotMatrixPreset { const Ticker(); }
class Genome extends DotMatrixPreset { const Genome(); }
class StackFill extends DotMatrixPreset { const StackFill(); }
class Veil extends DotMatrixPreset { const Veil(); }
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
class MatrixRain extends DotMatrixPreset { const MatrixRain(); }
class PingPong extends DotMatrixPreset { const PingPong(); }
class FadingGrid extends DotMatrixPreset { const FadingGrid(); }
class CrossSlide extends DotMatrixPreset { const CrossSlide(); }
class ConcentricBoxes extends DotMatrixPreset { const ConcentricBoxes(); }
class DNAHelix extends DotMatrixPreset { const DNAHelix(); }
class HeartbeatDouble extends DotMatrixPreset { const HeartbeatDouble(); }
class Fireworks extends DotMatrixPreset { const Fireworks(); }
class ExpandingPolygons extends DotMatrixPreset { const ExpandingPolygons(); }
class SinePlasma extends DotMatrixPreset { const SinePlasma(); }
class CellularAutomaton extends DotMatrixPreset { const CellularAutomaton(); }
class Supernova extends DotMatrixPreset { const Supernova(); }
class Vortex extends DotMatrixPreset { const Vortex(); }
class InfinityLoop extends DotMatrixPreset { const InfinityLoop(); }
class LiquidFluid extends DotMatrixPreset { const LiquidFluid(); }
class TetrisDrop extends DotMatrixPreset { const TetrisDrop(); }
class LaserSweep extends DotMatrixPreset { const LaserSweep(); }
class Starfield extends DotMatrixPreset { const Starfield(); }
class BarChart extends DotMatrixPreset { const BarChart(); }
class Labyrinth extends DotMatrixPreset { const Labyrinth(); }
class PacmanChase extends DotMatrixPreset { const PacmanChase(); }
class SineWaveMultiply extends DotMatrixPreset { const SineWaveMultiply(); }
class PulseWave extends DotMatrixPreset { const PulseWave(); }
class Hourglass extends DotMatrixPreset { const Hourglass(); }
class LoadingArc extends DotMatrixPreset { const LoadingArc(); }


class CustomDotAnimation extends DotMatrixPreset {
  const CustomDotAnimation({required this.builder});
  final DotAnimationFrame builder;
}

class SequenceAnimation extends DotMatrixPreset {
  const SequenceAnimation({required this.frames});
  final List<List<List<bool>>> frames;
}

DotAnimationFrame resolvePreset(DotMatrixPreset preset) {
  return switch (preset) {
    PulseRings() => _pulseRings,
    Spiral() => _spiral,
    Wave() => _wave,
    CrossExpand() => _crossExpand,
    Rain() => _rain,
    Heartbeat() => _heartbeat,
    Orbit() => _orbit,
    Ripple() => _ripple,
    Diagonal() => _diagonal,
    Bounce() => _bounce,
    Shockwave() => _shockwave,
    Metronome() => _metronome,
    Erosion() => _erosion,
    Sonar() => _sonar,
    Curtain() => _curtain,
    Interference() => _interference,
    Ticker() => _ticker,
    Genome() => _genome,
    StackFill() => _stackFill,
    Veil() => _veil,
    Radar() => _radar,
    Scanner() => _scanner,
    Collapse() => _collapse,
    Static() => _static,
    Wanderer() => _wanderer,
    Crosshair() => _crosshair,
    RippleIn() => _rippleIn,
    Wipe() => _wipe,
    Twinkle() => _twinkle,
    ZigZag() => _zigZag,
    Equalizer() => _equalizer,
    Gravity() => _gravity,
    Glitch() => _glitch,
    Diamond() => _diamond,
    Checkerboard() => _checkerboard,
    Breathe() => _breathe,
    MatrixRain() => _matrixRain,
    PingPong() => _pingPong,
    FadingGrid() => _fadingGrid,
    CrossSlide() => _crossSlide,
    ConcentricBoxes() => _concentricBoxes,
    DNAHelix() => _dnaHelix,
    HeartbeatDouble() => _heartbeatDouble,
    Fireworks() => _fireworks,
    ExpandingPolygons() => _expandingPolygons,
    SinePlasma() => _sinePlasma,
    CellularAutomaton() => _cellularAutomaton,
    Supernova() => _supernova,
    Vortex() => _vortex,
    InfinityLoop() => _infinityLoop,
    LiquidFluid() => _liquidFluid,
    TetrisDrop() => _tetrisDrop,
    LaserSweep() => _laserSweep,
    Starfield() => _starfield,
    BarChart() => _barChart,
    Labyrinth() => _labyrinth,
    PacmanChase() => _pacmanChase,
    SineWaveMultiply() => _sineWaveMultiply,
    PulseWave() => _pulseWave,
    Hourglass() => _hourglass,
    LoadingArc() => _loadingArc,
    CustomDotAnimation(:final builder) => builder,
    SequenceAnimation(:final frames) => (row, col, rows, cols, t) {
        if (frames.isEmpty) return const DotState(opacity: 0, scale: 0);
        final frameIndex = (t * frames.length).floor().clamp(0, frames.length - 1);
        final frame = frames[frameIndex];
        if (row >= frame.length || col >= frame[0].length) return const DotState(opacity: 0, scale: 0);
        final isActive = frame[row][col];
        return DotState(opacity: isActive ? 1.0 : 0.0, scale: isActive ? 1.0 : 0.0);
      },
  };
}

DotState _pulseRings(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
  final maxDist = math.sqrt(cx * cx + cy * cy);
  final delay = maxDist > 0 ? dist / maxDist : 0.0;
  final localT = ((t - delay * 0.6) / (1 - delay * 0.6)).clamp(0.0, 1.0);
  final v = math.sin(localT * math.pi);
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _spiral(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final angle = math.atan2(row - cy, col - cx);
  final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
  final normalizedAngle = (angle + math.pi) / (2 * math.pi);
  final delay = (normalizedAngle * 0.5 + (dist / (cx + cy)) * 0.5);
  final localT = ((t - delay * 0.5) / (1 - delay * 0.5)).clamp(0.0, 1.0);
  final v = math.sin(localT * math.pi);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _wave(int row, int col, int rows, int cols, double t) {
  final phase = col / cols;
  final v = (math.sin((t * 2 * math.pi) - (phase * 2 * math.pi * 1.5) + (row / rows * math.pi * 0.5)) + 1) / 2;
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _crossExpand(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final manhattan = (col - cx).abs() + (row - cy).abs();
  final delay = manhattan / (cx + cy);
  final localT = ((t - delay * 0.6) / (1 - delay * 0.6)).clamp(0.0, 1.0);
  return DotState(opacity: math.sin(localT * math.pi), scale: 0.4 + 0.6 * math.sin(localT * math.pi));
}

DotState _rain(int row, int col, int rows, int cols, double t) {
  final seeds = [0.0, 0.31, 0.62, 0.17, 0.48, 0.79, 0.05, 0.36, 0.67, 0.23];
  final drop = ((t + seeds[col % seeds.length]) % 1.0);
  final v = (1.0 - ((row / rows - drop).abs() * 3.0)).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _heartbeat(int row, int col, int rows, int cols, double t) {
  final dist = math.sqrt(math.pow(col - (cols-1)/2, 2) + math.pow(row - (rows-1)/2, 2));
  final localT = (t - dist * 0.05).clamp(0.0, 1.0);
  final beat = (math.sin(localT * 2 * math.pi) + 0.4 * math.sin(localT * 4 * math.pi)) / 1.4;
  final v = ((beat + 1) / 2).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _orbit(int row, int col, int rows, int cols, double t) {
  final dx = col - (cols-1)/2.0; final dy = row - (rows-1)/2.0;
  final dist = math.sqrt(dx*dx + dy*dy);
  final angle = math.atan2(dy, dx);
  // To ensure the animation is mathematically continuous when it loops from t = 1.0 back to 0.0,
  // the frequency multiplier of t must be an integer. Moving the distance factor to the phase offset 
  // (outside of the t term) creates a gorgeous, perfectly seamless spiraling orbit loop without stutters.
  final v = ((math.cos(angle - t * 2 * math.pi - dist * 0.6) * 2 + 1) / 2).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _ripple(int row, int col, int rows, int cols, double t) {
  final dist = math.sqrt(math.pow(col - (cols-1)/2.0, 2) + math.pow(row - (rows-1)/2.0, 2));
  final v = ((math.sin(dist * 2.5 - t * 2 * math.pi) + 1) / 2);
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _diagonal(int row, int col, int rows, int cols, double t) {
  final delay = (row + col) / (rows + cols);
  final localT = ((t - delay * 0.5) / (1 - delay * 0.5)).clamp(0.0, 1.0);
  return DotState(opacity: math.sin(localT * math.pi), scale: 0.4 + 0.6 * math.sin(localT * math.pi));
}

DotState _bounce(int row, int col, int rows, int cols, double t) {
  final localT = (t + col/cols) % 1.0;
  final v = (math.sin((localT + (1-row/rows)*0.2) * math.pi)).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _shockwave(int row, int col, int rows, int cols, double t) {
  final dist = math.sqrt(math.pow(col - (cols-1)/2, 2) + math.pow(row - (rows-1)/2, 2));
  final v = math.pow(math.sin((dist/10 - t) * 10).clamp(0.0, 1.0), 3).toDouble();
  return DotState(opacity: v, scale: 0.2 + 0.8 * v);
}

DotState _metronome(int row, int col, int rows, int cols, double t) {
  final angle = math.sin(t * 2 * math.pi) * 0.5;
  final dx = col - (cols-1)/2.0; final dy = row.toDouble();
  final rotatedX = dx * math.cos(angle) - dy * math.sin(angle);
  final v = math.pow(math.max(0, 1 - (rotatedX.abs() * 0.5)), 4).toDouble();
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _erosion(int row, int col, int rows, int cols, double t) {
  final noise = (math.sin(row * 1.5 + col * 2.1 + t * 5) + 1) / 2;
  final v = noise > (math.sin(t * 2 * math.pi) + 1) / 2 ? 1.0 : 0.0;
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _sonar(int row, int col, int rows, int cols, double t) {
  final dist = math.sqrt(math.pow(col - (cols-1)/2, 2) + math.pow(row - (rows-1), 2));
  final maxD = math.sqrt(math.pow((cols-1)/2, 2) + math.pow(rows-1, 2));
  final v = math.pow((1.0 - (t - dist/maxD).clamp(0.0, 1.0)), 4).toDouble();
  return t > dist/maxD ? DotState(opacity: v, scale: 0.3 + 0.7 * v) : const DotState(opacity: 0, scale: 0.3);
}

DotState _curtain(int row, int col, int rows, int cols, double t) {
  final v = math.sin((t - (col/cols)*0.5).clamp(0.0, 1.0) * math.pi);
  return DotState(opacity: v, scale: 1.0 - (row/rows * (1-v)));
}

DotState _interference(int row, int col, int rows, int cols, double t) {
  final v = ((math.sin(row*0.5 + t*10) + math.sin(col*0.5 - t*8)) / 2 + 1) / 2;
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _ticker(int row, int col, int rows, int cols, double t) {
  final isMe = (col + t*cols*2).floor() % cols == col;
  return DotState(opacity: isMe ? 1.0 : 0.1, scale: isMe ? 1.0 : 0.5);
}

DotState _genome(int row, int col, int rows, int cols, double t) {
  final wave = (math.sin(t*2*math.pi + (row/rows)*math.pi*2) + 1) / 2;
  final v = math.pow(math.max(0, 1 - (col - (wave*cols)).abs()), 2).toDouble();
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _stackFill(int row, int col, int rows, int cols, double t) {
  final target = (rows-1) - (t*rows).floor();
  if (row > target) return const DotState(opacity: 1, scale: 1);
  if (row < target) return const DotState(opacity: 0, scale: 0.3);
  final p = (t*rows) % 1.0; return DotState(opacity: p, scale: 0.3 + 0.7 * p);
}

DotState _veil(int row, int col, int rows, int cols, double t) {
  final v = math.sin(t*math.pi + (row+col)*0.1).abs();
  return DotState(opacity: v, scale: 0.5 + 0.5 * v);
}

DotState _radar(int row, int col, int rows, int cols, double t) {
  final angle = math.atan2(row-(rows-1)/2.0, col-(cols-1)/2.0);
  final sweep = (angle/(2*math.pi) + 0.5 - t) % 1.0;
  final v = math.pow(1.0 - sweep, 8).toDouble();
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _scanner(int row, int col, int rows, int cols, double t) {
  final pos = (math.sin(t*2*math.pi)+1)/2 * (rows-1);
  final v = math.pow(math.max(0, 1 - (row-pos).abs()), 2).toDouble();
  return DotState(opacity: v, scale: 0.5 + 0.5 * v);
}

DotState _collapse(int row, int col, int rows, int cols, double t) {
  final dist = math.sqrt(math.pow(col-(cols-1)/2, 2) + math.pow(row-(rows-1)/2, 2));
  final maxD = math.sqrt(math.pow((cols-1)/2, 2) + math.pow((rows-1)/2, 2));
  final v = dist < (1-t)*maxD ? 1.0 : 0.0; return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _static(int row, int col, int rows, int cols, double t) {
  final r = math.Random((row*31 + col*7 + (t*100).floor()).toInt()).nextDouble();
  return DotState(opacity: r, scale: 0.5 + 0.5 * r);
}

DotState _wanderer(int row, int col, int rows, int cols, double t) {
  final px = (math.sin(t*3)+1)/2 * (cols-1); final py = (math.cos(t*5)+1)/2 * (rows-1);
  final v = math.pow(math.max(0, 1 - math.sqrt(math.pow(col-px, 2) + math.pow(row-py, 2))/2), 2).toDouble();
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _crosshair(int row, int col, int rows, int cols, double t) {
  final isC = (col-(cols-1)/2.0).abs() < 0.5 || (row-(rows-1)/2.0).abs() < 0.5;
  final v = isC ? math.sin(t*2*math.pi).abs() : 0.05; return DotState(opacity: v, scale: 0.5 + 0.5 * v);
}

DotState _rippleIn(int row, int col, int rows, int cols, double t) {
  final dist = math.sqrt(math.pow(col-(cols-1)/2.0, 2) + math.pow(row-(rows-1)/2.0, 2));
  final v = math.sin(dist - (1-t)*10).clamp(0.0, 1.0); return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _wipe(int row, int col, int rows, int cols, double t) {
  final v = (col/cols < t) ? 1.0 : 0.0; return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _twinkle(int row, int col, int rows, int cols, double t) {
  final v = math.sin((t + (row*13+col*7)%100/100.0) * 2 * math.pi).abs();
  return DotState(opacity: v > 0.8 ? v : 0.1, scale: v > 0.8 ? 1.0 : 0.5);
}

DotState _zigZag(int row, int col, int rows, int cols, double t) {
  final cur = (t * rows * cols).floor() % (rows * cols);
  final r = cur ~/ cols; final c = (r % 2 == 0) ? (cur % cols) : (cols - 1 - (cur % cols));
  final isMe = (row == r && col == c); return DotState(opacity: isMe ? 1.0 : 0.1, scale: isMe ? 1.0 : 0.5);
}

DotState _equalizer(int row, int col, int rows, int cols, double t) {
  final h = (math.sin(t*2*math.pi + col*0.5)+1)/2 * rows;
  final v = (rows-row < h) ? 1.0 : 0.1; return DotState(opacity: v, scale: v == 1.0 ? 1.0 : 0.5);
}

DotState _gravity(int row, int col, int rows, int cols, double t) {
  final r = ((t + col*0.1) % 1.0 * rows).floor();
  final isMe = (row == r); return DotState(opacity: isMe ? 1.0 : 0.0, scale: isMe ? 1.0 : 0.3);
}

DotState _glitch(int row, int col, int rows, int cols, double t) {
  final v = math.Random((t*15).floor() + row).nextDouble() > 0.8 ? 1.0 : 0.05;
  return DotState(opacity: v, scale: v);
}

DotState _diamond(int row, int col, int rows, int cols, double t) {
  final v = math.sin(((col-(cols-1)/2.0).abs() + (row-(rows-1)/2.0).abs()) * 0.8 - t*2*math.pi).abs();
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _checkerboard(int row, int col, int rows, int cols, double t) {
  final v = (row+col)%2==0 ? math.sin(t*2*math.pi).abs() : math.cos(t*2*math.pi).abs();
  return DotState(opacity: v, scale: 0.5 + 0.5 * v);
}

DotState _breathe(int row, int col, int rows, int cols, double t) {
  final v = (math.sin(t*2*math.pi)+1)/2; return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _matrixRain(int row, int col, int rows, int cols, double t) {
  final colOffset = math.sin(col * 3.0 + 1.0) * 0.5 + 0.5;
  final speed = 0.8 + 0.4 * colOffset;
  final localT = (t * speed + colOffset) % 1.0;
  final headRow = (localT * (rows + 4)) - 2;
  final dist = row - headRow;
  if (dist > 0) return const DotState(opacity: 0, scale: 0.3);
  final v = math.exp(dist * 0.8).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _pingPong(int row, int col, int rows, int cols, double t) {
  final tx = (t * 2 % 2.0 - 1.0).abs();
  final ty = (t * 3 % 2.0 - 1.0).abs();
  final targetCol = tx * (cols - 1);
  final targetRow = ty * (rows - 1);
  final dist = math.sqrt(math.pow(col - targetCol, 2) + math.pow(row - targetRow, 2));
  final v = math.max(0.0, 1.0 - dist * 1.2);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _fadingGrid(int row, int col, int rows, int cols, double t) {
  final group = (row + col) % 2;
  final v = group == 0 ? (math.sin(t * 2 * math.pi) + 1) / 2 : (math.cos(t * 2 * math.pi) + 1) / 2;
  return DotState(opacity: v, scale: 0.4 + 0.6 * v);
}

DotState _crossSlide(int row, int col, int rows, int cols, double t) {
  final slideCol = (t * cols).floor() % cols;
  final slideRow = ((1.0 - t) * rows).floor() % rows;
  final isMe = (col == slideCol || row == slideRow);
  final v = isMe ? 1.0 : 0.08;
  return DotState(opacity: v, scale: isMe ? 1.0 : 0.4);
}

DotState _concentricBoxes(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final chebyshev = math.max((col - cx).abs(), (row - cy).abs());
  final maxDist = math.max(cx, cy);
  final delay = maxDist > 0 ? chebyshev / maxDist : 0.0;
  final v = math.sin((t - delay * 0.5) * 2 * math.pi).abs();
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _dnaHelix(int row, int col, int rows, int cols, double t) {
  final normalizedRow = row / rows;
  final angle = t * 2 * math.pi + normalizedRow * 2 * math.pi;
  final center = (cols - 1) / 2.0;
  final amplitude = (cols - 1) * 0.45;
  final pos1 = center + math.sin(angle) * amplitude;
  final pos2 = center - math.sin(angle) * amplitude;
  final d1 = (col - pos1).abs();
  final d2 = (col - pos2).abs();
  final v = math.max(math.max(0.0, 1.0 - d1 * 1.5), math.max(0.0, 1.0 - d2 * 1.5));
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _heartbeatDouble(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
  final maxDist = math.sqrt(cx * cx + cy * cy);
  final delay = maxDist > 0 ? dist / maxDist : 0.0;
  final pulseT = (t - delay * 0.15) % 1.0;
  double v = 0.0;
  if (pulseT < 0.15) {
    v = math.sin((pulseT / 0.15) * math.pi);
  } else if (pulseT >= 0.2 && pulseT < 0.4) {
    v = 0.6 * math.sin(((pulseT - 0.2) / 0.2) * math.pi);
  }
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _fireworks(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  if (t < 0.4) {
    final riseT = t / 0.4;
    final targetRow = (rows - 1) - riseT * (rows - 1 - cy);
    final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - targetRow, 2));
    final v = math.max(0.0, 1.0 - dist * 1.5);
    return DotState(opacity: v, scale: 0.4 + 0.6 * v);
  } else {
    final explT = (t - 0.4) / 0.6;
    final r = explT * (cx + cy);
    final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
    final diff = (dist - r).abs();
    final edgeFade = 1.0 - explT;
    final v = (math.max(0.0, 1.0 - diff * 2.0) * edgeFade).clamp(0.0, 1.0);
    return DotState(opacity: v, scale: 0.3 + 0.7 * v);
  }
}

DotState _expandingPolygons(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final dist = (col - cx).abs() + (row - cy).abs() * 0.8;
  final v = math.sin(dist - t * 2 * math.pi).abs();
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _sinePlasma(int row, int col, int rows, int cols, double t) {
  final nx = col / cols; final ny = row / rows;
  final v1 = math.sin(nx * 5.0 + t * 2 * math.pi);
  final v2 = math.cos(ny * 4.0 - t * 2 * math.pi);
  final v3 = math.sin((nx + ny) * 3.0 + t * 2 * math.pi * 1.5);
  final v = ((v1 + v2 + v3) / 3.0 + 1.0) / 2.0;
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _cellularAutomaton(int row, int col, int rows, int cols, double t) {
  final step = (t * 4).floor() % 4;
  final activeGrid = switch (step) {
    0 => [
        [false, true, false],
        [false, false, true],
        [true, true, true]
      ],
    1 => [
        [true, false, true],
        [false, true, true],
        [false, true, false]
      ],
    2 => [
        [false, false, true],
        [true, false, true],
        [false, true, true]
      ],
    _ => [
        [true, true, false],
        [true, false, true],
        [false, false, true]
      ],
  };
  final r = row % 3; final c = col % 3;
  final isActive = activeGrid[r][c];
  final v = isActive ? 1.0 : 0.1;
  return DotState(opacity: v, scale: isActive ? 1.0 : 0.4);
}

DotState _supernova(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
  final maxDist = math.sqrt(cx * cx + cy * cy);
  if (t < 0.5) {
    final implodeT = t / 0.5;
    final r = (1.0 - implodeT) * maxDist;
    final diff = (dist - r).abs();
    final v = math.max(0.0, 1.0 - diff * 1.5);
    return DotState(opacity: v, scale: 0.3 + 0.7 * v);
  } else {
    final explodeT = (t - 0.5) / 0.5;
    final r = explodeT * maxDist * 1.5;
    final diff = (dist - r).abs();
    final fade = 1.0 - explodeT;
    final v = (math.max(0.0, 1.0 - diff * 1.8) * fade).clamp(0.0, 1.0);
    return DotState(opacity: v, scale: 0.4 + 0.6 * v);
  }
}

DotState _vortex(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final dx = col - cx; final dy = row - cy;
  final dist = math.sqrt(dx*dx + dy*dy);
  final angle = math.atan2(dy, dx);
  final speedMult = dist > 0 ? (1.0 / (dist + 0.5)) * 3.0 : 1.0;
  final v = ((math.sin(angle - t * 2 * math.pi * speedMult) + 1.0) / 2.0);
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _infinityLoop(int row, int col, int rows, int cols, double t) {
  final angle = t * 2 * math.pi;
  final targetX = ((math.sin(angle) + 1.0) / 2.0) * (cols - 1);
  final targetY = ((math.sin(2.0 * angle) + 1.0) / 2.0) * (rows - 1);
  final dist = math.sqrt(math.pow(col - targetX, 2) + math.pow(row - targetY, 2));
  final v = math.max(0.0, 1.0 - dist * 1.2);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _liquidFluid(int row, int col, int rows, int cols, double t) {
  final nx = col / cols; final ny = row / rows;
  final v = (math.sin(nx * 3.0 + t * 2 * math.pi) * math.cos(ny * 3.0 + t * 2 * math.pi) + 1.0) / 2.0;
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _tetrisDrop(int row, int col, int rows, int cols, double t) {
  final cycleT = t % 1.0;
  final activeCol = (col % 4) < 2;
  if (cycleT < 0.7) {
    final fallT = cycleT / 0.7;
    final headRow = (fallT * (rows + 2)).floor();
    final isFalling = activeCol && (row == headRow || row == headRow - 1);
    final isAtBottom = !activeCol && row >= rows - 2;
    final isMe = isFalling || isAtBottom;
    final v = isMe ? 1.0 : 0.1;
    return DotState(opacity: v, scale: isMe ? 1.0 : 0.4);
  } else {
    final blink = ((cycleT - 0.7) * 10).floor() % 2 == 0;
    final isMe = activeCol ? (row >= rows - 2 && blink) : (row >= rows - 2);
    final v = isMe ? 1.0 : 0.1;
    return DotState(opacity: v, scale: isMe ? 1.0 : 0.4);
  }
}

DotState _laserSweep(int row, int col, int rows, int cols, double t) {
  final sweepT = (math.sin(t * 2 * math.pi) + 1.0) / 2.0;
  final targetCol = sweepT * cols;
  final dist = (col - targetCol).abs();
  final v = math.max(0.05, 1.0 - dist * 1.5);
  return DotState(opacity: v, scale: v);
}

DotState _starfield(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final dx = col - cx; final dy = row - cy;
  final angle = math.atan2(dy, dx);
  final startOffset = (col * 31 + row * 17) % 50 / 50.0;
  final starT = (t + startOffset) % 1.0;
  final speed = starT * math.max(cx, cy) * 1.2;
  final targetX = cx + math.cos(angle) * speed;
  final targetY = cy + math.sin(angle) * speed;
  final d = math.sqrt(math.pow(col - targetX, 2) + math.pow(row - targetY, 2));
  final v = (math.max(0.0, 1.0 - d * 1.5) * starT).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _barChart(int row, int col, int rows, int cols, double t) {
  final phase = col * 0.7;
  final h = ((math.sin(t * 2 * math.pi + phase) * math.cos(t * 4 * math.pi - phase) + 1.0) / 2.0) * rows;
  final isMe = (rows - 1 - row) < h;
  final v = isMe ? 1.0 : 0.1;
  return DotState(opacity: v, scale: isMe ? 1.0 : 0.4);
}

DotState _labyrinth(int row, int col, int rows, int cols, double t) {
  final cycle = (t * 4).floor() % 4;
  final isCorridor = switch (cycle) {
    0 => (row % 2 == 0 && col % 3 != 0) || (col % 2 == 0 && row % 3 != 0),
    1 => (row % 3 == 0) || (col % 2 == 0),
    2 => (col % 3 == 0) || (row % 2 == 0),
    _ => (row + col) % 3 == 0 || row % 2 == 0,
  };
  final v = isCorridor ? 1.0 : 0.05;
  return DotState(opacity: v, scale: isCorridor ? 1.0 : 0.3);
}

DotState _pacmanChase(int row, int col, int rows, int cols, double t) {
  final perimeter = 2 * (rows + cols - 2);
  if (perimeter <= 0) return const DotState(opacity: 0, scale: 0);
  int idx = -1;
  if (row == 0) {
    idx = col;
  } else if (col == cols - 1) {
    idx = (cols - 1) + row;
  } else if (row == rows - 1) {
    idx = (cols - 1) + (rows - 1) + (cols - 1 - col);
  } else if (col == 0) {
    idx = 2 * (cols - 1) + (rows - 1) + (rows - 1 - row);
  }
  if (idx == -1) return const DotState(opacity: 0.05, scale: 0.3);
  final pacPos = (t * perimeter).floor() % perimeter;
  final ghostPos = (pacPos - 3 + perimeter) % perimeter;
  if (idx == pacPos) {
    return const DotState(opacity: 1.0, scale: 1.0);
  } else if (idx == ghostPos) {
    return const DotState(opacity: 0.8, scale: 0.7);
  } else if ((idx - pacPos) % 2 == 0) {
    return const DotState(opacity: 0.5, scale: 0.4);
  } else {
    return const DotState(opacity: 0.1, scale: 0.3);
  }
}

DotState _sineWaveMultiply(int row, int col, int rows, int cols, double t) {
  final v1 = math.sin((col / cols) * 2 * math.pi + t * 2 * math.pi);
  final v2 = math.sin((row / rows) * 2 * math.pi - t * 2 * math.pi);
  final v = ((v1 * v2) + 1.0) / 2.0;
  return DotState(opacity: v, scale: 0.35 + 0.65 * v);
}

DotState _pulseWave(int row, int col, int rows, int cols, double t) {
  final sweepCol = t * (cols + 4) - 2;
  final dist = (col - sweepCol).abs();
  final v = math.exp(-dist * dist * 1.5).clamp(0.0, 1.0);
  return DotState(opacity: v, scale: 0.3 + 0.7 * v);
}

DotState _hourglass(int row, int col, int rows, int cols, double t) {
  final isTop = row < rows / 2;
  if (t < 0.5) {
    final stageT = t / 0.5;
    if (isTop) {
      final threshold = (stageT * (rows / 2)).floor();
      final isFilled = row >= threshold;
      final v = isFilled ? 1.0 : 0.1;
      return DotState(opacity: v, scale: isFilled ? 1.0 : 0.4);
    } else {
      final threshold = (rows - 1) - (stageT * (rows / 2)).floor();
      final isFilled = row >= threshold;
      final v = isFilled ? 1.0 : 0.1;
      return DotState(opacity: v, scale: isFilled ? 1.0 : 0.4);
    }
  } else {
    final stageT = (t - 0.5) / 0.5;
    if (isTop) {
      final threshold = (rows / 2) - 1 - (stageT * (rows / 2)).floor();
      final isFilled = row <= threshold;
      final v = isFilled ? 1.0 : 0.1;
      return DotState(opacity: v, scale: isFilled ? 1.0 : 0.4);
    } else {
      final threshold = (rows / 2) + (stageT * (rows / 2)).floor();
      final isFilled = row <= threshold;
      final v = isFilled ? 1.0 : 0.1;
      return DotState(opacity: v, scale: isFilled ? 1.0 : 0.4);
    }
  }
}

DotState _loadingArc(int row, int col, int rows, int cols, double t) {
  final cx = (cols - 1) / 2.0; final cy = (rows - 1) / 2.0;
  final dx = col - cx; final dy = row - cy;
  final dist = math.sqrt(dx*dx + dy*dy);
  final angle = math.atan2(dy, dx);
  final normalizedAngle = (angle + math.pi) / (2 * math.pi);
  final sweepAngle = (normalizedAngle - t) % 1.0;
  final v = sweepAngle < 0.4 ? (1.0 - sweepAngle / 0.4) : 0.05;
  final maxD = math.sqrt(cx*cx + cy*cy);
  final onBorder = dist >= maxD * 0.7;
  final finalV = onBorder ? v : 0.05;
  return DotState(opacity: finalV, scale: onBorder ? 0.4 + 0.6 * finalV : 0.3);
}
