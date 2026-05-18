import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../studio_provider.dart';
import '../widgets/studio_widgets.dart';
import '../data/repositories/preset_repository.dart';
import '../view_models/builder_view_model.dart';

/// Single preset inspector builder enabling fine-grained interactive customization
/// of dot spacings, matrix row/col counts, lerp blending and code generator templates.
class BuilderPage extends StatefulWidget {
  const BuilderPage({
    super.key,
    this.initialPresetName,
    this.initialRows,
    this.initialCols,
    this.initialSpeed,
    this.initialColor,
    required this.isDark,
    required this.onToggleTheme,
  });

  final String? initialPresetName;
  final int? initialRows;
  final int? initialCols;
  final double? initialSpeed;
  final Color? initialColor;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<BuilderPage> createState() => _BuilderPageState();
}

class _BuilderPageState extends State<BuilderPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final BuilderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final speed = widget.initialSpeed ?? 1.0;
    _viewModel = BuilderViewModel(
      initialPresetName: widget.initialPresetName ?? PresetRepository.presetsByDisplayName.keys.first,
      initialColor: widget.initialColor ?? Colors.white,
      initialRows: widget.initialRows ?? 5,
      initialCols: widget.initialCols ?? 5,
      initialSpeed: speed,
    );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1200 / speed).round()),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialColor == null) {
      _viewModel.updateColor(Theme.of(context).colorScheme.primary);
    }
  }

  @override
  void didUpdateWidget(covariant BuilderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPresetName != oldWidget.initialPresetName &&
        widget.initialPresetName != null) {
      _viewModel.updatePreset(widget.initialPresetName!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = widget.isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);
    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.08);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
      },
    );
  }

  Widget _buildMobileLayout(Color onSurface, Color cardBg, Color borderColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveDot = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFDDDDDD);
    final trackInactive = onSurface.withValues(alpha: 0.12);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _BackButton(color: onSurface),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _viewModel.presetName,
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

          // ── Live preview ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Center(
              child: Container(
                width: (_viewModel.loaderSize + 80).clamp(140.0, 240.0),
                height: (_viewModel.loaderSize + 80).clamp(140.0, 240.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: StudioProvider.of(context).borderRadius * 1.2,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(_viewModel.loaderSize * 0.4 + 20),
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: 0.03),
                              borderRadius: StudioProvider.of(context).borderRadius,
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
                                key: ValueKey(_viewModel.presetName),
                                child: DotMatrixLoader(
                                  size: _viewModel.loaderSize,
                                  preset: _viewModel.preset,
                                  style: DotMatrixStyle(
                                    rows: _viewModel.rows,
                                    columns: _viewModel.cols,
                                    activeColor: _viewModel.activeColor,
                                    inactiveColor: inactiveDot,
                                    dotRadius: _viewModel.dotRadius,
                                    dotGap: _viewModel.dotGap,
                                    dotShape: StudioProvider.of(context).shape,
                                    enableColorLerp: _viewModel.enableColorLerp,
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

          // ── Controls ──
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

          // ── Export button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SidebarExportButton(
              copied: _viewModel.copied,
              activeColor: _viewModel.activeColor,
              onTap: () => _viewModel.copyCode(StudioProvider.of(context).shape),
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
    final inactiveDot = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFDDDDDD);
    final trackInactive = onSurface.withValues(alpha: 0.12);

    return Row(
      children: [
        // ── Main Preview Area ──
        Expanded(
          flex: constraints.maxWidth > 900 ? 6 : 5,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Theme Toggle + Back)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BackButton(color: onSurface),
                      IconButton(
                        onPressed: widget.onToggleTheme,
                        icon: Icon(
                          widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        ),
                        color: onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),

                // Main centered workspace
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: _StaggeredEntrance(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: (_viewModel.loaderSize + 160).clamp(200.0, 360.0),
                            height: (_viewModel.loaderSize + 160).clamp(200.0, 360.0),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: StudioProvider.of(context).borderRadius * 1.5,
                              border: Border.all(color: borderColor, width: 1.5),
                              boxShadow: [
                                if (isDark)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                else
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    Center(
                                      child: KeyedSubtree(
                                        key: ValueKey(_viewModel.presetName),
                                        child: DotMatrixLoader(
                                          size: _viewModel.loaderSize * 1.5,
                                          preset: _viewModel.preset,
                                          style: DotMatrixStyle(
                                            rows: _viewModel.rows,
                                            columns: _viewModel.cols,
                                            activeColor: _viewModel.activeColor,
                                            inactiveColor: inactiveDot,
                                            dotRadius: _viewModel.dotRadius * 1.5,
                                            dotGap: _viewModel.dotGap * 1.5,
                                            dotShape: StudioProvider.of(context).shape,
                                            enableColorLerp: _viewModel.enableColorLerp,
                                          ),
                                          externalAnimation: _controller,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Vertical Divider
        Container(width: 1, color: borderColor),

        // ── Right Inspector Sidebar ──
        Container(
          width: constraints.maxWidth > 900 ? 380 : 320,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title & Category details
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _viewModel.presetName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ALGORITHMIC PRESET CUSTOMIZER',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: onSurface.withValues(alpha: 0.4),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),

              // Sidebar Controls Scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Color
                      _SectionLabel('COLOR SYSTEM', onSurface: onSurface),
                      const SizedBox(height: 12),
                      _ColorRow(
                        selected: _viewModel.activeColor,
                        isDark: isDark,
                        onSelect: (c) => _viewModel.updateColor(c),
                        themePrimary: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),

                      // Dimensions / Sliders
                      _SectionLabel('SIZE (SQUARE)', onSurface: onSurface),
                      const SizedBox(height: 8),
                      _StyledSlider(
                        value: _viewModel.loaderSize,
                        min: 10.0,
                        max: 99.0,
                        label: '${_viewModel.loaderSize.toStringAsFixed(0)} dp',
                        activeColor: _viewModel.activeColor,
                        trackInactive: trackInactive,
                        thumbColor: onSurface,
                        onChanged: (v) => _viewModel.updateLoaderSize(v),
                      ),
                      const SizedBox(height: 24),

                      _SectionLabel('SPEED', onSurface: onSurface),
                      const SizedBox(height: 8),
                      _StyledSlider(
                        value: _viewModel.speed,
                        min: 0.25,
                        max: 3.0,
                        label: '${_viewModel.speed.toStringAsFixed(2)}×',
                        activeColor: _viewModel.activeColor,
                        trackInactive: trackInactive,
                        thumbColor: onSurface,
                        onChanged: (v) => _viewModel.updateSpeed(v, _controller),
                      ),
                      const SizedBox(height: 24),

                      _SectionLabel('GRID LAYOUT', onSurface: onSurface),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _StyledSlider(
                              value: _viewModel.rows.toDouble(),
                              min: 3,
                              max: 9,
                              divisions: 6,
                              label: '${_viewModel.rows} rows',
                              activeColor: _viewModel.activeColor,
                              trackInactive: trackInactive,
                              thumbColor: onSurface,
                              onChanged: (v) => _viewModel.updateRows(v.round()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StyledSlider(
                              value: _viewModel.cols.toDouble(),
                              min: 3,
                              max: 9,
                              divisions: 6,
                              label: '${_viewModel.cols} cols',
                              activeColor: _viewModel.activeColor,
                              trackInactive: trackInactive,
                              thumbColor: onSurface,
                              onChanged: (v) => _viewModel.updateCols(v.round()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _SectionLabel('DOT SIZE', onSurface: onSurface),
                      const SizedBox(height: 8),
                      _StyledSlider(
                        value: _viewModel.dotRadius,
                        min: 1.0,
                        max: 12.0,
                        label: '${_viewModel.dotRadius.toStringAsFixed(1)} dp',
                        activeColor: _viewModel.activeColor,
                        trackInactive: trackInactive,
                        thumbColor: onSurface,
                        onChanged: (v) => _viewModel.updateRadius(v),
                      ),
                      const SizedBox(height: 24),

                      _SectionLabel('DOT GAP SPACING', onSurface: onSurface),
                      const SizedBox(height: 8),
                      _StyledSlider(
                        value: _viewModel.dotGap,
                        min: 1.0,
                        max: 14.0,
                        label: '${_viewModel.dotGap.toStringAsFixed(1)} dp',
                        activeColor: _viewModel.activeColor,
                        trackInactive: trackInactive,
                        thumbColor: onSurface,
                        onChanged: (v) => _viewModel.updateGap(v),
                      ),
                      const SizedBox(height: 24),

                      _SectionLabel('DOT SHAPE', onSurface: onSurface),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildShapeOption('Circle', DotShape.circle, onSurface),
                          const SizedBox(width: 8),
                          _buildShapeOption('Rounded', DotShape.roundedSquare, onSurface),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Color lerp toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Color lerp blending',
                            style: TextStyle(
                              fontSize: 13,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          _Toggle(
                            value: _viewModel.enableColorLerp,
                            activeColor: _viewModel.activeColor,
                            onSurface: onSurface,
                            onChanged: (v) => _viewModel.toggleColorLerp(v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Export / Code Copy bottom section
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: SidebarExportButton(
                  copied: _viewModel.copied,
                  activeColor: _viewModel.activeColor,
                  onTap: () => _viewModel.copyCode(StudioProvider.of(context).shape),
                ),
              ),
            ],
          ),
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
          selected: _viewModel.activeColor,
          isDark: isDark,
          onSelect: (c) => _viewModel.updateColor(c),
          themePrimary: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),

        // Loader Size
        _SectionLabel('Loader Size (Square)', onSurface: onSurface),
        const SizedBox(height: 8),
        _StyledSlider(
          value: _viewModel.loaderSize,
          min: 10.0,
          max: 99.0,
          label: '${_viewModel.loaderSize.toStringAsFixed(0)} dp',
          activeColor: _viewModel.activeColor,
          trackInactive: trackInactive,
          thumbColor: onSurface,
          onChanged: (v) => _viewModel.updateLoaderSize(v),
        ),
        const SizedBox(height: 24),

        // Speed
        _SectionLabel('Speed', onSurface: onSurface),
        const SizedBox(height: 8),
        _StyledSlider(
          value: _viewModel.speed,
          min: 0.25,
          max: 3.0,
          label: '${_viewModel.speed.toStringAsFixed(1)}×',
          activeColor: _viewModel.activeColor,
          trackInactive: trackInactive,
          thumbColor: onSurface,
          onChanged: (v) => _viewModel.updateSpeed(v, _controller),
        ),
        const SizedBox(height: 24),

        // Grid size
        _SectionLabel('Grid Size', onSurface: onSurface),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StyledSlider(
                value: _viewModel.rows.toDouble(),
                min: 3,
                max: 9,
                divisions: 6,
                label: '${_viewModel.rows} rows',
                activeColor: _viewModel.activeColor,
                trackInactive: trackInactive,
                thumbColor: onSurface,
                onChanged: (v) => _viewModel.updateRows(v.round()),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StyledSlider(
                value: _viewModel.cols.toDouble(),
                min: 3,
                max: 9,
                divisions: 6,
                label: '${_viewModel.cols} cols',
                activeColor: _viewModel.activeColor,
                trackInactive: trackInactive,
                thumbColor: onSurface,
                onChanged: (v) => _viewModel.updateCols(v.round()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Dot radius
        _SectionLabel('Dot Size', onSurface: onSurface),
        const SizedBox(height: 8),
        _StyledSlider(
          value: _viewModel.dotRadius,
          min: 1.0,
          max: 12.0,
          label: '${_viewModel.dotRadius.toStringAsFixed(1)} dp',
          activeColor: _viewModel.activeColor,
          trackInactive: trackInactive,
          thumbColor: onSurface,
          onChanged: (v) => _viewModel.updateRadius(v),
        ),
        const SizedBox(height: 24),

        // Dot gap
        _SectionLabel('Dot Gap', onSurface: onSurface),
        const SizedBox(height: 8),
        _StyledSlider(
          value: _viewModel.dotGap,
          min: 1.0,
          max: 14.0,
          label: '${_viewModel.dotGap.toStringAsFixed(1)} dp',
          activeColor: _viewModel.activeColor,
          trackInactive: trackInactive,
          thumbColor: onSurface,
          onChanged: (v) => _viewModel.updateGap(v),
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
              value: _viewModel.enableColorLerp,
              activeColor: _viewModel.activeColor,
              onSurface: onSurface,
              onChanged: (v) => _viewModel.toggleColorLerp(v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShapeOption(String label, DotShape shape, Color onSurface) {
    final studio = StudioProvider.of(context);
    final active = studio.shape == shape;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          studio.onShapeChanged(shape);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: active ? _viewModel.activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? Colors.transparent : onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: active
                    ? (widget.isDark ? Colors.black : Colors.white)
                    : onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private helper widgets ──

/// Simple back button.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.maybePop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 14,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

/// Small gray title for inspector sections.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.onSurface});
  final String text;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: onSurface.withValues(alpha: 0.4),
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Fluid customizable slider matching design language.
class _StyledSlider extends StatelessWidget {
  const _StyledSlider({
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.label,
    required this.activeColor,
    required this.trackInactive,
    required this.thumbColor,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String label;
  final Color activeColor;
  final Color trackInactive;
  final Color thumbColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: thumbColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: activeColor,
            inactiveTrackColor: trackInactive,
            thumbColor: activeColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
      ],
    );
  }
}

/// Discrete selectable color row aligning to the monochrome studio theme.
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

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      themePrimary,
      const Color(0xFF42A5F5), // Blue
      const Color(0xFF66BB6A), // Green
      const Color(0xFFFFA726), // Amber
      const Color(0xFFAB47BC), // Purple
      const Color(0xFFEF5350), // Red
    ];

    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, i) {
          final c = colors[i];
          final isSel = selected == c;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(c);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel
                        ? (isDark ? Colors.white : Colors.black)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    if (isSel)
                      BoxShadow(
                        color: c.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Toggle switch for color lerp options.
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
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: value ? activeColor : onSurface.withValues(alpha: 0.08),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                  : onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Staggered entry animation on load.
class _StaggeredEntrance extends StatefulWidget {
  const _StaggeredEntrance({required this.child});
  final Widget child;

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnim, child: widget.child);
  }
}

/// Custom blur transition widget.
class BlurTransition extends AnimatedWidget {
  const BlurTransition({
    super.key,
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  final Widget child;

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    // Custom blur value calculation
    final blur = (1.0 - _progress.value) * 8.0;
    if (blur <= 0.01) return child;
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          colors: [Colors.black.withValues(alpha: 1.0 - (blur / 8.0)), Colors.black],
        ).createShader(rect);
      },
      child: child,
    );
  }
}
