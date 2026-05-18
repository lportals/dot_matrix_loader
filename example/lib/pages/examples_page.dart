import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../studio_provider.dart';
import '../widgets/studio_widgets.dart';
import '../data/models/config_data.dart';
import '../data/repositories/preset_repository.dart';
import '../view_models/examples_view_model.dart';

/// Premium Interactive Dashboard showing custom status indicators, complete with
/// live dynamic code export, a custom configuration bottom sheet and recommended agent use-cases.
class ExamplesPage extends StatefulWidget {
  const ExamplesPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage>
    with SingleTickerProviderStateMixin {
  /// Shared controller for zero-overhead, perfectly synced indicator grids.
  late final AnimationController _sharedController;
  late final ExamplesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _sharedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _viewModel = ExamplesViewModel(defaultColor: Colors.white);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel.updateDefaultColor(Theme.of(context).colorScheme.primary);
  }

  @override
  void dispose() {
    _sharedController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// Launches the configuration bottom sheet playground.
  void _showFilterBottomSheet() {
    HapticFeedback.mediumImpact();
    final activeColor = _viewModel.activeSelectedColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => _ConfigurationBottomSheet(
        isDark: widget.isDark,
        initialLabel: _viewModel.activeLabel,
        initialPresetName: _viewModel.activePresetName,
        initialRows: _viewModel.activeRows,
        initialCols: _viewModel.activeCols,
        initialRadius: _viewModel.activeRadius,
        initialGap: _viewModel.activeGap,
        initialShape: _viewModel.activeShape,
        initialColor: activeColor,
        onChanged: (data) => _viewModel.updateConfig(data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final bgColor = widget.isDark ? const Color(0xFF080808) : const Color(0xFFF8F9FA);
        final surfaceColor = widget.isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = widget.isDark ? Colors.white : Colors.black;
        final borderColor = widget.isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE0E0E0);
        final activeColor = _viewModel.activeSelectedColor;
        final codeSnippet = _viewModel.generateCodeSnippet(widget.isDark);

        final mainContent = SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Playground & Code Inspector Section ──
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktopLayout = constraints.maxWidth > 850;

                  final playgroundCapsule = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INTERACTIVE PLAYGROUND',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: textColor.withValues(alpha: 0.4),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPlaygroundPillCard(surfaceColor, borderColor, textColor),
                      const SizedBox(height: 16),
                      // Configuration status indicator quick display helper
                      GestureDetector(
                        onTap: _showFilterBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: activeColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: activeColor.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tune_rounded, size: 12, color: activeColor),
                              const SizedBox(width: 6),
                              Text(
                                '${PresetRepository.formatPresetName(_viewModel.activePresetName)} (${_viewModel.activeRows}x${_viewModel.activeCols}) | Radius: ${_viewModel.activeRadius.toStringAsFixed(1)} | Gap: ${_viewModel.activeGap.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: activeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                  final codeInspector = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DART SOURCE CODE',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: textColor.withValues(alpha: 0.4),
                              letterSpacing: 1.0,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_viewModel.isCodeExpanded) ...[
                                _buildCopyButton(activeColor),
                                const SizedBox(width: 12),
                              ],
                              GestureDetector(
                                onTap: _viewModel.toggleCodeExpanded,
                                child: Row(
                                  children: [
                                    Text(
                                      _viewModel.isCodeExpanded ? 'HIDE CODE' : 'SHOW CODE',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: activeColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _viewModel.isCodeExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                      color: activeColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AnimatedCrossFade(
                        firstChild: _buildCodeInspector(
                          codeSnippet,
                          surfaceColor,
                          borderColor,
                          textColor,
                          activeColor,
                          showHeader: false,
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: _viewModel.isCodeExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  );

                  if (isDesktopLayout) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: playgroundCapsule,
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: _buildCodeInspector(
                              codeSnippet,
                              surfaceColor,
                              borderColor,
                              textColor,
                              activeColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        playgroundCapsule,
                        const SizedBox(height: 24),
                        codeInspector,
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 40),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 32),

              // ── Simulated System Cases (Grid of 36 Presets) ──
              _buildSimulatedCasesSection(surfaceColor, borderColor, textColor, activeColor),
            ],
          ),
        );

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(textColor, borderColor),
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Top Bar Header exactly matched to the design and alignment of Showcase & Sequence builders.
  Widget _buildTopBar(Color textColor, Color borderColor) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 20,
        vertical: isDesktop ? 24 : 16,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scenario Simulator',
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 24,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: isDesktop ? -1.0 : -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'REAL-WORLD SYSTEM INTEGRATION PLAYGROUND',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: textColor.withValues(alpha: 0.4),
                    letterSpacing: isDesktop ? 1.2 : 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StudioIconButton(
                icon: widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: widget.onToggleTheme,
                tooltip: 'Toggle Theme',
              ),
              const SizedBox(width: 8),
              StudioIconButton(
                icon: Icons.tune_rounded,
                onTap: _showFilterBottomSheet,
                tooltip: 'Scenario Options',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Centered custom-configurable capsule playground without a card background.
  Widget _buildPlaygroundPillCard(Color surfaceColor, Color borderColor, Color textColor) {
    return Center(
      child: _StatusPillButton(
        key: const ValueKey('examples_playground_pill'),
        label: _viewModel.activeLabel,
        preset: PresetRepository.presetsByClassName[_viewModel.activePresetName]!,
        sharedAnimation: _sharedController,
        isSelected: true,
        isDark: widget.isDark,
        activeColorOverride: _viewModel.activeSelectedColor,
        shapeOverride: _viewModel.activeShape,
        radiusOverride: _viewModel.activeRadius,
        gapOverride: _viewModel.activeGap,
        rowsOverride: _viewModel.activeRows,
        colsOverride: _viewModel.activeCols,
        onTap: _showFilterBottomSheet,
      ),
    );
  }

  /// System Active processes grid simulating real-world workloads using all 36 presets.
  Widget _buildSimulatedCasesSection(Color surfaceColor, Color borderColor, Color textColor, Color activeColor) {
    final filtered = _viewModel.filteredExamples;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INTEGRATION USE CASES',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: textColor.withValues(alpha: 0.4),
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '${filtered.length} ACTIVE SCENARIOS',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Bar
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: textColor.withValues(alpha: 0.4)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) => _viewModel.updateSearchQuery(val),
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search simulated background AI and system tasks...',
                    hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_viewModel.searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () => _viewModel.updateSearchQuery(''),
                  child: Icon(Icons.clear_rounded, size: 16, color: textColor.withValues(alpha: 0.4)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Category Chips
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _viewModel.categories.length,
            itemBuilder: (context, idx) {
              final cat = _viewModel.categories[idx];
              final isSel = _viewModel.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _viewModel.updateCategory(cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? activeColor : surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSel ? Colors.transparent : borderColor),
                    ),
                    child: Center(
                      child: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isSel
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                              : textColor.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Grid of simulated active cases
        filtered.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 36, color: textColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text(
                        'No running processes found matching filters.',
                        style: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 1100 ? 3 : (width > 700 ? 2 : 1);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 136,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      final isCurrentSelected = _viewModel.activePresetName == item.preset.runtimeType.toString();

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _viewModel.updateConfig(
                            ConfigData(
                              label: item.activeText,
                              presetName: item.preset.runtimeType.toString(),
                              rows: item.rows,
                              cols: item.cols,
                              radius: 2.2,
                              gap: 3.2,
                              shape: _viewModel.activeShape,
                              color: _viewModel.activeSelectedColor,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCurrentSelected ? activeColor.withValues(alpha: 0.05) : surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrentSelected ? activeColor.withValues(alpha: 0.5) : borderColor,
                              width: isCurrentSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: textColor.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DotMatrixLoader(
                                      key: ValueKey('grid_loader_${item.name}'),
                                      preset: item.preset,
                                      style: DotMatrixStyle(
                                        columns: item.cols,
                                        rows: item.rows,
                                        dotRadius: 1.5,
                                        dotGap: 2.2,
                                        activeColor: isCurrentSelected 
                                            ? activeColor 
                                            : activeColor.withValues(alpha: 0.2),
                                        inactiveColor: isCurrentSelected
                                            ? activeColor.withValues(alpha: 0.08)
                                            : textColor.withValues(alpha: 0.05),
                                        dotShape: _viewModel.activeShape,
                                      ),
                                      externalAnimation: _sharedController,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.category.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            color: activeColor.withValues(alpha: 0.7),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: textColor.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.preset.runtimeType.toString(),
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: textColor.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ],
    );
  }

  /// A premium copy button to replicate current code configurations to system clipboard.
  Widget _buildCopyButton(Color activeColor) {
    return GestureDetector(
      onTap: () => _viewModel.copySnippetToClipboard(widget.isDark),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _viewModel.codeCopied
              ? Colors.green.withValues(alpha: 0.15)
              : activeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _viewModel.codeCopied
                ? Colors.green.withValues(alpha: 0.3)
                : activeColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _viewModel.codeCopied ? Icons.check_rounded : Icons.copy_rounded,
              size: 12,
              color: _viewModel.codeCopied ? Colors.green : activeColor,
            ),
            const SizedBox(width: 6),
            Text(
              _viewModel.codeCopied ? 'COPIED' : 'COPY',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _viewModel.codeCopied ? Colors.green : activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive Code Inspector card showcasing current layout syntax.
  Widget _buildCodeInspector(
    String snippet,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color activeColor, {
    bool showHeader = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DART SOURCE CODE',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: textColor.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              _buildCopyButton(activeColor),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            snippet,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: widget.isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPillButton extends StatefulWidget {
  const _StatusPillButton({
    super.key,
    required this.label,
    required this.preset,
    required this.sharedAnimation,
    required this.isSelected,
    required this.isDark,
    this.activeColorOverride,
    this.shapeOverride,
    this.radiusOverride,
    this.gapOverride,
    this.rowsOverride,
    this.colsOverride,
    required this.onTap,
  });

  final String label;
  final DotMatrixPreset preset;
  final Animation<double> sharedAnimation;
  final bool isSelected;
  final bool isDark;
  final Color? activeColorOverride;
  final DotShape? shapeOverride;
  final double? radiusOverride;
  final double? gapOverride;
  final int? rowsOverride;
  final int? colsOverride;
  final VoidCallback onTap;

  @override
  State<_StatusPillButton> createState() => _StatusPillButtonState();
}

class _StatusPillButtonState extends State<_StatusPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final studio = StudioProvider.of(context);

    // Resolve playground overrides or default to monochrome settings
    final activeColor = widget.activeColorOverride ?? (widget.isDark ? Colors.white : Colors.black);
    final inactiveColor = widget.isDark
        ? activeColor.withValues(alpha: 0.08)
        : activeColor.withValues(alpha: 0.08);

    final resolvedShape = widget.shapeOverride ?? studio.shape;
    final resolvedRadius = widget.radiusOverride ?? 2.2;
    final resolvedGap = widget.gapOverride ?? 3.2;
    final resolvedRows = widget.rowsOverride ?? 3;
    final resolvedCols = widget.colsOverride ?? 3;

    final textColor = widget.isSelected
        ? (widget.isDark ? Colors.white : Colors.black)
        : (widget.isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7));

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : (widget.isSelected ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 450),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30), // Capsule pill shape
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: DotMatrixLoader(
                  key: ValueKey('examples_pill_loader_${widget.label}'),
                  preset: widget.preset,
                  style: DotMatrixStyle(
                    columns: resolvedCols,
                    rows: resolvedRows,
                    dotRadius: resolvedRadius,
                    dotGap: resolvedGap,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    dotShape: resolvedShape,
                  ),
                  externalAnimation: widget.sharedAnimation,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom stateful bottom sheet enabling real-time interactive adjustments
/// of our status indicators. Styled with high-fidelity, fluid aesthetics.
class _ConfigurationBottomSheet extends StatefulWidget {
  const _ConfigurationBottomSheet({
    required this.isDark,
    required this.initialLabel,
    required this.initialPresetName,
    required this.initialRows,
    required this.initialCols,
    required this.initialRadius,
    required this.initialGap,
    required this.initialShape,
    required this.initialColor,
    required this.onChanged,
  });

  final bool isDark;
  final String initialLabel;
  final String initialPresetName;
  final int initialRows;
  final int initialCols;
  final double initialRadius;
  final double initialGap;
  final DotShape initialShape;
  final Color initialColor;
  final ValueChanged<ConfigData> onChanged;

  @override
  State<_ConfigurationBottomSheet> createState() => _ConfigurationBottomSheetState();
}

class _ConfigurationBottomSheetState extends State<_ConfigurationBottomSheet> {
  late final TextEditingController _textController;
  late String _selectedPresetName;
  late int _rows;
  late int _cols;
  late double _radius;
  late double _gap;
  late DotShape _shape;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialLabel);
    _selectedPresetName = widget.initialPresetName;
    _rows = widget.initialRows;
    _cols = widget.initialCols;
    _radius = widget.initialRadius;
    _gap = widget.initialGap;
    _shape = widget.initialShape;
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      ConfigData(
        label: _textController.text,
        presetName: _selectedPresetName,
        rows: _rows,
        cols: _cols,
        radius: _radius,
        gap: _gap,
        shape: _shape,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final borderColor = widget.isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE0E0E0);

    final List<Color> colors = [
      Theme.of(context).colorScheme.primary,
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFFEF5350),
    ];

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Playground Setup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Title input text field
              Text(
                'LABEL / TASK DESCRIPTION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: textColor.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: TextField(
                    controller: _textController,
                    onChanged: (_) => _notifyChange(),
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter active task status...',
                      hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Preset Selector Dropdown
              Text(
                'ALGORITHMIC PRESET',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: textColor.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPresetName,
                    dropdownColor: cardBg,
                    style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                    items: PresetRepository.presetsByClassName.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(PresetRepository.formatPresetName(key)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedPresetName = val);
                        _notifyChange();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Color Row Selector
              Text(
                'COLOR SYSTEM',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: textColor.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  itemBuilder: (context, idx) {
                    final color = colors[idx];
                    final isSel = _selectedColor == color;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedColor = color);
                          _notifyChange();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel
                                  ? (widget.isDark ? Colors.white : Colors.black)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Sliders Configuration
              Row(
                children: [
                  Expanded(
                    child: _buildSliderField(
                      'ROWS',
                      _rows.toDouble(),
                      (val) {
                        setState(() => _rows = val.round());
                        _notifyChange();
                      },
                      3,
                      9,
                      textColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSliderField(
                      'COLUMNS',
                      _cols.toDouble(),
                      (val) {
                        setState(() => _cols = val.round());
                        _notifyChange();
                      },
                      3,
                      9,
                      textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildSliderField(
                      'DOT RADIUS',
                      _radius,
                      (val) {
                        setState(() => _radius = val);
                        _notifyChange();
                      },
                      1.0,
                      4.0,
                      textColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSliderField(
                      'GAP SPACING',
                      _gap,
                      (val) {
                        setState(() => _gap = val);
                        _notifyChange();
                      },
                      1.0,
                      8.0,
                      textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dot Shape Selection
              Text(
                'DOT SHAPE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: textColor.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildShapeButton(
                      'CIRCULAR',
                      DotShape.circle,
                      textColor,
                      borderColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildShapeButton(
                      'SQUARE',
                      DotShape.roundedSquare,
                      textColor,
                      borderColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderField(
    String label,
    double value,
    ValueChanged<double> onChanged,
    double min,
    double max,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: textColor.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: _selectedColor,
            inactiveTrackColor: textColor.withValues(alpha: 0.08),
            thumbColor: _selectedColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildShapeButton(
    String label,
    DotShape shape,
    Color textColor,
    Color borderColor,
  ) {
    final active = _shape == shape;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _shape = shape);
        _notifyChange();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: active ? _selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? Colors.transparent : borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active
                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                  : textColor.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
