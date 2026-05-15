# dot_matrix_loader

A zero-dependency Flutter package for premium dot-matrix loading animations.
Render animated NxM dot grids with **36 built-in presets**, a custom builder API,
and a frame-by-frame sequence API — all driven by a single `AnimationController`.

---

## Features

- **36 built-in presets** — Pulse Rings, Spiral, Wave, Heartbeat, Radar, Equalizer, and more
- **`CustomDotAnimation`** — define any animation as `f(row, col, t) → DotState`
- **`SequenceAnimation`** — frame-by-frame pixel art, like a GIF for dot grids
- **Gallery-friendly** — share one `AnimationController` across N loaders (zero extra tickers)
- **Inline-ready** — `size` parameter for use next to text in a `Row`
- **Fully customizable** — color, size, gap, shape, speed, color lerp
- **Zero dependencies** — only `flutter` SDK

---

## Installation

```yaml
dependencies:
  dot_matrix_loader: ^0.1.0
```

---

## Quick Start

```dart
import 'package:dot_matrix_loader/dot_matrix_loader.dart';

// Simplest usage — self-managed controller
DotMatrixLoader(
  preset: const PulseRings(),
  style: DotMatrixStyle(activeColor: Colors.blue),
)
```

---

## Inline Usage (next to text)

Use the `size` parameter to render a small, fixed-size loader inline:

```dart
Row(
  children: [
    const Text('Uploading...'),
    const SizedBox(width: 8),
    DotMatrixLoader(
      size: 18,
      preset: const Breathe(),
      style: DotMatrixStyle(activeColor: Colors.blue),
    ),
  ],
)
```

---

## When to use each API

| API | Analogy | Best for |
|---|---|---|
| Built-in presets (`PulseRings()`, etc.) | Material Icons | Drop-in loaders, no code needed |
| `CustomDotAnimation(builder: ...)` | A shader | Continuous math-defined animations |
| `SequenceAnimation(frames: ...)` | A GIF | Frame-by-frame pixel art, custom icons |

### Using a built-in preset

```dart
DotMatrixLoader(preset: const Spiral())
```

### Custom algorithm (`CustomDotAnimation`)

Define any animation as a function of `(row, col, rows, cols, t)`:

```dart
DotMatrixLoader(
  preset: CustomDotAnimation(
    builder: (row, col, rows, cols, t) {
      final cx = (cols - 1) / 2.0;
      final cy = (rows - 1) / 2.0;
      final dist = math.sqrt(math.pow(col - cx, 2) + math.pow(row - cy, 2));
      final v = ((math.sin(dist * 2.5 - t * 2 * math.pi) + 1) / 2);
      return DotState(opacity: v, scale: 0.35 + 0.65 * v);
    },
  ),
)
```

### Frame-by-frame sequence (`SequenceAnimation`)

Define discrete frames as boolean grids (use the **Sequence Builder** in the example app
to design them visually and export the code automatically):

```dart
DotMatrixLoader(
  preset: SequenceAnimation(
    frames: [
      [
        [false, true,  false],
        [true,  false, true ],
        [false, true,  false],
      ],
      [
        [true,  false, true ],
        [false, true,  false],
        [true,  false, true ],
      ],
    ],
  ),
  style: DotMatrixStyle(rows: 3, columns: 3),
)
```

---

## Gallery Usage (shared controller)

To render many loaders simultaneously without creating extra tickers:

```dart
class MyGallery extends StatefulWidget { ... }

class _MyGalleryState extends State<MyGallery>
    with SingleTickerProviderStateMixin {

  late final AnimationController _shared;

  @override
  void initState() {
    super.initState();
    _shared = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shared.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: const [
        DotMatrixLoader(preset: PulseRings(), externalAnimation: _shared),
        DotMatrixLoader(preset: Spiral(),     externalAnimation: _shared),
        DotMatrixLoader(preset: Wave(),       externalAnimation: _shared),
        DotMatrixLoader(preset: Radar(),      externalAnimation: _shared),
      ],
    );
  }
}
```

---

## DotMatrixStyle Reference

