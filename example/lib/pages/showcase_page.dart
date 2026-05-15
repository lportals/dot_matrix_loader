import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';


import '../widgets/preset_card.dart';
import '../widgets/studio_widgets.dart';

/// Preset metadata for the gallery grid.
class _PresetEntry {
  const _PresetEntry({
    required this.preset,
    required this.name,
    required this.description,
    required this.category,
    required this.tag,
  });

  final DotMatrixPreset preset;
  final String name;
  final String description;
  final String category;
  final String tag;
}

const _allPresets = [
  _PresetEntry(
    preset: PulseRings(),
    name: 'Pulse Rings',
    description: 'Concentric rings expand from the center.',
    category: 'Spinner',
    tag: 'shape-01',
  ),
  _PresetEntry(
    preset: Spiral(),
    name: 'Spiral',
    description: 'A bright trace winds outward from the center.',
    category: 'Spinner',
    tag: 'shape-02',
  ),
  _PresetEntry(
    preset: Wave(),
    name: 'Wave',
    description: 'A breathing sine wave drifts left to right.',
    category: 'Ambient',
    tag: 'shape-03',
  ),
  _PresetEntry(
    preset: CrossExpand(),
    name: 'Cross Expand',
    description: 'A plus shape blooms in Manhattan steps.',
    category: 'Ambient',
    tag: 'shape-04',
  ),
  _PresetEntry(
    preset: Rain(),
    name: 'Rain',
    description: 'Independent drops fall column by column.',
    category: 'Ambient',
    tag: 'shape-05',
  ),
  _PresetEntry(
    preset: Heartbeat(),
    name: 'Heartbeat',
    description: 'A double-pulse rhythm radiates from center.',
    category: 'Progress',
    tag: 'shape-06',
  ),
  _PresetEntry(
    preset: Orbit(),
    name: 'Orbit',
    description: 'Dots cycle in concentric orbital rings.',
    category: 'Spinner',
    tag: 'shape-07',
  ),
  _PresetEntry(
    preset: Ripple(),
    name: 'Ripple',
    description: 'Sine ripples radiate outward from center.',
    category: 'Ambient',
    tag: 'shape-08',
  ),
  _PresetEntry(
    preset: Diagonal(),
    name: 'Diagonal',
    description: 'A sweep travels top-left to bottom-right.',
    category: 'Agent',
    tag: 'shape-09',
  ),
  _PresetEntry(
    preset: Bounce(),
    name: 'Bounce',
    description: 'Dots bounce vertically with column offset.',
    category: 'Spinner',
    tag: 'shape-10',
  ),
  _PresetEntry(
    preset: Shockwave(),
    name: 'Shockwave',
    description: 'A sharp ring erupts with an exponential decay.',
    category: 'Spinner',
    tag: 'shape-11',
  ),
  _PresetEntry(
    preset: Metronome(),
    name: 'Metronome',
    description: 'A vertical column swings left-right with row lag.',
    category: 'Ambient',
    tag: 'shape-12',
  ),
  _PresetEntry(
    preset: Erosion(),
    name: 'Erosion',
    description: 'A two-phase diagonal erase and refill pattern.',
    category: 'Agent',
    tag: 'shape-13',
  ),
  _PresetEntry(
    preset: Sonar(),
    name: 'Sonar',
    description: 'A ping originates from the corner and returns.',
    category: 'Agent',
    tag: 'shape-14',
  ),
  _PresetEntry(
    preset: Curtain(),
    name: 'Curtain',
    description: 'Columns fill top-down in a staggered reveal.',
    category: 'Progress',
    tag: 'shape-15',
  ),
  _PresetEntry(
    preset: Interference(),
    name: 'Interference',
    description: 'Two offset waves interfere creating moiré patterns.',
    category: 'Ambient',
    tag: 'shape-16',
  ),
  _PresetEntry(
    preset: Ticker(),
    name: 'Ticker',
    description: 'A dot races around the perimeter varying speed.',
    category: 'Spinner',
    tag: 'shape-17',
  ),
  _PresetEntry(
    preset: Genome(),
    name: 'Genome',
    description: 'Per-dot FM synthesis for an organic feel.',
    category: 'Ambient',
    tag: 'shape-18',
  ),
  _PresetEntry(
    preset: StackFill(),
    name: 'Stack Fill',
    description: 'A columnar bottom-up fill with a dome-shaped front.',
    category: 'Progress',
    tag: 'shape-19',
  ),
  _PresetEntry(
    preset: Veil(),
    name: 'Veil',
    description: 'A full brightness sweep band that rotates continuously.',
    category: 'Spinner',
    tag: 'shape-20',
  ),
  _PresetEntry(
    preset: Radar(),
    name: 'Radar',
    description: 'A classic rotating radar sweep beam.',
    category: 'Spinner',
    tag: 'shape-21',
  ),
  _PresetEntry(
    preset: Scanner(),
    name: 'Scanner',
    description: 'A scanning horizontal laser bounding up and down.',
    category: 'Agent',
    tag: 'shape-22',
  ),
  _PresetEntry(
    preset: Collapse(),
    name: 'Collapse',
    description: 'Corners collapse rapidly into the center.',
    category: 'Ambient',
    tag: 'shape-23',
  ),
  _PresetEntry(
    preset: Static(),
    name: 'Static',
    description: 'Randomized high-frequency white noise.',
    category: 'Ambient',
    tag: 'shape-24',
  ),
  _PresetEntry(
    preset: Wanderer(),
    name: 'Wanderer',
    description: 'A single dot wandering via Lissajous curves.',
    category: 'Agent',
    tag: 'shape-25',
  ),
  _PresetEntry(
    preset: Crosshair(),
    name: 'Crosshair',
    description: 'Intersecting axes moving smoothly across the grid.',
    category: 'Spinner',
    tag: 'shape-26',
  ),
  _PresetEntry(
    preset: RippleIn(),
    name: 'Ripple In',
    description: 'Concentric waves collapsing inward to the core.',
    category: 'Ambient',
    tag: 'shape-27',
  ),
  _PresetEntry(
    preset: Wipe(),
    name: 'Wipe',
    description: 'A solid directional wipe rotating in 360 degrees.',
    category: 'Progress',
    tag: 'shape-28',
  ),
  _PresetEntry(
    preset: Twinkle(),
    name: 'Twinkle',
    description: 'Smooth, asynchronous twinkling stars.',
    category: 'Ambient',
    tag: 'shape-29',
  ),
  _PresetEntry(
    preset: ZigZag(),
    name: 'ZigZag',
    description: 'A sequential raster scan snake filling the grid.',
    category: 'Progress',
    tag: 'shape-30',
  ),
  _PresetEntry(
    preset: Equalizer(),
    name: 'Equalizer',
    description: 'Dynamic audio spectrum bars reacting to phase noise.',
    category: 'Progress',
    tag: 'shape-31',
  ),
  _PresetEntry(
    preset: Gravity(),
    name: 'Gravity',
    description: 'Dots dropping and bouncing with physical gravity.',
    category: 'Agent',
    tag: 'shape-32',
  ),
  _PresetEntry(
    preset: Glitch(),
    name: 'Glitch',
    description: 'VHS-style horizontal displacement noise.',
    category: 'Ambient',
    tag: 'shape-33',
  ),
  _PresetEntry(
    preset: Diamond(),
    name: 'Diamond',
    description: 'Expanding diamond rings using Manhattan distance.',
    category: 'Ambient',
    tag: 'shape-34',
  ),
  _PresetEntry(
    preset: Checkerboard(),
    name: 'Checkerboard',
    description: 'A classic alternating grid crossfade.',
    category: 'Ambient',
    tag: 'shape-35',
  ),
  _PresetEntry(
    preset: Breathe(),
    name: 'Breathe',
    description: 'A global ease-in-out pulse mimicking deep breathing.',
    category: 'Ambient',
    tag: 'shape-36',
  ),
];

