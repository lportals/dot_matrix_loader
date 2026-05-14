import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';



/// Detail & export page for a specific [DotMatrixPreset].
///
/// Shows a large live preview of the preset and lets the user tweak
/// [DotMatrixStyle] properties (color, size, speed). The export button
/// generates a clean `DotMatrixLoader(preset: …, style: …)` snippet
/// using the **real preset class** — no custom lambda required.
class BuilderPage extends StatefulWidget {
  const BuilderPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    this.initialPresetName,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  /// Name of the preset to show on first load (matches [_PresetRegistry] keys).
  final String? initialPresetName;

  @override
  State<BuilderPage> createState() => _BuilderPageState();
}

// ---------------------------------------------------------------------------
// Preset registry — maps display name → class instance
// ---------------------------------------------------------------------------

/// All built-in presets with their display names.
///
/// Ordered to match the showcase gallery.
const _presetRegistry = <String, DotMatrixPreset>{
  'Pulse Rings':    PulseRings(),
  'Spiral':         Spiral(),
  'Wave':           Wave(),
  'Cross Expand':   CrossExpand(),
  'Rain':           Rain(),
  'Heartbeat':      Heartbeat(),
  'Orbit':          Orbit(),
  'Ripple':         Ripple(),
  'Diagonal':       Diagonal(),
  'Bounce':         Bounce(),
  'Shockwave':      Shockwave(),
  'Metronome':      Metronome(),
  'Erosion':        Erosion(),
  'Sonar':          Sonar(),
  'Curtain':        Curtain(),
  'Interference':   Interference(),
  'Ticker':         Ticker(),
  'Genome':         Genome(),
  'Stack Fill':     StackFill(),
  'Veil':           Veil(),
  'Radar':          Radar(),
  'Scanner':        Scanner(),
  'Collapse':       Collapse(),
  'Static':         Static(),
  'Wanderer':       Wanderer(),
  'Crosshair':      Crosshair(),
  'Ripple In':      RippleIn(),
  'Wipe':           Wipe(),
  'Twinkle':        Twinkle(),
  'ZigZag':         ZigZag(),
  'Equalizer':      Equalizer(),
  'Gravity':        Gravity(),
  'Glitch':         Glitch(),
  'Diamond':        Diamond(),
  'Checkerboard':   Checkerboard(),
  'Breathe':        Breathe(),
};

// ---------------------------------------------------------------------------
// Page state
// ---------------------------------------------------------------------------

