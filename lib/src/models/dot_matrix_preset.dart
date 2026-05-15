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
  final v = ((math.cos(angle - t * 2 * math.pi * (1 + dist * 0.3)) * 2 + 1) / 2).clamp(0.0, 1.0);
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
  return t > dist/maxD ? DotState(opacity: v, scale: v) : const DotState(opacity: 0, scale: 0);
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
  if (row < target) return const DotState(opacity: 0, scale: 0);
  final p = (t*rows) % 1.0; return DotState(opacity: p, scale: p);
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
  final v = dist < (1-t)*maxD ? 1.0 : 0.0; return DotState(opacity: v, scale: v);
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
  final v = (col/cols < t) ? 1.0 : 0.0; return DotState(opacity: v, scale: v);
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
  final isMe = (row == r); return DotState(opacity: isMe ? 1.0 : 0.0, scale: isMe ? 1.0 : 0.0);
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