| Property | Type | Default | Description |
|---|---|---|---|
| `rows` | `int` | `5` | Number of dot rows |
| `columns` | `int` | `5` | Number of dot columns |
| `activeColor` | `Color` | `Color(0xFFE53935)` | Color of a fully active dot |
| `inactiveColor` | `Color` | `Color(0xFF252525)` | Color of an inactive dot (when `enableColorLerp` is true) |
| `dotRadius` | `double` | `5.0` | Radius of each dot in dp |
| `dotGap` | `double` | `6.0` | Gap between dots in dp |
| `dotShape` | `DotShape` | `DotShape.circle` | `circle` or `roundedSquare` |
| `speed` | `double` | `1.0` | Playback multiplier (2.0 = 2× faster) |
| `enableColorLerp` | `bool` | `true` | Lerp dot color from inactive to active |
| `enableHaptics` | `bool` | `false` | Haptic pulse at the end of each loop |
| `loop` | `bool` | `true` | Loop the animation |
| `loopPause` | `Duration` | `Duration.zero` | Pause between loop iterations |

## DotMatrixLoader Reference

| Property | Type | Default | Description |
|---|---|---|---|
| `preset` | `DotMatrixPreset` | `PulseRings()` | The animation preset |
| `style` | `DotMatrixStyle` | `DotMatrixStyle()` | Visual configuration |
| `size` | `double?` | `null` | Fixed square size in dp (for inline use) |
| `isActive` | `bool` | `true` | Whether the animation plays |
| `externalAnimation` | `Animation<double>?` | `null` | Shared controller for gallery use |

---

## Built-in Presets

| Name | Category | Description |
|---|---|---|
| `PulseRings` | Spinner | Concentric rings expand from center |
| `Spiral` | Spinner | A bright trace winds outward in a spiral |
| `Wave` | Ambient | A breathing sine wave drifts left to right |
| `CrossExpand` | Ambient | A plus shape blooms in Manhattan steps |
| `Rain` | Ambient | Independent drops fall column by column |
| `Heartbeat` | Progress | A double-pulse rhythm radiates from center |
| `Orbit` | Spinner | Dots cycle in concentric orbital rings |
| `Ripple` | Ambient | Sine ripples radiate outward from center |
| `Diagonal` | Agent | A sweep travels top-left to bottom-right |
| `Bounce` | Spinner | Dots bounce vertically with column offset |
| `Shockwave` | Spinner | A sharp ring erupts with exponential decay |
| `Metronome` | Ambient | A column swings left-right with row lag |
| `Erosion` | Agent | A two-phase diagonal erase and refill |
| `Sonar` | Agent | A ping from corner expands and returns |
| `Curtain` | Progress | Columns fill top-down in a theatrical reveal |
| `Interference` | Ambient | Two offset waves create moiré patterns |
| `Ticker` | Spinner | A dot races around the perimeter |
| `Genome` | Ambient | Per-dot FM synthesis for organic motion |
| `StackFill` | Progress | Columnar bottom-up fill with dome-shaped front |
| `Veil` | Spinner | A brightness sweep band that rotates |
| `Radar` | Spinner | A classic rotating radar sweep beam |
| `Scanner` | Agent | A horizontal laser bouncing up and down |
| `Collapse` | Ambient | A ring collapses rapidly into the center |
| `Static` | Ambient | Randomized high-frequency white noise |
| `Wanderer` | Agent | A single dot wandering via Lissajous curves |
| `Crosshair` | Spinner | Intersecting axes moving across the grid |
| `RippleIn` | Ambient | Concentric waves collapsing inward |
| `Wipe` | Progress | A solid directional wipe rotating 360° |
| `Twinkle` | Ambient | Smooth, asynchronous twinkling stars |
| `ZigZag` | Progress | A raster scan snake filling the grid |
| `Equalizer` | Progress | Dynamic audio spectrum bars |
| `Gravity` | Agent | Dots dropping with physical gravity |
| `Glitch` | Ambient | VHS-style horizontal displacement noise |
| `Diamond` | Ambient | Expanding diamond rings (Manhattan distance) |
| `Checkerboard` | Ambient | An alternating grid crossfade |
| `Breathe` | Ambient | A global ease-in-out pulse |

---

## License

MIT
