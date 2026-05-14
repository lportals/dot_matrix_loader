import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:dot_matrix_loader/dot_matrix_loader.dart';



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
  final int _rows = 5;
  final int _cols = 5;
  
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
    final bgColor = widget.isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7);
    final surfaceColor = widget.isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final subtextColor = widget.isDark ? Colors.white54 : Colors.black54;
    final borderColor = widget.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Sequence Builder.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Live Preview
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: DotMatrixLoader(
                  preset: SequenceAnimation(frames: _frames),
                  style: DotMatrixStyle(
                    rows: _rows,
                    columns: _cols,
                    activeColor: _activeColor,
                    inactiveColor: widget.isDark ? const Color(0xFF242424) : const Color(0xFFE5E5E5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid Canvas
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _cols / _rows,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _cols,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _rows * _cols,
                      itemBuilder: (context, index) {
                        final r = index ~/ _cols;
                        final c = index % _cols;
                        final isActive = _frames[_currentIndex][r][c];
                        return GestureDetector(
                          onTap: () => _toggleDot(r, c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? _activeColor 
                                  : (widget.isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE5E5E5)),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onTap: _frames.length > 1 ? _deleteFrame : null,
                      color: Colors.redAccent,
                    ),
                  ),
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.copy,
                      label: 'Duplicate',
                      onTap: _duplicateFrame,
                      color: textColor,
                    ),
                  ),
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.add,
                      label: 'Add Frame',
                      onTap: _addFrame,
                      color: _activeColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timeline and Color Picker
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        for (final c in [
                          Theme.of(context).colorScheme.primary,
                          const Color(0xFF42A5F5),
                          const Color(0xFF66BB6A),
                          const Color(0xFFFFA726),
                          const Color(0xFFAB47BC),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _activeColor = c);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _activeColor == c
                                        ? textColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: _activeColor == c
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
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Timeline
                  SizedBox(
                    height: 60,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _frames.length,
                      onReorder: (oldIndex, newIndex) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
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
                        // Unique key based on the object reference so ReorderableListView tracks it correctly
                        return GestureDetector(
                          key: ValueKey(_frames[index]),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _currentIndex = index);
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? (widget.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0))
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
                                  size: const Size(40, 40),
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? _activeColor : subtextColor,
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
            ),
            
            // Export Button at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
                        color: (_copied ? Colors.green : _activeColor).withValues(alpha: 0.25),
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
                          _copied ? Icons.check_circle_outline_rounded : Icons.code_rounded,
                          color: _copied
                              ? Colors.white
                              : (_activeColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _copied ? 'COPIED TO CLIPBOARD' : 'EXPORT ANIMATION CODE',
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

class _ControlButton extends StatelessWidget {
  const _ControlButton({
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: onTap == null ? color.withValues(alpha: 0.3) : color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onTap == null ? color.withValues(alpha: 0.3) : color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
    final radius = math.min(cellW, cellH) / 2 * 0.8;
    
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
  bool shouldRepaint(covariant _MiniFramePainter oldDelegate) {
    return oldDelegate.frame != frame || 
           oldDelegate.activeColor != activeColor || 
           oldDelegate.inactiveColor != inactiveColor;
  }
}
