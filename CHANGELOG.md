## 0.1.4

### Optimizations
- Refactored `_orbit` preset animation logic in `lib/src/models/dot_matrix_preset.dart` to be mathematically continuous for smooth, stutter-free loops when `t` loops from `1.0` back to `0.0`.

### Example App Enhancements
- Refactored Example Studio codebase to a clean MVVM (Model-View-ViewModel) architecture.
- Added a new **Predefined Status Showcase** page (`examples_page.dart`) demonstrating real-world workflow patterns (e.g., system diagnostics, database operations, media processing).
- Added `CustomSequenceRepository` to manage runtime storage and caching of user-designed animation sequences.
- Improved layout responsiveness across the Sequence Builder and Example pages for both desktop and mobile viewports.
- Enhanced code-export widgets with premium copy indicators and polished syntax highlighting contrast.

## 0.1.3

- Force README asset refresh for pub.dev using cache-busting URLs.
- Added professional badges to README.

## 0.1.2

- Final fix for README asset paths using absolute GitHub URLs.

## 0.1.1

- Fix README asset paths for proper rendering on pub.dev.

## 0.1.0

### Added
- 36 built-in animation presets: `PulseRings`, `Spiral`, `Wave`, `CrossExpand`,
  `Rain`, `Heartbeat`, `Orbit`, `Ripple`, `Diagonal`, `Bounce`, `Shockwave`,
  `Metronome`, `Erosion`, `Sonar`, `Curtain`, `Interference`, `Ticker`, `Genome`,
  `StackFill`, `Veil`, `Radar`, `Scanner`, `Collapse`, `Static`, `Wanderer`,
  `Crosshair`, `RippleIn`, `Wipe`, `Twinkle`, `ZigZag`, `Equalizer`, `Gravity`,
  `Glitch`, `Diamond`, `Checkerboard`, `Breathe`
- `DotMatrixLoader` widget with `size` parameter for inline usage next to text
- `DotMatrixAnimationBuilder` convenience widget for custom frame functions
- `CustomDotAnimation` preset — supply any `DotAnimationFrame` function
- `SequenceAnimation` preset — frame-by-frame boolean grid animations
- `DotMatrixStyle` immutable configuration with `copyWith` support
- `externalAnimation` parameter — share one `AnimationController` across N loaders
- `DotShape` enum: `circle` and `roundedSquare`
- `loop`, `loopPause`, `enableHaptics`, `enableColorLerp` style options
- `isActive` flag to pause/resume standalone loaders
- **Interactive Studio Example**: Full-featured design playground with frame editor and code exporter.
