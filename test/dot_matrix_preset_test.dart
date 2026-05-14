import 'package:flutter_test/flutter_test.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';

void main() {
  group('DotMatrixPreset Algorithm Validation', () {
    const presets = [
      PulseRings(), Spiral(), Wave(), CrossExpand(), Rain(), Heartbeat(),
      Orbit(), Ripple(), Diagonal(), Bounce(), Shockwave(), Metronome(),
      Erosion(), Sonar(), Curtain(), Interference(), Ticker(), Genome(),
      StackFill(), Veil(), Radar(), Scanner(), Collapse(), Static(),
      Wanderer(), Crosshair(), RippleIn(), Wipe(), Twinkle(), ZigZag(),
      Equalizer(), Gravity(), Glitch(), Diamond(), Checkerboard(), Breathe(),
    ];

    for (final preset in presets) {
      test('${preset.runtimeType} should return valid DotState', () {
        final animation = resolvePreset(preset);
        
        // Test various points in time and space
        final testPoints = [
          (row: 0, col: 0, t: 0.0),
          (row: 2, col: 2, t: 0.5),
          (row: 4, col: 4, t: 1.0),
        ];

        for (final p in testPoints) {
          final state = animation(p.row, p.col, 5, 5, p.t);
          
          // Verify opacity is in [0, 1] range
          expect(state.opacity, greaterThanOrEqualTo(0.0), 
              reason: 'Opacity should be >= 0.0 at t=${p.t}');
          expect(state.opacity, lessThanOrEqualTo(1.0), 
              reason: 'Opacity should be <= 1.0 at t=${p.t}');
          
          // Verify scale is in [0, 1] range
          expect(state.scale, greaterThanOrEqualTo(0.0), 
              reason: 'Scale should be >= 0.0 at t=${p.t}');
          expect(state.scale, lessThanOrEqualTo(1.0), 
              reason: 'Scale should be <= 1.0 at t=${p.t}');
        }
      });
    }
  });

  test('SequenceAnimation resolves frames correctly', () {
    final frames = [
      [[true, false], [false, true]],
      [[false, true], [true, false]],
    ];
    final preset = SequenceAnimation(frames: frames);
    final animation = resolvePreset(preset);

    // Frame 0 (t = 0.0)
    expect(animation(0, 0, 2, 2, 0.0).opacity, 1.0);
    expect(animation(0, 1, 2, 2, 0.0).opacity, 0.0);

    // Frame 1 (t = 0.5)
    expect(animation(0, 0, 2, 2, 0.5).opacity, 0.0);
    expect(animation(0, 1, 2, 2, 0.5).opacity, 1.0);
  });
}
