import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../widgets/studio_widgets.dart';
import '../studio_provider.dart';

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
    this.initialRows,
    this.initialCols,
    this.initialSpeed,
    this.initialColor,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  /// Name of the preset to show on first load (matches [_PresetRegistry] keys).
  final String? initialPresetName;

  final int? initialRows;
  final int? initialCols;
  final double? initialSpeed;
  final Color? initialColor;

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
  'Pulse Rings': PulseRings(),
  'Spiral': Spiral(),
  'Wave': Wave(),
  'Cross Expand': CrossExpand(),
  'Rain': Rain(),
  'Heartbeat': Heartbeat(),
  'Orbit': Orbit(),
  'Ripple': Ripple(),
  'Diagonal': Diagonal(),
  'Bounce': Bounce(),
  'Shockwave': Shockwave(),
  'Metronome': Metronome(),
  'Erosion': Erosion(),
  'Sonar': Sonar(),
  'Curtain': Curtain(),
  'Interference': Interference(),
  'Ticker': Ticker(),
  'Genome': Genome(),
  'Stack Fill': StackFill(),
  'Veil': Veil(),
  'Radar': Radar(),
  'Scanner': Scanner(),
  'Collapse': Collapse(),
  'Static': Static(),
  'Wanderer': Wanderer(),
  'Crosshair': Crosshair(),
  'Ripple In': RippleIn(),
  'Wipe': Wipe(),
  'Twinkle': Twinkle(),
  'ZigZag': ZigZag(),
  'Equalizer': Equalizer(),
  'Gravity': Gravity(),
  'Glitch': Glitch(),
  'Diamond': Diamond(),
  'Checkerboard': Checkerboard(),
  'Breathe': Breathe(),
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
  bool _enableColorLerp = true;
  bool _copied = false;

  DotMatrixPreset get _preset =>
      _presetRegistry[_presetName] ?? const PulseRings();

  @override
  void initState() {
    super.initState();
    _presetName =
        widget.initialPresetName != null &&
                _presetRegistry.containsKey(widget.initialPresetName)
            ? widget.initialPresetName!
            : _presetRegistry.keys.first;

    _rows = widget.initialRows ?? 5;
    _cols = widget.initialCols ?? 5;
    _speed = widget.initialSpeed ?? 1.0;
    // Note: _activeColor is initialized in didChangeDependencies if not provided here,
    // but we can set it here if we have it.
    if (widget.initialColor != null) {
      _activeColor = widget.initialColor!;
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1200 / _speed).round()),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialColor == null) {
      _activeColor = Theme.of(context).colorScheme.primary;
    }
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
    final r =
        _activeColor.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g =
        _activeColor.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b =
        _activeColor.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final colorHex = '0xFF$r$g$b';

    final sb =
        StringBuffer()
          ..writeln('DotMatrixLoader(')
          ..writeln('  preset: const $_presetName(),');

    sb.writeln('  style: DotMatrixStyle(');
    if (_rows != 5) sb.writeln('    rows: $_rows,');
    if (_cols != 5) sb.writeln('    columns: $_cols,');
    sb.writeln('    activeColor: const Color($colorHex),');
    if (_dotRadius != 2.5)
      sb.writeln('    dotRadius: ${_dotRadius.toStringAsFixed(1)},');
    if (_dotGap != 6.0)
      sb.writeln('    dotGap: ${_dotGap.toStringAsFixed(1)},');
    if (_speed != 1.0) sb.writeln('    speed: ${_speed.toStringAsFixed(2)},');
    final currentShape = StudioProvider.of(context).shape;
    if (currentShape != DotShape.circle)
      sb.writeln('    dotShape: DotShape.roundedSquare,');
    if (!_enableColorLerp) sb.writeln('    enableColorLerp: false,');
    sb.writeln('  ),');
    if (_loaderSize != 100.0)
      sb.writeln('  size: ${_loaderSize.toStringAsFixed(1)},');
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
    final studio = StudioProvider.of(context);
    final isDark = widget.isDark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);
    final borderColor =
        isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 600;

          if (isDesktop) {
            return _buildDesktopLayout(
              onSurface,
              cardBg,
              borderColor,
              constraints,
            );
          }
          return _buildMobileLayout(onSurface, cardBg, borderColor);
        },
      ),
    );
  }

  Widget _buildMobileLayout(Color onSurface, Color cardBg, Color borderColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewBg =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFEAEAEA);
    final inactiveDot =
        isDark ? const Color(0xFF1C1C1C) : const Color(0xFFDDDDDD);
    final trackInactive = onSurface.withValues(alpha: 0.12);

    return SafeArea(
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
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: onSurface,
                      letterSpacing: -0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Live preview ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Center(
              child: Container(
                width: (_loaderSize + 80).clamp(140.0, 240.0),
                height: (_loaderSize + 80).clamp(140.0, 240.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: StudioProvider.of(context).borderRadius * 1.2,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dotSpacing = (_dotRadius * 2 + _dotGap);
                    return Stack(
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(_loaderSize * 0.4 + 20),
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: 0.03),
                              borderRadius: StudioProvider.of(context).borderRadius,
                              border: Border.all(
                                color: onSurface.withValues(alpha: 0.05),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: BlurTransition(
                                    animation: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.95,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(_presetName),
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
                                    dotShape: StudioProvider.of(context).shape,
                                    enableColorLerp: _enableColorLerp,
                                  ),
                                  externalAnimation: _controller,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
                  _buildMobileControls(onSurface, trackInactive, isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Export button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SidebarExportButton(
              copied: _copied,
              activeColor: _activeColor,
              onTap: _copyCode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    Color onSurface,
    Color cardBg,
    Color borderColor,
    BoxConstraints constraints,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveDot =
        isDark ? const Color(0xFF1C1C1C) : const Color(0xFFDDDDDD);
    final trackInactive = onSurface.withValues(alpha: 0.12);

    return Row(
      children: [
        // ── Main Preview Area ──────────────────────────────────────────
        Expanded(
          child: Column(
            children: [
              // Custom Desktop Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    _BackButton(color: onSurface),
                    const SizedBox(width: 20),
                    Text(
                      _presetName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ALGORITHMIC PRESET',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: onSurface.withValues(alpha: 0.4),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Centered Large Preview
              Expanded(
                child: LayoutBuilder(
                  builder: (context, previewConstraints) {
                    final isSmallDesktop = constraints.maxWidth < 1100;
                    final previewScale = isSmallDesktop ? 2.0 : 2.8;

                    final dotSpacing =
                        (_dotRadius * 2 + _dotGap) * previewScale;

                    return Stack(
                      children: [
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: previewConstraints.maxWidth * 0.8,
                              maxHeight: previewConstraints.maxHeight * 0.8,
                            ),
                            padding: EdgeInsets.all((_loaderSize * previewScale) * 0.3 + 32),
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: 0.02),
                              borderRadius: StudioProvider.of(context).borderRadius * 1.2,
                              border: Border.all(
                                color: onSurface.withValues(alpha: 0.05),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: BlurTransition(
                                    animation: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.98,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(_presetName),
                                child: DotMatrixLoader(
                                  size: _loaderSize * previewScale,
                                  preset: _preset,
                                  style: DotMatrixStyle(
                                    rows: _rows,
                                    columns: _cols,
                                    activeColor: _activeColor,
                                    inactiveColor: inactiveDot,
                                    dotRadius:
                                        _dotRadius * (previewScale * 0.8),
                                    dotGap: _dotGap * (previewScale * 0.8),
                                    dotShape: StudioProvider.of(context).shape,
                                    enableColorLerp: _enableColorLerp,
                                  ),
                                  externalAnimation: _controller,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Inspector Sidebar ──────────────────────────────────────────
        Container(
          width: 340,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(left: BorderSide(color: borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Inspector.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StaggeredEntrance(
                        index: 0,
                        child: _buildSidebarSection(
                          'COLOR',
                          _ColorRow(
                            selected: _activeColor,
                            isDark: isDark,
                            onSelect: (c) => setState(() => _activeColor = c),
                            themePrimary: Theme.of(context).colorScheme.primary,
                          ),
                          onSurface,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _StaggeredEntrance(
                        index: 1,
                        child: _buildSidebarSection(
                          'LOADER SIZE',
                          _buildSidebarSlider(
                            'Size',
                            _loaderSize,
                            (v) => setState(() => _loaderSize = v),
                            onSurface,
                            min: 10,
                            max: 99,
                          ),
                          onSurface,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _StaggeredEntrance(
                        index: 2,
                        child: _buildSidebarSection(
                          'ANIMATION',
                          Column(
                            children: [
                              _buildSidebarSlider(
                                'Speed',
                                _speed,
                                _updateSpeed,
                                onSurface,
                                min: 0.25,
                                max: 3.0,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Color lerp',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  _Toggle(
                                    value: _enableColorLerp,
                                    activeColor: _activeColor,
                                    onSurface: onSurface,
                                    onChanged:
                                        (v) => setState(
                                          () => _enableColorLerp = v,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onSurface,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _StaggeredEntrance(
                        index: 3,
                        child: _buildSidebarSection(
                          'GRID CONFIG',
                          Column(
                            children: [
                              _buildSidebarSlider(
                                'Rows',
                                _rows.toDouble(),
                                (v) => setState(() => _rows = v.round()),
                                onSurface,
                                min: 3,
                                max: 9,
                              ),
                              const SizedBox(height: 16),
                              _buildSidebarSlider(
                                'Cols',
                                _cols.toDouble(),
                                (v) => setState(() => _cols = v.round()),
                                onSurface,
                                min: 3,
                                max: 9,
                              ),
                            ],
                          ),
                          onSurface,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _StaggeredEntrance(
                        index: 4,
                        child: _buildSidebarSection(
                          'DOT STYLE',
                          Column(
                            children: [
                              _buildSidebarSlider(
                                'Radius',
                                _dotRadius,
                                (v) => setState(() => _dotRadius = v),
                                onSurface,
                                min: 1,
                                max: 12,
                              ),
                              const SizedBox(height: 16),
                              _buildSidebarSlider(
                                'Gap',
                                _dotGap,
                                (v) => setState(() => _dotGap = v),
                                onSurface,
                                min: 1,
                                max: 14,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  _buildShapeOption('Circle', DotShape.circle, onSurface),
                                  const SizedBox(width: 8),
                                  _buildShapeOption('Rounded', DotShape.roundedSquare, onSurface),
                                ],
                              ),
                            ],
                          ),
                          onSurface,
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: SidebarExportButton(
                  copied: _copied,
                  activeColor: _activeColor,
                  onTap: _copyCode,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShapeOption(String label, DotShape shape, Color onSurface) {
    final studio = StudioProvider.of(context);
    final active = studio.shape == shape;
    return StudioInteractiveWrapper(
      onTap: () {
        HapticFeedback.selectionClick();
        studio.onShapeChanged(shape);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _activeColor : onSurface.withValues(alpha: 0.05),
          borderRadius: studio.borderRadius,
          border: Border.all(
            color: active ? _activeColor : onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              shape == DotShape.circle ? Icons.circle_outlined : Icons.crop_square_rounded,
              size: 14,
              color: active 
                  ? (_activeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                  : onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active 
                    ? (_activeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                    : onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSection(String title, Widget content, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: textColor.withValues(alpha: 0.35),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildSidebarSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
    Color textColor, {
    double min = 0,
    double max = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: _activeColor,
            inactiveTrackColor: textColor.withValues(alpha: 0.1),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildMobileControls(
    Color onSurface,
    Color trackInactive,
    bool isDark,
  ) {
    return Column(
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
        const SizedBox(height: 24),

        // Loader Size
        _SectionLabel('Loader Size (Square)', onSurface: onSurface),
        const SizedBox(height: 8),
        _StyledSlider(
          value: _loaderSize,
          min: 10.0,
          max: 99.0,
          label: '${_loaderSize.toStringAsFixed(0)} dp',
          activeColor: _activeColor,
          trackInactive: trackInactive,
          thumbColor: onSurface,
          onChanged: (v) => setState(() => _loaderSize = v),
        ),
        const SizedBox(height: 24),

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
        const SizedBox(height: 24),

        // Grid size
        _SectionLabel('Grid Size', onSurface: onSurface),
        const SizedBox(height: 8),
        Row(
          children: [
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
          ],
        ),
        const SizedBox(height: 24),

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
        const SizedBox(height: 24),

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
        const SizedBox(height: 24),

        // Dot shape
        _SectionLabel('Shape', onSurface: onSurface),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildShapeOption('Circle', DotShape.circle, onSurface),
            const SizedBox(width: 8),
            _buildShapeOption('Rounded', DotShape.roundedSquare, onSurface),
          ],
        ),
        const SizedBox(height: 24),

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
      ],
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
    return StudioInteractiveWrapper(
      onTap: () => Navigator.pop(context),
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
    return Row(
      children: [
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
      ],
    );
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
      children:
          allColors.map((c) {
            final isSelected = selected == c;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: StudioInteractiveWrapper(
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
                    borderRadius: StudioProvider.of(context).shape == DotShape.circle 
                        ? BorderRadius.circular(99) 
                        : StudioProvider.of(context).borderRadius / 2,
                    border: Border.all(
                      color: isSelected ? ringColor : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: c.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                            : null,
                  ),
                ),
              ),
            );
          }).toList(),
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
    return StudioInteractiveWrapper(
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
              color: value 
                  ? (activeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                  : onSurface, 
              shape: BoxShape.circle
            ),
          ),
        ),
      ),
    );
  }
}

/// A staggered entrance animation for list items.
class _StaggeredEntrance extends StatelessWidget {
  const _StaggeredEntrance({required this.child, required this.index});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        // Simple stagger effect using index
        final delay = index * 0.05;
        final animatedValue = (value - delay).clamp(0.0, 1.0);

        return Opacity(
          opacity: animatedValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animatedValue)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A blur transition for [AnimatedSwitcher].
class BlurTransition extends AnimatedWidget {
  const BlurTransition({
    super.key,
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: (1.0 - animation.value) * 10,
        sigmaY: (1.0 - animation.value) * 10,
      ),
      child: child,
    );
  }
}
