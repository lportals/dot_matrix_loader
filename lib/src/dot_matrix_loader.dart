import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/dot_matrix_style.dart';
import 'models/dot_matrix_preset.dart';
import 'painter/dot_matrix_painter.dart';

/// A premium dot-matrix loading animation widget.
///
/// Renders an NxM grid of dots where each dot's opacity, scale and color
/// are individually driven by a per-preset delay-map function, producing
/// patterns like pulse rings, spirals, waves, and more.
///
/// ## Inline usage (fixed size, next to text)
/// ```dart
/// Row(children: [
///   Text('Uploading...'),
///   SizedBox(width: 8),
///   DotMatrixLoader(size: 18, preset: const Breathe()),
/// ])
/// ```
///
/// ## Standalone usage (self-managed controller)
/// ```dart
/// DotMatrixLoader(
///   preset: const PulseRings(),
///   style: DotMatrixStyle(activeColor: Colors.red),
/// )
/// ```
///
/// ## Gallery / showcase usage (shared controller — zero extra tickers)
/// ```dart
/// // In the parent State:
/// final _controller = AnimationController(vsync: this, duration: ...)..repeat();
///
/// // For each card:
/// DotMatrixLoader(
///   preset: const Spiral(),
///   externalAnimation: _controller,
/// )
/// ```
class DotMatrixLoader extends StatefulWidget {
  /// Creates a [DotMatrixLoader].
  const DotMatrixLoader({
    super.key,
    this.preset = const PulseRings(),
    this.style = const DotMatrixStyle(),
    this.isActive = true,
    this.externalAnimation,
    this.size,
  });

  /// The animation preset that determines dot behavior.
  final DotMatrixPreset preset;

  /// Visual configuration (colors, size, shape, speed).
  final DotMatrixStyle style;

  /// Whether the animation is actively playing.
  ///
  /// When false, the internal controller (if any) is stopped.
  /// Has no effect when [externalAnimation] is provided.
  final bool isActive;

  /// Optional externally-managed animation value.
  ///
  /// When provided, this widget creates **no** internal [AnimationController]
  /// or [Ticker]. All preset cards in a gallery should share one controller
  /// via this parameter to minimise scheduler overhead.
  final Animation<double>? externalAnimation;

  /// Optional fixed size (width = height) in logical pixels.
  ///
  /// When provided, the widget renders as a square of [size] × [size] dp.
  /// This is the recommended way to use the loader **inline**, next to text:
  ///
  /// ```dart
  /// Row(children: [
  ///   Text('Uploading...'),
  ///   SizedBox(width: 8),
  ///   DotMatrixLoader(size: 18, preset: const Breathe()),
  /// ])
  /// ```
  ///
  /// When null, the widget fills all available space from its parent
  /// while maintaining the column/row aspect ratio — suitable for
  /// use inside a fixed-size container or a gallery card.
  final double? size;

  @override
  State<DotMatrixLoader> createState() => _DotMatrixLoaderState();
}

class _DotMatrixLoaderState extends State<DotMatrixLoader>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late DotAnimationFrame _frame;
  Timer? _loopPauseTimer;

  bool get _usesExternalAnimation => widget.externalAnimation != null;

  /// The animation this widget actually reads from.
  Animation<double> get _animation =>
      widget.externalAnimation ?? _controller!;

  @override
  void initState() {
    super.initState();
    _frame = resolvePreset(widget.preset);

    if (!_usesExternalAnimation) {
      _initController();
    }
  }

  void _initController() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (1200 / widget.style.speed.clamp(0.1, 10.0)).round(),
      ),
    );

    _controller!.addStatusListener(_onStatus);

    if (widget.isActive) {
      _controller!.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    if (!widget.style.loop) return;

    if (widget.style.loopPause == Duration.zero) {
      _controller!.forward(from: 0);
    } else {
      _loopPauseTimer = Timer(widget.style.loopPause, () {
        if (mounted) _controller!.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(DotMatrixLoader oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-resolve frame if preset changed.
    if (oldWidget.preset.runtimeType != widget.preset.runtimeType ||
        (widget.preset is CustomDotAnimation &&
            (widget.preset as CustomDotAnimation).builder !=
                (oldWidget.preset as CustomDotAnimation?)?.builder)) {
      _frame = resolvePreset(widget.preset);
    }

    if (!_usesExternalAnimation && _controller != null) {
      // Update speed.
      final newDuration = Duration(
        milliseconds: (1200 / widget.style.speed.clamp(0.1, 10.0)).round(),
      );
      if (_controller!.duration != newDuration) {
        _controller!.duration = newDuration;
      }

      // Start / stop.
      if (widget.isActive && !oldWidget.isActive) {
        _controller!.forward();
      } else if (!widget.isActive && oldWidget.isActive) {
        _loopPauseTimer?.cancel();
        _controller!.stop();
      }
    }
  }

  @override
  void dispose() {
    _loopPauseTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    final core = RepaintBoundary(
      child: AspectRatio(
        aspectRatio: style.gridWidth / style.gridHeight,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : style.gridWidth;
                final height = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : style.gridHeight;

                return CustomPaint(
                  size: Size(width, height),
                  painter: DotMatrixPainter(
                    frame: _frame,
                    style: style,
                    t: _animation.value,
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    // When a fixed size is provided, constrain to a square. This is the
    // correct way to use the loader inline next to text.
    if (widget.size != null) {
      return SizedBox.square(dimension: widget.size, child: core);
    }

    return core;
  }
}
