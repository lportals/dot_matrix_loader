import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../studio_provider.dart';
import '../widgets/studio_widgets.dart';
import '../view_models/sequence_builder_view_model.dart';

/// Interactive Sequence Builder Studio enabling frame-by-frame animation timelines,
/// canvas editing grids, sequence preview dialog sheets, and haptic code generators.
class SequenceBuilderPage extends StatefulWidget {
  const SequenceBuilderPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<SequenceBuilderPage> createState() => _SequenceBuilderPageState();
}

class _SequenceBuilderPageState extends State<SequenceBuilderPage> {
  late final SequenceBuilderViewModel _viewModel;
  bool _isLivePreview = false;

  @override
  void initState() {
    super.initState();
    _viewModel = SequenceBuilderViewModel(defaultColor: Colors.white);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel.updateActiveColor(Theme.of(context).colorScheme.primary);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _resetSequence() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF242424) : Colors.white,
        title: Text(
          'Reset Sequence?',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'This will delete all current frames and start over. Are you sure?',
          style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: widget.isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      HapticFeedback.heavyImpact();
      _viewModel.clearSequence();
    }
  }

  void _onGridSizeChange(int r, int c) async {
    // If we have meaningful data, ask for confirmation
    bool hasData = _viewModel.frames.length > 1 || _viewModel.frames[0].any((row) => row.any((dot) => dot));

    if (hasData) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: widget.isDark ? const Color(0xFF242424) : Colors.white,
          title: Text(
            'Change Grid Size?',
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Changing the grid size will clear all current frames. Do you want to proceed?',
            style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Change & Reset', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    HapticFeedback.mediumImpact();
    _viewModel.changeGridSize(r, c);
  }



  void _showSettingsBottomSheet() {
    HapticFeedback.mediumImpact();
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final trackInactive = onSurface.withValues(alpha: 0.12);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF141414) : const Color(0xFFFFFFFF);
        final borderColor = isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.08);

        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: borderColor),
              ),
              padding: EdgeInsets.fromLTRB(28, 16, 28, 28 + MediaQuery.of(context).padding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SEQUENCE OPTIONS',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: onSurface,
                          letterSpacing: 0.8,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onToggleTheme();
                        },
                        icon: Icon(
                          widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 20,
                        ),
                        color: onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  _buildSequenceControlsSection(onSurface, trackInactive, widget.isDark),
                ],
              ),
            );
          },
        );
      },
    );
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
                return _buildDesktopLayout(onSurface, cardBg, borderColor, constraints);
              }
              return _buildMobileLayout(onSurface, cardBg, borderColor);
            },
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(Color onSurface, Color cardBg, Color borderColor) {
    final currentFrame = _viewModel.frames[_viewModel.currentIndex];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Title Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sequence Studio',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      'FRAME ${_viewModel.currentIndex + 1} OF ${_viewModel.frames.length}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: onSurface.withValues(alpha: 0.4),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _resetSequence,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      color: onSurface.withValues(alpha: 0.6),
                      tooltip: 'Reset Sequence',
                    ),
                    IconButton(
                      onPressed: _showSettingsBottomSheet,
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      color: onSurface.withValues(alpha: 0.6),
                      tooltip: 'Sequence Options',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Segmented Tab Selector (Design vs Live) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Center(
              child: Container(
                width: 220,
                height: 38,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isLivePreview = false);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: !_isLivePreview 
                                ? _viewModel.activeColor.withValues(alpha: 0.15) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'DESIGN',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: !_isLivePreview ? _viewModel.activeColor : onSurface.withValues(alpha: 0.4),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isLivePreview = true);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _isLivePreview 
                                ? _viewModel.activeColor.withValues(alpha: 0.15) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'LIVE PREVIEW',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: _isLivePreview ? _viewModel.activeColor : onSurface.withValues(alpha: 0.4),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Main interactive grid canvas ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: StudioProvider.of(context).borderRadius,
                      border: Border.all(color: borderColor),
                    ),
                    child: _isLivePreview
                        ? Center(
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: DotMatrixLoader(
                                key: const ValueKey('sequence_playback_loader_inline'),
                                preset: SequenceAnimation(frames: _viewModel.frames),
                                style: DotMatrixStyle(
                                  rows: _viewModel.rows,
                                  columns: _viewModel.cols,
                                  activeColor: _viewModel.activeColor,
                                  inactiveColor: widget.isDark 
                                      ? const Color(0xFF1C1C1C) 
                                      : const Color(0xFFDDDDDD),
                                  dotRadius: 4.5,
                                  dotGap: 8.0,
                                  dotShape: StudioProvider.of(context).shape,
                                ),
                              ),
                            ),
                          )
                        : _buildPixelCanvasGrid(currentFrame, onSurface),
                  ),
                ),
              ),
            ),
          ),

          // ── Timeline slider of frames ──
          SizedBox(
            height: 80,
            child: _buildTimelineCarousel(cardBg, borderColor, onSurface),
          ),

          const Divider(height: 1),

          // ── Lower toolbar & export options ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStudioToolbar(onSurface),
                const SizedBox(height: 16),
                SidebarExportButton(
                  copied: _viewModel.copied,
                  activeColor: _viewModel.activeColor,
                  onTap: () => _viewModel.copyCode(StudioProvider.of(context).shape),
                ),
              ],
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
    final trackInactive = onSurface.withValues(alpha: 0.12);
    final currentFrame = _viewModel.frames[_viewModel.currentIndex];

    return Row(
      children: [
        // ── Main Canvas Workspace ──
        Expanded(
          flex: constraints.maxWidth > 900 ? 6 : 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title block
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sequence Canvas',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: onSurface,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Text(
                          'FRAME-BY-FRAME PIXEL MATRIX ANIMATOR',
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

              // ── Segmented Tab Selector (Design vs Live) ──
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Container(
                    width: 220,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _isLivePreview = false);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !_isLivePreview 
                                    ? _viewModel.activeColor.withValues(alpha: 0.15) 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'DESIGN',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: !_isLivePreview ? _viewModel.activeColor : onSurface.withValues(alpha: 0.4),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _isLivePreview = true);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _isLivePreview 
                                    ? _viewModel.activeColor.withValues(alpha: 0.15) 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'LIVE PREVIEW',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: _isLivePreview ? _viewModel.activeColor : onSurface.withValues(alpha: 0.4),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Matrix Canvas Grid
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      margin: const EdgeInsets.all(40),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: StudioProvider.of(context).borderRadius * 1.5,
                        border: Border.all(color: borderColor, width: 1.5),
                        boxShadow: [
                          if (widget.isDark)
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
                      child: _isLivePreview
                          ? Center(
                              child: SizedBox(
                                width: 180,
                                height: 180,
                                child: DotMatrixLoader(
                                  key: const ValueKey('sequence_playback_loader_desktop'),
                                  preset: SequenceAnimation(frames: _viewModel.frames),
                                  style: DotMatrixStyle(
                                    rows: _viewModel.rows,
                                    columns: _viewModel.cols,
                                    activeColor: _viewModel.activeColor,
                                    inactiveColor: widget.isDark 
                                        ? const Color(0xFF1C1C1C) 
                                        : const Color(0xFFDDDDDD),
                                    dotRadius: 6.0,
                                    dotGap: 10.0,
                                    dotShape: StudioProvider.of(context).shape,
                                  ),
                                ),
                              ),
                            )
                          : _buildPixelCanvasGrid(currentFrame, onSurface),
                    ),
                  ),
                ),
              ),

              // Bottom Horizontal Timeline Carousel
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: _buildTimelineCarousel(cardBg, borderColor, onSurface),
              ),
            ],
          ),
        ),

        // Vertical Studio Divider
        Container(width: 1, color: borderColor),

        // ── Right Inspector Panel Sidebar ──
        Container(
          width: constraints.maxWidth > 900 ? 380 : 320,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title details
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sequence Inspector',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FRAME CONTROL & EXPORT TOOLS',
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

              // Scrollable Inspector Fields
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [


                      // Sequence Action Controls
                      Text(
                        'TIMELINE ACTIONS',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: onSurface.withValues(alpha: 0.4),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStudioToolbar(onSurface),
                      const SizedBox(height: 28),

                      // Grid details and configs
                      _buildSequenceControlsSection(onSurface, trackInactive, widget.isDark),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Sequence Export Button
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

  Widget _buildPixelCanvasGrid(List<List<bool>> frameData, Color onSurface) {
    final studio = StudioProvider.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;

        final itemWidth = totalWidth / _viewModel.cols;
        final itemHeight = totalHeight / _viewModel.rows;
        final cellSize = itemWidth < itemHeight ? itemWidth : itemHeight;

        return Center(
          child: SizedBox(
            width: cellSize * _viewModel.cols,
            height: cellSize * _viewModel.rows,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _viewModel.cols,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: _viewModel.rows * _viewModel.cols,
              itemBuilder: (context, idx) {
                final r = idx ~/ _viewModel.cols;
                final c = idx % _viewModel.cols;
                final isActive = frameData[r][c];

                return GestureDetector(
                  onTap: () => _viewModel.toggleDot(r, c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeInOutCubic,
                    decoration: BoxDecoration(
                      color: isActive ? _viewModel.activeColor : onSurface.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(
                        studio.shape == DotShape.circle ? cellSize : cellSize * 0.25,
                      ),
                      border: Border.all(
                        color: isActive
                            ? _viewModel.activeColor
                            : onSurface.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineCarousel(Color cardBg, Color borderColor, Color onSurface) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        itemCount: _viewModel.frames.length,
        itemBuilder: (context, index) {
          final frame = _viewModel.frames[index];
          final isSel = _viewModel.currentIndex == index;

          return ReorderableDelayedDragStartListener(
            key: ValueKey('timeline_frame_item_$index'),
            index: index,
            child: GestureDetector(
              onTap: () => _viewModel.selectFrame(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isSel ? _viewModel.activeColor.withValues(alpha: 0.06) : cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? _viewModel.activeColor : borderColor,
                    width: isSel ? 2.0 : 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomPaint(
                        painter: _MiniFramePainter(
                          frameData: frame,
                          activeColor: _viewModel.activeColor,
                          isDark: widget.isDark,
                          shape: StudioProvider.of(context).shape,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 4,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 8,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                          color: isSel
                              ? _viewModel.activeColor
                              : onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        onReorder: (oldIndex, newIndex) => _viewModel.reorderFrames(oldIndex, newIndex),
      ),
    );
  }

  Widget _buildStudioToolbar(Color onSurface) {
    return Row(
      children: [
        Expanded(
          child: _StudioActionButton(
            label: 'ADD FRAME',
            icon: Icons.add_rounded,
            activeColor: _viewModel.activeColor,
            isDark: widget.isDark,
            onTap: _viewModel.addFrame,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StudioActionButton(
            label: 'DUPLICATE',
            icon: Icons.copy_all_rounded,
            activeColor: _viewModel.activeColor,
            isDark: widget.isDark,
            onTap: _viewModel.duplicateFrame,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StudioActionButton(
            label: 'DELETE',
            icon: Icons.delete_outline_rounded,
            activeColor: _viewModel.activeColor,
            isDark: widget.isDark,
            onTap: _viewModel.deleteFrame,
          ),
        ),
      ],
    );
  }

  Widget _buildSequenceControlsSection(Color onSurface, Color trackInactive, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Color Picker (visible on both mobile and desktop)
        Text(
          'COLOR SYSTEM',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: 0.4),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, i) {
              final colors = [
                Theme.of(context).colorScheme.primary,
                const Color(0xFF42A5F5),
                const Color(0xFF66BB6A),
                const Color(0xFFFFA726),
                const Color(0xFFAB47BC),
                const Color(0xFFEF5350),
              ];
              final c = colors[i];
              final isSel = _viewModel.activeColor == c;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _viewModel.updateActiveColor(c);
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
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Grid Size Selectors (from 2x2 to 6x6 max!)
        Text(
          'GRID DENSITY',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: 0.4),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDensityChips(
                '2 × 2',
                _viewModel.rows == 2 && _viewModel.cols == 2,
                () => _onGridSizeChange(2, 2),
                onSurface,
              ),
              const SizedBox(width: 8),
              _buildDensityChips(
                '3 × 3',
                _viewModel.rows == 3 && _viewModel.cols == 3,
                () => _onGridSizeChange(3, 3),
                onSurface,
              ),
              const SizedBox(width: 8),
              _buildDensityChips(
                '4 × 4',
                _viewModel.rows == 4 && _viewModel.cols == 4,
                () => _onGridSizeChange(4, 4),
                onSurface,
              ),
              const SizedBox(width: 8),
              _buildDensityChips(
                '5 × 5',
                _viewModel.rows == 5 && _viewModel.cols == 5,
                () => _onGridSizeChange(5, 5),
                onSurface,
              ),
              const SizedBox(width: 8),
              _buildDensityChips(
                '6 × 6',
                _viewModel.rows == 6 && _viewModel.cols == 6,
                () => _onGridSizeChange(6, 6),
                onSurface,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Dot Shape Configurator
        Text(
          'DOT SHAPE',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: 0.4),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildShapeOptionChips(
                'CIRCULAR',
                DotShape.circle,
                onSurface,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildShapeOptionChips(
                'SQUARE',
                DotShape.roundedSquare,
                onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShapeOptionChips(String label, DotShape shape, Color onSurface) {
    final studio = StudioProvider.of(context);
    final isSel = studio.shape == shape;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        studio.onShapeChanged(shape);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        decoration: BoxDecoration(
          color: isSel ? _viewModel.activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? Colors.transparent : onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isSel
                    ? (widget.isDark ? Colors.black : Colors.white)
                    : onSurface.withValues(alpha: 0.6),
                shape: shape == DotShape.circle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: shape == DotShape.roundedSquare ? BorderRadius.circular(2.5) : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSel
                    ? (widget.isDark ? Colors.black : Colors.white)
                    : onSurface.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDensityChips(String label, bool isSel, VoidCallback onTap, Color onSurface) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        width: 76,
        decoration: BoxDecoration(
          color: isSel ? _viewModel.activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? Colors.transparent : onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isSel
                  ? (widget.isDark ? Colors.black : Colors.white)
                  : onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Secondary Layout Components ──

class _StudioActionButton extends StatefulWidget {
  const _StudioActionButton({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_StudioActionButton> createState() => _StudioActionButtonState();
}

class _StudioActionButtonState extends State<_StudioActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = widget.isDark ? const Color(0xFF161616) : const Color(0xFFF0F0F0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: onSurface.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: onSurface.withValues(alpha: 0.7)),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: onSurface.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini canvas painter representing each frame thumbnail.
class _MiniFramePainter extends CustomPainter {
  const _MiniFramePainter({
    required this.frameData,
    required this.activeColor,
    required this.isDark,
    required this.shape,
  });

  final List<List<bool>> frameData;
  final Color activeColor;
  final bool isDark;
  final DotShape shape;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = frameData.length;
    final cols = frameData[0].length;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    final dotRadius = (cellWidth < cellHeight ? cellWidth : cellHeight) * 0.4;

    final paintActive = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final paintInactive = Paint()
      ..color = isDark ? const Color(0xFF202020) : const Color(0xFFE5E5E5)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * cellWidth + cellWidth / 2;
        final cy = r * cellHeight + cellHeight / 2;
        final isActive = frameData[r][c];

        final targetPaint = isActive ? paintActive : paintInactive;

        if (shape == DotShape.circle) {
          canvas.drawCircle(Offset(cx, cy), dotRadius, targetPaint);
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCircle(center: Offset(cx, cy), radius: dotRadius),
              Radius.circular(dotRadius * 0.25),
            ),
            targetPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
