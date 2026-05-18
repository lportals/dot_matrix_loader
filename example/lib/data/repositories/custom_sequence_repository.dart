import '../models/custom_sequence.dart';

/// Repository responsible for providing pre-made animation templates
/// and managing the runtime storage/retrieval of custom sequences.
class CustomSequenceRepository {
  /// Local cache for storing the active user-designed sequence at runtime.
  CustomSequence? _cachedUserSequence;

  /// Returns the default set of high-fidelity animation sequence templates.
  List<CustomSequence> getDefaultSequences() {
    return [
      _spaceInvaderPreset(),
      _radarSweepPreset(),
      _pulsingTargetPreset(),
      _waveMotionPreset(),
    ];
  }

  /// Saves the active user sequence in the runtime cache.
  void saveSequence(CustomSequence sequence) {
    _cachedUserSequence = sequence;
  }

  /// Loads the cached user sequence, returning null if no sequence is saved yet.
  CustomSequence? getSavedSequence() {
    return _cachedUserSequence;
  }

  // ── High-Fidelity Sequence Presets ───────────────────────────────────

  CustomSequence _spaceInvaderPreset() {
    return const CustomSequence(
      name: 'Space Invader',
      rows: 5,
      cols: 5,
      frames: [
        // Frame 1: Hands down
        [
          [false, true, true, true, false],
          [true, false, true, false, true],
          [true, true, true, true, true],
          [false, true, false, true, false],
          [true, false, false, false, true],
        ],
        // Frame 2: Hands up
        [
          [false, true, true, true, false],
          [true, false, true, false, true],
          [true, true, true, true, true],
          [false, true, false, true, false],
          [false, true, false, true, false],
        ],
      ],
    );
  }

  CustomSequence _radarSweepPreset() {
    return const CustomSequence(
      name: 'Radar Sweep',
      rows: 4,
      cols: 4,
      frames: [
        // 12 o'clock sweep
        [
          [false, true, true, false],
          [false, true, true, false],
          [false, false, false, false],
          [false, false, false, false],
        ],
        // 3 o'clock sweep
        [
          [false, false, false, false],
          [false, false, true, true],
          [false, false, true, true],
          [false, false, false, false],
        ],
        // 6 o'clock sweep
        [
          [false, false, false, false],
          [false, false, false, false],
          [false, true, true, false],
          [false, true, true, false],
        ],
        // 9 o'clock sweep
        [
          [false, false, false, false],
          [true, true, false, false],
          [true, true, false, false],
          [false, false, false, false],
        ],
      ],
    );
  }

  CustomSequence _pulsingTargetPreset() {
    return const CustomSequence(
      name: 'Pulsing Target',
      rows: 5,
      cols: 5,
      frames: [
        // Frame 1: Center dot
        [
          [false, false, false, false, false],
          [false, false, false, false, false],
          [false, false, true, false, false],
          [false, false, false, false, false],
          [false, false, false, false, false],
        ],
        // Frame 2: Middle ring
        [
          [false, false, false, false, false],
          [false, true, true, true, false],
          [false, true, false, true, false],
          [false, true, true, true, false],
          [false, false, false, false, false],
        ],
        // Frame 3: Outer border ring
        [
          [true, true, true, true, true],
          [true, false, false, false, true],
          [true, false, false, false, true],
          [true, false, false, false, true],
          [true, true, true, true, true],
        ],
        // Frame 4: Middle ring (contracting)
        [
          [false, false, false, false, false],
          [false, true, true, true, false],
          [false, true, false, true, false],
          [false, true, true, true, false],
          [false, false, false, false, false],
        ],
      ],
    );
  }

  CustomSequence _waveMotionPreset() {
    return const CustomSequence(
      name: 'Wave Motion',
      rows: 6,
      cols: 6,
      frames: [
        // Frame 1
        [
          [true, false, false, false, false, false],
          [true, true, false, false, false, false],
          [false, true, true, false, false, false],
          [false, false, true, true, false, false],
          [false, false, false, true, true, false],
          [false, false, false, false, true, true],
        ],
        // Frame 2
        [
          [false, true, true, false, false, false],
          [false, false, true, true, false, false],
          [false, false, false, true, true, false],
          [false, false, false, false, true, true],
          [false, false, false, false, false, true],
          [true, false, false, false, false, false],
        ],
        // Frame 3
        [
          [false, false, false, true, true, false],
          [false, false, false, false, true, true],
          [false, false, false, false, false, true],
          [true, false, false, false, false, false],
          [true, true, false, false, false, false],
          [false, true, true, false, false, false],
        ],
        // Frame 4
        [
          [false, false, false, false, false, true],
          [true, false, false, false, false, false],
          [true, true, false, false, false, false],
          [false, true, true, false, false, false],
          [false, false, true, true, false, false],
          [false, false, false, true, true, false],
        ],
      ],
    );
  }
}