class _BuilderPageState extends State<BuilderPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Style parameters
  late String _presetName;
  late Color _activeColor;
  double _dotRadius = 2.5;
  double _dotGap = 6.0;
  double _loaderSize = 48.0;
  double _speed = 1.0;
  int _rows = 5;
  int _cols = 5;
  DotShape _dotShape = DotShape.circle;
  bool _enableColorLerp = true;
  bool _copied = false;

  DotMatrixPreset get _preset =>
      _presetRegistry[_presetName] ?? const PulseRings();

  @override
  void initState() {
    super.initState();
    _presetName = widget.initialPresetName != null &&
            _presetRegistry.containsKey(widget.initialPresetName)
        ? widget.initialPresetName!
        : _presetRegistry.keys.first;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeColor = Theme.of(context).colorScheme.primary;
  }

  @override
  void didUpdateWidget(covariant BuilderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPresetName != oldWidget.initialPresetName &&
        widget.initialPresetName != null &&
        _presetRegistry.containsKey(widget.initialPresetName)) {
      setState(() => _presetName = widget.initialPresetName!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Code generation — always produces the real preset class, never a lambda.
  // ---------------------------------------------------------------------------

  String get _generatedCode {
    final r = _activeColor.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _activeColor.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _activeColor.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final colorHex = '0xFF$r$g$b';

    final sb = StringBuffer()
      ..writeln('DotMatrixLoader(')
      ..writeln('  preset: const $_presetName(),');


    sb.writeln('  style: DotMatrixStyle(');
    if (_rows != 5) sb.writeln('    rows: $_rows,');
    if (_cols != 5) sb.writeln('    columns: $_cols,');
    sb.writeln('    activeColor: const Color($colorHex),');
    if (_dotRadius != 2.5) sb.writeln('    dotRadius: ${_dotRadius.toStringAsFixed(1)},');
    if (_dotGap != 6.0) sb.writeln('    dotGap: ${_dotGap.toStringAsFixed(1)},');
    if (_speed != 1.0) sb.writeln('    speed: ${_speed.toStringAsFixed(2)},');
    if (_dotShape != DotShape.circle) sb.writeln('    dotShape: DotShape.roundedSquare,');
    if (!_enableColorLerp) sb.writeln('    enableColorLerp: false,');
    sb.writeln('  ),');
    if (_loaderSize != 100.0) sb.writeln('  size: ${_loaderSize.toStringAsFixed(1)},');
    sb.writeln(')');

    return sb.toString();
  }

  Future<void> _copyCode() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _generatedCode));
    if (mounted) setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  void _updateSpeed(double v) {
    setState(() => _speed = v);
    _controller
      ..duration = Duration(milliseconds: (1200 / v).round())
      ..repeat();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewBg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFEAEAEA);
    final inactiveDot = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFDDDDDD);
    final trackInactive = onSurface.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _BackButton(color: onSurface),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _presetName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                        letterSpacing: -1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Live preview ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: previewBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: DotMatrixLoader(
                      size: _loaderSize,
                      preset: _preset,
                      style: DotMatrixStyle(
                        rows: _rows,
                        columns: _cols,
                        activeColor: _activeColor,
                        inactiveColor: inactiveDot,
                        dotRadius: _dotRadius,
                        dotGap: _dotGap,
                        speed: _speed,
                        dotShape: _dotShape,
                        enableColorLerp: _enableColorLerp,
                      ),
                      externalAnimation: _controller,
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // ── Controls ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Color
                    _SectionLabel('Color', onSurface: onSurface),
                    const SizedBox(height: 10),
                    _ColorRow(
                      selected: _activeColor,
                      isDark: isDark,
                      onSelect: (c) => setState(() => _activeColor = c),
                      themePrimary: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),

                    // Loader Size
                    _SectionLabel('Loader Size (Square)', onSurface: onSurface),
                    const SizedBox(height: 8),
                    _StyledSlider(
                      value: _loaderSize,
                      min: 10.0,
                      max: 99.0,
                      label: '${_loaderSize.toStringAsFixed(0)} × ${_loaderSize.toStringAsFixed(0)} dp',
                      activeColor: _activeColor,
                      trackInactive: trackInactive,
                      thumbColor: onSurface,
                      onChanged: (v) => setState(() => _loaderSize = v),
                    ),
                    const SizedBox(height: 20),

                    // Speed
                    _SectionLabel('Speed', onSurface: onSurface),
                    const SizedBox(height: 8),
                    _StyledSlider(
                      value: _speed,
                      min: 0.25,
                      max: 3.0,
                      label: '${_speed.toStringAsFixed(1)}×',
                      activeColor: _activeColor,
                      trackInactive: trackInactive,
                      thumbColor: onSurface,
                      onChanged: _updateSpeed,
                    ),
                    const SizedBox(height: 20),

                    // Grid size
                    _SectionLabel('Grid Size', onSurface: onSurface),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: _StyledSlider(
                          value: _rows.toDouble(),
                          min: 3,
                          max: 9,
                          divisions: 6,
                          label: '$_rows rows',
                          activeColor: _activeColor,
                          trackInactive: trackInactive,
                          thumbColor: onSurface,
                          onChanged: (v) => setState(() => _rows = v.round()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StyledSlider(
                          value: _cols.toDouble(),
                          min: 3,
                          max: 9,
                          divisions: 6,
                          label: '$_cols cols',
                          activeColor: _activeColor,
                          trackInactive: trackInactive,
                          thumbColor: onSurface,
                          onChanged: (v) => setState(() => _cols = v.round()),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Dot radius
                    _SectionLabel('Dot Size', onSurface: onSurface),
                    const SizedBox(height: 8),
                    _StyledSlider(
                      value: _dotRadius,
                      min: 1.0,
                      max: 12.0,
                      label: '${_dotRadius.toStringAsFixed(1)} dp',
                      activeColor: _activeColor,
                      trackInactive: trackInactive,
                      thumbColor: onSurface,
                      onChanged: (v) => setState(() => _dotRadius = v),
                    ),
                    const SizedBox(height: 20),

                    // Dot gap
                    _SectionLabel('Dot Gap', onSurface: onSurface),
                    const SizedBox(height: 8),
                    _StyledSlider(
                      value: _dotGap,
                      min: 1.0,
                      max: 14.0,
                      label: '${_dotGap.toStringAsFixed(1)} dp',
                      activeColor: _activeColor,
                      trackInactive: trackInactive,
                      thumbColor: onSurface,
                      onChanged: (v) => setState(() => _dotGap = v),
                    ),
                    const SizedBox(height: 20),

                    // Dot shape
                    _SectionLabel('Shape', onSurface: onSurface),
                    const SizedBox(height: 10),
                    Row(children: [
                      _ShapeChip(
                        label: 'Circle',
                        selected: _dotShape == DotShape.circle,
                        activeColor: _activeColor,
                        onSurface: onSurface,
                        onTap: () => setState(() => _dotShape = DotShape.circle),
                      ),
                      const SizedBox(width: 8),
                      _ShapeChip(
                        label: 'Rounded Square',
                        selected: _dotShape == DotShape.roundedSquare,
                        activeColor: _activeColor,
                        onSurface: onSurface,
                        onTap: () => setState(() => _dotShape = DotShape.roundedSquare),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Color lerp toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Color lerp',
                          style: TextStyle(
                            fontSize: 13,
                            color: onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        _Toggle(
                          value: _enableColorLerp,
                          activeColor: _activeColor,
                          onSurface: onSurface,
                          onChanged: (v) => setState(() => _enableColorLerp = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Export button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: GestureDetector(
                onTap: _copyCode,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _copied ? Colors.green : _activeColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_copied ? Colors.green : _activeColor)
                            .withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied
                              ? Icons.check_circle_outline_rounded
                              : Icons.code_rounded,
                          color: _copied
                              ? Colors.white
                              : (_activeColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _copied ? 'COPIED!' : 'COPY CODE',
                          style: TextStyle(
                            color: _copied
                                ? Colors.white
                                : (_activeColor.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

/// Simple back button.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: color.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// Section header label.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.onSurface});
  final String text;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: onSurface.withValues(alpha: 0.35),
        letterSpacing: 1.4,
      ),
    );
  }
}

/// Styled slider with a value label on the right.
class _StyledSlider extends StatelessWidget {
  const _StyledSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.activeColor,
    required this.trackInactive,
    required this.thumbColor,
    required this.onChanged,
    this.divisions,
  });

  final double value;
  final double min;
  final double max;
  final String label;
  final Color activeColor;
  final Color trackInactive;
  final Color thumbColor;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: activeColor,
            inactiveTrackColor: trackInactive,
            thumbColor: thumbColor,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ),
      SizedBox(
        width: 64,
        child: Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 11,
            color: thumbColor.withValues(alpha: 0.5),
          ),
        ),
      ),
    ]);
  }
}

/// Color picker row with preset swatches.
class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.selected,
    required this.isDark,
    required this.onSelect,
    required this.themePrimary,
  });

  final Color selected;
  final bool isDark;
  final ValueChanged<Color> onSelect;
  final Color themePrimary;

  static const _swatches = [
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
    Color(0xFF26C6DA),
  ];

  @override
  Widget build(BuildContext context) {
    final ringColor = isDark ? Colors.white : Colors.black;
    final allColors = [themePrimary, ..._swatches];

    return Row(
      children: allColors.map((c) {
        final isSelected = selected == c;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(c);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ringColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)]
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Dot shape selector chip.
class _ShapeChip extends StatelessWidget {
  const _ShapeChip({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onSurface,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final Color onSurface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : onSurface.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? (activeColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white)
                : onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

/// Simple animated toggle switch.
class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.value,
    required this.activeColor,
    required this.onSurface,
    required this.onChanged,
  });

  final bool value;
  final Color activeColor;
  final Color onSurface;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? activeColor : onSurface.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: onSurface,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
