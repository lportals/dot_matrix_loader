## 0.2.0

### Preset Expansion & Documentation Update
- **25 New Built-in Presets**: Added 25 new premium, mathematically defined, looping animation presets, bringing the total built-in presets from 36 to 61. The new presets include:
  - `MatrixRain`, `PingPong`, `FadingGrid`, `CrossSlide`, `ConcentricBoxes`, `DNAHelix`, `HeartbeatDouble`, `Fireworks`, `ExpandingPolygons`, `SinePlasma`, `CellularAutomaton`, `Supernova`, `Vortex`, `InfinityLoop`, `LiquidFluid`, `TetrisDrop`, `LaserSweep`, `Starfield`, `BarChart`, `Labyrinth`, `PacmanChase`, `SineWaveMultiply`, `PulseWave`, `Hourglass`, and `LoadingArc`.
- **Documentation**: Updated README.md, pubspec.yaml, and showcase examples references to reflect the new 61 presets count.

## 0.1.6

### Features & Styling Polish
- **Motion Trail (Phosphor Decay)**: Added `enableTrail` option to `DotMatrixStyle`. It simulates retro phosphor screen persistence by statelessly rendering previous frames with an exponential decay, creating a beautiful trailing effect behind moving elements. Exposes toggles in all designer and playground screens.
- **Neon Glow (Soft Shadow)**: Added `enableGlow` option to `DotMatrixStyle`. It applies a soft blurred neon lighting mask under active dots using GPU-accelerated blurs to simulate physical LEDs. Exposes toggles in all designer and playground screens.
- **Mobile Responsive Enhancements**:
  - Replaced tight header layout Rows with wrapping flows (`Wrap`) to prevent text overflows on narrow viewports.
  - Refactored `ShowcasePage` controls with a fluid `LayoutBuilder` to stack options vertically on screens < 600dp and use `Expanded` sliders to fit any viewport.
  - Configured Examples Playground code inspector and settings pills to scale down elegantly on narrow screens.

## 0.1.5

### Features & Styling Polish
- **Dynamic Shape-Morphing UI Sync**: Integrated dynamic shape transitions across the entire Examples & Showcase layouts. Setting a shape (Circle ⇄ Square) in the configuration sheet dynamically morphs the border radiuses of all visual elements (search toolbars, category selection chips, scenario cards, active process backgrounds, status pills, and code inspectors).
- **Global Studio State Sync**: Enabled bidirectional state synchronization between separate tabs (Showcase and Playground) via a unified `StudioProvider` architecture, keeping shapes and settings perfectly in sync across the application shell.
- **Crisp Rounded Square Definition**: Optimized `DotShape.roundedSquare` corners in the canvas painter from `0.35` multiplier to a crisp `0.18`, ensuring high-density vertical grids (such as the 6x4 Log Stream Ingestion rain preset) look highly defined and rectangular at small dimensions instead of looking circular due to antialiasing.
- **Interactive Playground Rebranding**: Renamed the visible "Examples" tab to **"Playground"** in both desktop side navigation rails and mobile navigation bars, completing a cohesive developer-focused studio workspace trilogy: *Showcase*, *Sequence*, and *Playground*.
- **Shape-Morphing AppBar Toggles**: Made the top action buttons (theme toggle and option selectors) shape-responsive, dynamically morphing their outlines from circles to rounded squares when switching modes.
- **Shape Icon Toggle for Dot Shape Selector**: The dot shape picker in the Scenario Simulator now uses distinct SVG-style icons (circle vs. rounded square) instead of text labels, matching the visual language established in the Showcase and Sequence Builder pages.

### Scenario Simulator — Interactive Playground Enhancements
- **Shimmer Text Effect**: The active status label inside the Interactive Playground pill button now displays a continuous shimmer sweep animation — a horizontal light-to-dark gradient that cycles at 2 s/loop, powered by a `ShaderMask` and `LinearGradient`. In dark mode it highlights with a white shine; in light mode it follows the active primary color.
- **DOT SIZE Control**: The "Playground Setup" configuration sheet now exposes a **DOT SIZE** slider (range `1.0–4.0`) controlling `DotMatrixStyle.dotRadius`, replacing the previously unlabeled radius field. The label is also unified across the Sequence Builder ("DOT SIZE" replaces "DOT RADIUS").
- **LOADER SIZE Control**: A new **LOADER SIZE** slider (range `10–30 dp`, default `20 dp`) in the "Playground Setup" sheet controls the square dimension of the `SizedBox` container wrapping the `DotMatrixLoader` in the playground pill, allowing real-time visual scaling of the indicator widget in context.
- **Layout Stability Fix**: Removed a `FittedBox` wrapper that was causing a recursive layout assertion loop (`!_debugDoingThisLayout`) in the `DotMatrixLoader`'s internal `LayoutBuilder`/`AspectRatio` pipeline. The loader now renders inside a stable, bounded `SizedBox` at all times.

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