const _categories = ['All', 'Spinner', 'Progress', 'Ambient', 'Agent'];

/// Premium showcase gallery displaying all built-in presets.
///
/// Uses a **single** [AnimationController] shared across all visible
/// preset cards — zero extra tickers regardless of card count.
class ShowcasePage extends StatefulWidget {
  const ShowcasePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onSelectPreset,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onSelectPreset;

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage>
    with SingleTickerProviderStateMixin {
  /// The single shared controller. All preset cards receive this
  /// via [DotMatrixLoader.externalAnimation].
  late final AnimationController _sharedController;

  int _categoryIndex = 0;
  double _speed = 1.0;
  int _rows = 5;
  int _cols = 5;
  late Color _activeColor;

  @override
  void initState() {
    super.initState();
    _sharedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _sharedController.dispose();
    super.dispose();
  }

  /// Updates the shared controller speed.
  ///
  /// Must call [repeat] after mutating [duration] — otherwise the
  /// controller keeps running at the old speed until the next loop.
  void _updateSpeed(double value) {
    setState(() => _speed = value);
    _sharedController
      ..duration = Duration(milliseconds: (1200 / value).round())
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeColor = Theme.of(context).colorScheme.primary;
  }

  List<_PresetEntry> get _visiblePresets {
    if (_categoryIndex == 0) return _allPresets;
    final cat = _categories[_categoryIndex];
    return _allPresets.where((p) => p.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = (width / 180).floor().clamp(2, 8);

        return CustomScrollView(
          slivers: [
        // ── Header ────────────────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildHeader()),

        // ── Speed + color controls ─────────────────────────────────────────
        SliverToBoxAdapter(child: _buildControls()),

        // ── Category filter ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            // Equal breathing room above and below the chip row.
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _buildCategoryFilter(),
          ),
        ),

        // ── Grid ──────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = _visiblePresets[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(
                      milliseconds: 300 + (index % 5) * 60),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, (1 - v) * 16),
                      child: child,
                    ),
                  ),
                  child: PresetCard(
                    entry: PresetCardData(
                      preset: entry.preset,
                      name: entry.name,
                      description: entry.description,
                      tag: entry.tag,
                      category: entry.category,
                    ),
                    sharedAnimation: _sharedController,
                    activeColor: _activeColor,
                    rows: _rows,
                    cols: _cols,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onSelectPreset(entry.name);
                    },
                  ),
                );
              },
              childCount: _visiblePresets.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.82 + ((crossAxisCount - 2) * 0.05).clamp(0.0, 0.2),
            ),
          ),
        ),
      ],
    );
  },
);
  }

  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;


    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dot Matrix\nAnimations.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: onSurface,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleTheme,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      widget.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      key: ValueKey(widget.isDark),
                      size: 18,
                      color: onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '36 built-in patterns. One controller.\n'
            'Zero extra tickers.',
            style: TextStyle(
              fontSize: 13,
              color: onSurface.withValues(alpha: 0.45),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: onSurface.withValues(alpha: 0.07),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackInactive = onSurface.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color + speed row
          Row(
            children: [
              _ColorDot(
                color: Theme.of(context).colorScheme.primary,
                selected: _activeColor == Theme.of(context).colorScheme.primary,
                onTap: () => setState(() => _activeColor = Theme.of(context).colorScheme.primary),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ColorDot(
                color: const Color(0xFF42A5F5),
                selected: _activeColor == const Color(0xFF42A5F5),
                onTap: () => setState(() => _activeColor = const Color(0xFF42A5F5)),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ColorDot(
                color: const Color(0xFF66BB6A),
                selected: _activeColor == const Color(0xFF66BB6A),
                onTap: () => setState(() => _activeColor = const Color(0xFF66BB6A)),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ColorDot(
                color: const Color(0xFFAB47BC),
                selected: _activeColor == const Color(0xFFAB47BC),
                onTap: () => setState(() => _activeColor = const Color(0xFFAB47BC)),
                isDark: isDark,
              ),
              const Spacer(),
              Text(
                'SPEED',
                style: TextStyle(
                  fontSize: 10,
                  color: onSurface.withValues(alpha: 0.35),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: _activeColor,
                    inactiveTrackColor: trackInactive,
                    thumbColor: onSurface,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _speed,
                    min: 0.25,
                    max: 3.0,
                    onChanged: _updateSpeed,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 28,
                child: Text(
                  '${_speed.toStringAsFixed(1)}×',
                  style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid size row
          Row(
            children: [
              Text(
                'GRID',
                style: TextStyle(
                  fontSize: 10,
                  color: onSurface.withValues(alpha: 0.35),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'R',
                style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withValues(alpha: 0.45)),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 90,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 5),
                    activeTrackColor: _activeColor,
                    inactiveTrackColor: trackInactive,
                    thumbColor: onSurface,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _rows.toDouble(),
                    min: 3,
                    max: 5,
                    divisions: 2,
                    onChanged: (v) => setState(() => _rows = v.round()),
                  ),
                ),
              ),
              SizedBox(
                width: 22,
                child: Text(
                  '$_rows',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 11,
                      color: onSurface.withValues(alpha: 0.55)),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'C',
                style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withValues(alpha: 0.45)),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 90,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 5),
                    activeTrackColor: _activeColor,
                    inactiveTrackColor: trackInactive,
                    thumbColor: onSurface,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _cols.toDouble(),
                    min: 3,
                    max: 5,
                    divisions: 2,
                    onChanged: (v) => setState(() => _cols = v.round()),
                  ),
                ),
              ),
              SizedBox(
                width: 22,
                child: Text(
                  '$_cols',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 11,
                      color: onSurface.withValues(alpha: 0.55)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = _categoryIndex == i;
          return StudioInteractiveWrapper(
            onTap: () => setState(() => _categoryIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active
                    ? _activeColor
                    : onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? _activeColor.withValues(alpha: 0.2)
                      : onSurface.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? (_activeColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white)
                      : onSurface.withValues(alpha: 0.5),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ringColor = isDark ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? ringColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }
}
