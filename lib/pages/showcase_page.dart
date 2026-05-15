import 'package:flutter/material.dart';
import '../src/dot_matrix_loader.dart';
import '../src/models/dot_matrix_style.dart';
import '../src/models/dot_matrix_preset.dart';
import '../widgets/preset_card.dart';

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
    tag: 'icon-01',
  ),
  _PresetEntry(
    preset: Spiral(),
    name: 'Spiral',
    description: 'A bright trace winds outward from the center.',
    category: 'Spinner',
    tag: 'icon-02',
  ),
  _PresetEntry(
    preset: Wave(),
    name: 'Wave',
    description: 'A breathing sine wave drifts left to right.',
    category: 'Ambient',
    tag: 'icon-03',
  ),
  _PresetEntry(
    preset: CrossExpand(),
    name: 'Cross Expand',
    description: 'A plus shape blooms in Manhattan steps.',
    category: 'Ambient',
    tag: 'icon-04',
  ),
  _PresetEntry(
    preset: Rain(),
    name: 'Rain',
    description: 'Independent drops fall column by column.',
    category: 'Ambient',
    tag: 'icon-05',
  ),
  _PresetEntry(
    preset: Heartbeat(),
    name: 'Heartbeat',
    description: 'A double-pulse rhythm radiates from center.',
    category: 'Progress',
    tag: 'icon-06',
  ),
  _PresetEntry(
    preset: Orbit(),
    name: 'Orbit',
    description: 'Dots cycle in concentric orbital rings.',
    category: 'Spinner',
    tag: 'icon-07',
  ),
  _PresetEntry(
    preset: Ripple(),
    name: 'Ripple',
    description: 'Sine ripples radiate outward from center.',
    category: 'Ambient',
    tag: 'icon-08',
  ),
  _PresetEntry(
    preset: Diagonal(),
    name: 'Diagonal',
    description: 'A sweep travels top-left to bottom-right.',
    category: 'Agent',
    tag: 'icon-09',
  ),
  _PresetEntry(
    preset: Bounce(),
    name: 'Bounce',
    description: 'Dots bounce vertically with column offset.',
    category: 'Spinner',
    tag: 'icon-10',
  ),
];

const _categories = ['All', 'Spinner', 'Progress', 'Ambient', 'Agent'];

/// Premium showcase gallery displaying all built-in presets.
///
/// Uses a **single** [AnimationController] shared across all visible
/// preset cards — zero extra tickers regardless of card count.
class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

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
  Color _activeColor = const Color(0xFFE53935);

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

  void _updateSpeed(double value) {
    setState(() => _speed = value);
    _sharedController.duration =
        Duration(milliseconds: (1200 / value).round());
  }

  List<_PresetEntry> get _visiblePresets {
    if (_categoryIndex == 0) return _allPresets;
    final cat = _categories[_categoryIndex];
    return _allPresets.where((p) => p.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Header ────────────────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildHeader()),

        // ── Speed + color controls ─────────────────────────────────────────
        SliverToBoxAdapter(child: _buildControls()),

        // ── Category filter ────────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildCategoryFilter()),

        // ── Grid ──────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
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
                  ),
                );
              },
              childCount: _visiblePresets.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
          // Hero loader
          Center(
            child: DotMatrixLoader(
              preset: const PulseRings(),
              style: DotMatrixStyle(
                rows: 7,
                columns: 7,
                dotRadius: 6.5,
                dotGap: 7,
                activeColor: _activeColor,
                inactiveColor: const Color(0xFF1E1E1E),
              ),
              externalAnimation: _sharedController,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'A small library\nof quiet loaders.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dot-matrix patterns, each animated from a single\n'
            'animation controller and a per-dot delay map.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Color tint
          _ColorDot(
            color: const Color(0xFFE53935),
            selected: _activeColor == const Color(0xFFE53935),
            onTap: () => setState(() => _activeColor = const Color(0xFFE53935)),
          ),
          const SizedBox(width: 8),
          _ColorDot(
            color: const Color(0xFF42A5F5),
            selected: _activeColor == const Color(0xFF42A5F5),
            onTap: () => setState(() => _activeColor = const Color(0xFF42A5F5)),
          ),
          const SizedBox(width: 8),
          _ColorDot(
            color: const Color(0xFF66BB6A),
            selected: _activeColor == const Color(0xFF66BB6A),
            onTap: () => setState(() => _activeColor = const Color(0xFF66BB6A)),
          ),
          const SizedBox(width: 8),
          _ColorDot(
            color: const Color(0xFFFFA726),
            selected: _activeColor == const Color(0xFFFFA726),
            onTap: () => setState(() => _activeColor = const Color(0xFFFFA726)),
          ),
          const SizedBox(width: 8),
          _ColorDot(
            color: Colors.white,
            selected: _activeColor == Colors.white,
            onTap: () => setState(() => _activeColor = Colors.white),
          ),
          const Spacer(),
          // Speed label
          Text(
            'SPEED',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.35),
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
                inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                thumbColor: Colors.white,
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
            width: 26,
            child: Text(
              '${_speed.toStringAsFixed(1)}×',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = _categoryIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _categoryIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? _activeColor
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
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
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            color: selected ? Colors.white : Colors.transparent,
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
