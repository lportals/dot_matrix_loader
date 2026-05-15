import 'package:flutter/material.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';
import 'pages/showcase_page.dart';
import 'pages/builder_page.dart';
import 'pages/sequence_builder_page.dart';
import 'studio_provider.dart';

/// Root application widget with a theme toggle (dark / light).
class DotMatrixApp extends StatefulWidget {
  const DotMatrixApp({super.key});

  @override
  State<DotMatrixApp> createState() => _DotMatrixAppState();
}

class _DotMatrixAppState extends State<DotMatrixApp> {
  bool _isDark = true;
  DotShape _globalShape = DotShape.circle;

  void _toggleTheme() => setState(() => _isDark = !_isDark);
  void _setGlobalShape(DotShape shape) => setState(() => _globalShape = shape);

  @override
  Widget build(BuildContext context) {
    return StudioProvider(
      shape: _globalShape,
      onShapeChanged: _setGlobalShape,
      isDark: _isDark,
      onToggleTheme: _toggleTheme,
      child: Builder(
        builder: (context) {
          final studio = StudioProvider.of(context);
          return MaterialApp(
            title: 'Dot Matrix Loader',
            debugShowCheckedModeBanner: false,
            themeMode: studio.isDark ? ThemeMode.dark : ThemeMode.light,
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
            home: const _RootShell(),
          );
        }
      ),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final studio = StudioProvider.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Row(
            children: [
              if (isDesktop)
                _SidebarRail(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    ShowcasePage(
                      isDark: studio.isDark,
                      onToggleTheme: studio.onToggleTheme,
                      onSelectPreset: (name, rows, cols, speed, color) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuilderPage(
                              isDark: studio.isDark,
                              onToggleTheme: studio.onToggleTheme,
                              initialPresetName: name,
                              initialRows: rows,
                              initialCols: cols,
                              initialSpeed: speed,
                              initialColor: color,
                            ),
                          ),
                        );
                      },
                    ),
                    SequenceBuilderPage(
                      isDark: studio.isDark,
                      onToggleTheme: studio.onToggleTheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop 
              ? null 
              : _BottomBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
        );
      },
    );
  }
}

class _SidebarRail extends StatelessWidget {
  const _SidebarRail({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final railBg = isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      width: 72,
      height: double.infinity,
      decoration: BoxDecoration(
        color: railBg,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.blur_on_rounded, color: Theme.of(context).colorScheme.onSurface, size: 32),
          const SizedBox(height: 48),
          _RailTab(
            label: 'Showcase',
            icon: Icons.grid_view_rounded,
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          const SizedBox(height: 16),
          _RailTab(
            label: 'Sequence',
            icon: Icons.auto_awesome_motion_rounded,
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailTab extends StatelessWidget {
  const _RailTab({
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
    final color = active ? cs.onSurface : cs.onSurface.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (active)
              Positioned(
                left: 0,
                top: 16,
                bottom: 16,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: cs.onSurface,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: color)),
              ],
            ),
          ],
        ),
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
