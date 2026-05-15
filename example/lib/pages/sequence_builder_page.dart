import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import '../widgets/studio_widgets.dart';



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
  int _rows = 5;
  int _cols = 5;
  
  final List<List<List<bool>>> _frames = [];
  int _currentIndex = 0;
  bool _copied = false;
  
  late Color _activeColor;
  @override
  void initState() {
    super.initState();
    _frames.add(_createEmptyFrame(_rows, _cols));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeColor = Theme.of(context).colorScheme.primary;
  }
  
  List<List<bool>> _createEmptyFrame(int r, int c) {
    return List.generate(r, (_) => List.generate(c, (_) => false));
  }
  
  List<List<bool>> _cloneFrame(List<List<bool>> source) {
    return source.map((row) => List<bool>.from(row)).toList();
  }

  void _addFrame() {
    HapticFeedback.lightImpact();
    setState(() {
      _frames.insert(_currentIndex + 1, _createEmptyFrame(_rows, _cols));
      _currentIndex++;
    });
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
      setState(() {
        _frames.clear();
        _frames.add(_createEmptyFrame(_rows, _cols));
        _currentIndex = 0;
      });
    }
  }

  void _onGridSizeChange(int r, int c) async {
    // If we have meaningful data, ask for confirmation
    bool hasData = _frames.length > 1 || _frames[0].any((row) => row.any((dot) => dot));
    
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
    setState(() {
      _rows = r;
      _cols = c;
      _frames.clear();
      _frames.add(_createEmptyFrame(_rows, _cols));
      _currentIndex = 0;
    });
  }
  
  void _duplicateFrame() {
    HapticFeedback.lightImpact();
    setState(() {
      _frames.insert(_currentIndex + 1, _cloneFrame(_frames[_currentIndex]));
      _currentIndex++;
    });
  }
  
  void _deleteFrame() {
    if (_frames.length == 1) return;
    HapticFeedback.lightImpact();
    setState(() {
      _frames.removeAt(_currentIndex);
      if (_currentIndex >= _frames.length) {
        _currentIndex = _frames.length - 1;
      }
    });
  }
  
  void _toggleDot(int r, int c) {
    HapticFeedback.selectionClick();
    setState(() {
      _frames[_currentIndex][r][c] = !_frames[_currentIndex][r][c];
    });
  }

  String get _generatedCode {
    final r = _activeColor.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _activeColor.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _activeColor.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
    final colorHex = '$r$g$b';

    final sb = StringBuffer();
    sb.writeln('DotMatrixLoader(');
    sb.writeln('  preset: SequenceAnimation(');
    sb.writeln('    frames: [');
    for (var frame in _frames) {
      sb.writeln('      [');
      for (var row in frame) {
        sb.write('        [');
        sb.write(row.map((b) => b.toString()).join(', '));
        sb.writeln('],');
      }
      sb.writeln('      ],');
    }
    sb.writeln('    ],');
    sb.writeln('  ),');
    sb.writeln('  style: DotMatrixStyle(');
    sb.writeln('    rows: $_rows,');
    sb.writeln('    columns: $_cols,');
    sb.writeln('    activeColor: const Color(0xFF$colorHex),');
    sb.writeln('    inactiveColor: const Color(0xFF1C1C1C),');
    sb.writeln('  ),');
    sb.writeln(')');
    return sb.toString();
  }

  Future<void> _copyCode() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _generatedCode));
    if (mounted) {
      // Just set copied to true and wait to reset
      setState(() => _copied = true);
    }
    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF080808) : const Color(0xFFF8F9FA);
    final surfaceColor = widget.isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final borderColor = widget.isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bgColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 600;
          
          if (isDesktop) {
            return _buildDesktopLayout(surfaceColor, borderColor, textColor, constraints);
          }
          
          return _buildMobileLayout(surfaceColor, borderColor, textColor);
        },
      ),
    );
  }

  Widget _buildMobileLayout(Color surfaceColor, Color borderColor, Color textColor) {
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);

    return Stack(
      children: [
        // ── Background & Canvas ──────────────────────────────────────────
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(textColor, borderColor),
              
              Expanded(
                child: Stack(
                  children: [
                    // The Grid Canvas (Focused and Compact)
                    Positioned.fill(
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                        child: Align(
                          alignment: const Alignment(0, -0.6),
                          child: AspectRatio(
                            aspectRatio: _cols / _rows,
                            child: _buildGridCanvas(borderColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Area (Live Preview + Timeline)
              _buildBottomRibbon(surfaceColor, borderColor, textColor),
            ],
          ),
        ),

        // ── Floating Studio Toolbar ──────────────────────────────────────
        Positioned(
          left: 20,
          right: 20,
          bottom: 110,
          child: _buildStudioToolbar(surfaceColor, borderColor, textColor),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(Color surfaceColor, Color borderColor, Color textColor, BoxConstraints constraints) {
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);

    return Row(
      children: [
        // ── Main Workspace ───────────────────────────────────────────────
        Expanded(
          child: Column(
            children: [
              _buildTopBar(textColor, borderColor, showExport: false),
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                    padding: const EdgeInsets.all(64),
                    child: AspectRatio(
                      aspectRatio: _cols / _rows,
                      child: _buildGridCanvas(borderColor),
                    ),
                  ),
                ),
              ),
              _buildBottomRibbon(surfaceColor, borderColor, textColor),
            ],
          ),
        ),

        // ── Studio Sidebar ───────────────────────────────────────────────
        Container(
          width: 320,
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
                    color: textColor,
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
                      _buildSidebarSection('GRID SETTINGS', Column(
                        children: [
                          _buildSidebarSlider('Rows', _rows, (v) => _onGridSizeChange(v.round(), _cols), textColor),
                          const SizedBox(height: 16),
                          _buildSidebarSlider('Columns', _cols, (v) => _onGridSizeChange(_rows, v.round()), textColor),
                        ],
                      ), textColor),
                      
                      const SizedBox(height: 32),
                      
                      _buildSidebarSection('ACTIVE COLOR', SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final c in [
                              Theme.of(context).colorScheme.primary,
                              const Color(0xFF42A5F5),
                              const Color(0xFF66BB6A),
                              const Color(0xFFFFA726),
                              const Color(0xFFAB47BC),
                              const Color(0xFFEF5350),
                              const Color(0xFF8D6E63),
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () => setState(() => _activeColor = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _activeColor == c ? textColor : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ), textColor),
                      
                      const SizedBox(height: 32),
                      
                      _buildSidebarSection('ACTIONS', Column(
                        children: [
                          _buildSidebarActionButton(
                            icon: Icons.add_rounded,
                            label: 'Add New Frame',
                            onTap: _addFrame,
                            color: _activeColor,
                          ),
                          _buildSidebarActionButton(
                            icon: Icons.copy_all_rounded,
                            label: 'Duplicate Frame',
                            onTap: _duplicateFrame,
                            color: textColor,
                          ),
                          _buildSidebarActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete Frame',
                            onTap: _frames.length > 1 ? _deleteFrame : null,
                            color: Colors.redAccent,
                          ),
                          _buildSidebarActionButton(
                            icon: Icons.refresh_rounded,
                            label: 'Reset Entire Sequence',
                            onTap: _resetSequence,
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ), textColor),
                    ],
                  ),
                ),
              ),
              
              // Export at the bottom of sidebar
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

  Widget _buildSidebarSection(String title, Widget content, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: textColor.withValues(alpha: 0.4),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildSidebarSlider(String label, int value, ValueChanged<double> onChanged, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: textColor)),
            Text('$value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: _activeColor,
            inactiveTrackColor: textColor.withValues(alpha: 0.1),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 3,
            max: 5,
            divisions: 2,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    final isDisabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isDisabled ? color.withValues(alpha: 0.2) : color),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDisabled ? color.withValues(alpha: 0.2) : color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textColor, Color borderColor, {bool showExport = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sequence Builder.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'FRAME ${_currentIndex + 1} OF ${_frames.length}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textColor.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          
          // Compact Export Button
          if (showExport)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _copyCode,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _copied ? Colors.green : _activeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _copied ? Colors.green : _activeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _copied ? Icons.check_rounded : Icons.code_rounded,
                        size: 16,
                        color: _copied ? Colors.white : _activeColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _copied ? 'COPIED' : 'EXPORT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: _copied ? Colors.white : _activeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomRibbon(Color surfaceColor, Color borderColor, Color textColor) {
    return Container(
      height: 100, // Slightly taller for better thumbnail visibility
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Live Preview Slot (Larger)
          _buildLivePreviewSlot(borderColor),
          
          // Timeline (Scrollable)
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _frames.length,
              onReorder: (oldIndex, newIndex) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _frames.removeAt(oldIndex);
                  _frames.insert(newIndex, item);
                  if (_currentIndex == oldIndex) {
                    _currentIndex = newIndex;
                  } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
                    _currentIndex--;
                  } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
                    _currentIndex++;
                  }
                });
              },
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  key: ValueKey(_frames[index]),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _currentIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72, // Larger thumbnails
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _activeColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? _activeColor : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(44, 44), // Larger mini-matrix
                          painter: _MiniFramePainter(
                            frame: _frames[index],
                            rows: _rows,
                            cols: _cols,
                            activeColor: _activeColor,
                            inactiveColor: widget.isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 6,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? _activeColor : textColor.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewSlot(Color borderColor) {
    return Container(
      width: 100, // Wider for better visibility
      height: double.infinity,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _activeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _activeColor.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 0.55, // Significantly larger preview
            child: DotMatrixLoader(
              preset: SequenceAnimation(frames: _frames),
              style: DotMatrixStyle(
                rows: _rows,
                columns: _cols,
                activeColor: _activeColor,
                inactiveColor: widget.isDark ? const Color(0xFF242424) : const Color(0xFFE5E5E5),
                dotRadius: 6,
                dotGap: 4,
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 8,
            child: Icon(Icons.play_circle_filled_rounded, size: 14, color: _activeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCanvas(Color borderColor) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _cols,
        crossAxisSpacing: 10, // Tighter spacing for a technical look
        mainAxisSpacing: 10,
      ),
      itemCount: _rows * _cols,
      itemBuilder: (context, index) {
        final r = index ~/ _cols;
        final c = index % _cols;
        final isActive = _frames[_currentIndex][r][c];
        
        return GestureDetector(
          onTap: () => _toggleDot(r, c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isActive 
                  ? _activeColor 
                  : (widget.isDark ? const Color(0xFF141414) : const Color(0xFFE5E5E5)),
              shape: BoxShape.circle,
              boxShadow: isActive ? [
                BoxShadow(
                  color: _activeColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ] : null,
              border: Border.all(
                color: isActive 
                    ? _activeColor.withValues(alpha: 0.6)
                    : (widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                width: 1.5,
              ),
            ),
            child: isActive ? Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ) : null,
          ),
        );
      },
    );
  }

  Widget _buildStudioToolbar(Color surfaceColor, Color borderColor, Color textColor) {
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.92), // Matched base color with glass effect
        borderRadius: BorderRadius.circular(20), // Matched Showcase radius
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Size Sliders
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _buildCompactSlider('R', _rows, (v) => _onGridSizeChange(v.round(), _cols), textColor),
                const SizedBox(width: 16),
                _buildCompactSlider('C', _cols, (v) => _onGridSizeChange(_rows, v.round()), textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        for (final c in [
                          Theme.of(context).colorScheme.primary,
                          const Color(0xFF42A5F5),
                          const Color(0xFF66BB6A),
                          const Color(0xFFFFA726),
                          const Color(0xFFAB47BC),
                          const Color(0xFFEF5350),
                          const Color(0xFF8D6E63),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _activeColor = c);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _activeColor == c ? textColor : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, indent: 12, endIndent: 12),
          ),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StudioActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                onTap: _frames.length > 1 ? _deleteFrame : null,
                color: Colors.redAccent,
              ),
              _StudioActionButton(
                icon: Icons.copy_all_rounded,
                label: 'Duplicate',
                onTap: _duplicateFrame,
                color: textColor,
              ),
              _StudioActionButton(
                icon: Icons.add_rounded,
                label: 'Add Frame',
                onTap: _addFrame,
                color: _activeColor,
              ),
              _StudioActionButton(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                onTap: _resetSequence,
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSlider(String label, int value, ValueChanged<double> onChanged, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: textColor.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              activeTrackColor: _activeColor,
              inactiveTrackColor: textColor.withValues(alpha: 0.1),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 3,
              max: 5,
              divisions: 2,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

}

class _StudioActionButton extends StatefulWidget {
  const _StudioActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  State<_StudioActionButton> createState() => _StudioActionButtonState();
}

class _StudioActionButtonState extends State<_StudioActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed && !isDisabled ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 160), // Matched Showcase timing
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon, 
                size: 20,
                color: isDisabled ? widget.color.withValues(alpha: 0.2) : widget.color,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isDisabled ? widget.color.withValues(alpha: 0.2) : widget.color,
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

class _MiniFramePainter extends CustomPainter {
  _MiniFramePainter({
    required this.frame,
    required this.rows,
    required this.cols,
    required this.activeColor,
    required this.inactiveColor,
  });

  final List<List<bool>> frame;
  final int rows;
  final int cols;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final radius = math.min(cellW, cellH) / 2 * 0.7;
    
    final activePaint = Paint()..color = activeColor;
    final inactivePaint = Paint()..color = inactiveColor;
    
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * cellW + cellW / 2;
        final cy = r * cellH + cellH / 2;
        canvas.drawCircle(Offset(cx, cy), radius, frame[r][c] ? activePaint : inactivePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniFramePainter oldDelegate) => true;
}


