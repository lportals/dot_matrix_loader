# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] - 2026-05-13

### Added
- **10 built-in animation presets**: `PulseRings`, `Spiral`, `Wave`, `CrossExpand`, `Rain`,
  `Heartbeat`, `Orbit`, `Ripple`, `Diagonal`, `Bounce`.
- **`DotMatrixLoader`** — core widget with internal `AnimationController` and support for an
  externally-shared `Animation<double>` to minimise ticker overhead in gallery views.
- **`DotMatrixAnimationBuilder`** — convenience wrapper for supplying a custom `DotAnimationFrame`
  function without boilerplate.
- **`DotMatrixStyle`** — immutable configuration model (`copyWith`) covering dot size, gap,
  shape (`circle` / `roundedSquare`), colors, speed, loop pause, and haptics.
- **`DotMatrixPreset`** — sealed class hierarchy enabling exhaustive, branchless dispatch via
  Dart 3 switch expressions.
- **Showcase page** — full-screen gallery with a single shared `AnimationController`, category
  filter chips, color picker, speed slider, and live rows/columns sliders that affect both the
  hero loader and every preset card simultaneously.
- **Builder page** — interactive animation builder with real-time Dart code generation and
  one-tap clipboard copy.
- **Light / dark mode** — complete theme support across all widgets; floating toggle button in
  the top-right corner of the app shell.
- **`RepaintBoundary`** wrapping every `CustomPaint` to isolate repaints from the widget tree.

### Fixed
- **`shouldRepaint` bug** — `DotMatrixPainter` was comparing `oldDelegate.frame` to itself
  (always `false`), preventing preset changes from being reflected on-canvas until `t` or
  `style` changed. Now correctly compares `oldDelegate.frame != frame`.
- **Speed slider** — changing the animation duration on a repeating `AnimationController`
  requires calling `repeat()` again; without it the controller continued at the old speed.
- **`Paint` allocation** — a single `Paint` object is now allocated once per `paint()` call
  and mutated in-place per dot, eliminating ~1 500 unnecessary allocations per second at
  60 fps on a 5×5 grid.

### Changed
- Navbar active icon color changed from the red `primary` accent to `onSurface` (white in
  dark mode, black in light mode) — antagonistic to the current brightness.
- Category filter chips now have equal vertical spacing above and below.

---

## [Unreleased]

- Accessibility: `Semantics` labels for `DotMatrixLoader`.
- Additional presets: `Noise`, `Checkerboard`, `Snake`.
- Pub.dev publication.
