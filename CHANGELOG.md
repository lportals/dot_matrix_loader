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
