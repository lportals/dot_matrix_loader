import 'package:flutter/material.dart';
import 'pages/showcase_page.dart';
import 'pages/builder_page.dart';
import 'pages/sequence_builder_page.dart';

/// Root application widget with a theme toggle (dark / light).
class DotMatrixApp extends StatefulWidget {
  const DotMatrixApp({super.key});

  @override
  State<DotMatrixApp> createState() => _DotMatrixAppState();
}

class _DotMatrixAppState extends State<DotMatrixApp> {
  bool _isDark = true;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Matrix Loader',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      // ── Dark theme ─────────────────────────────────────────────────────────
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF080808),
          primary: Colors.white,
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        fontFamily: '',
      ),
      // ── Light theme ────────────────────────────────────────────────────────
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        colorScheme: const ColorScheme.light(
          surface: Color(0xFFF2F2F2),
          primary: Colors.black,
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        fontFamily: '',
      ),
      home: _RootShell(isDark: _isDark, onToggleTheme: _toggleTheme),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell({
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _currentIndex = 0;
  String? _selectedBuilderPresetName;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Floating theme toggle in the top-right corner, above content.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ShowcasePage(
            isDark: widget.isDark,
            onToggleTheme: widget.onToggleTheme,
            onSelectPreset: (name) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuilderPage(
                    isDark: widget.isDark,
                    onToggleTheme: widget.onToggleTheme,
                    initialPresetName: name,
                  ),
                ),
              );
            },
          ),
          SequenceBuilderPage(
            isDark: widget.isDark,
            onToggleTheme: widget.onToggleTheme,
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

/// Two-tab navbar. Active icon/label color is the inverse of the brightness
/// (white in dark mode, black in light mode) — i.e. [ColorScheme.onSurface].
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg =
        isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFFFFFF);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _Tab(
              label: 'Showcase',
              icon: Icons.grid_on_rounded,
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _Tab(
              label: 'Sequence',
              icon: Icons.view_carousel_rounded,
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single navbar tab. Active color = [ColorScheme.onSurface] (antagonistic
/// to the current brightness: white on dark, black on light).
class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Active = full onSurface (white in dark, black in light).
    // Inactive = onSurface at low alpha.
    final activeColor = cs.onSurface;
    final inactiveColor = cs.onSurface.withValues(alpha: 0.35);
    final color = active ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.0 : 0.88,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: color,
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
