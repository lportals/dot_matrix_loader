import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../studio_provider.dart';
import 'package:dot_matrix_loader/dot_matrix_loader.dart';

/// A premium, physics-based export button designed for the Studio Sidebar.
class SidebarExportButton extends StatefulWidget {
  const SidebarExportButton({
    super.key,
    required this.copied,
    required this.activeColor,
    required this.onTap,
    this.label = 'EXPORT ANIMATION',
  });

  final bool copied;
  final Color activeColor;
  final VoidCallback onTap;
  final String label;

  @override
  State<SidebarExportButton> createState() => _SidebarExportButtonState();
}

class _SidebarExportButtonState extends State<SidebarExportButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.copied ? Colors.green : widget.activeColor;
    final isLight = bgColor.computeLuminance() > 0.5;
    final contentColor = isLight ? Colors.black : Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: StudioProvider.of(context).borderRadius,
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.copied ? Icons.check_rounded : Icons.code_rounded,
                size: 20,
                color: contentColor,
              ),
              const SizedBox(width: 12),
              Text(
                widget.copied ? 'COPIED TO CLIPBOARD' : widget.label,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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

/// A technical, subtle grid background for the Studio preview area.
class StudioGridBackground extends StatelessWidget {
  const StudioGridBackground({
    super.key,
    this.dotColor,
    this.gridColor,
    this.opacity = 0.05,
    this.spacing = 40.0,
    this.offset = Offset.zero,
  });

  final Color? dotColor;
  final Color? gridColor;
  final double opacity;
  final double spacing;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = gridColor ?? (isDark ? Colors.white : Colors.black);

    return CustomPaint(
      painter: _GridPainter(
        color: color.withValues(alpha: opacity),
        spacing: spacing,
        offset: offset,
      ),
      child: Container(),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.color,
    required this.spacing,
    required this.offset,
  });
  final Color color;
  final double spacing;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    final startX = offset.dx % spacing;
    final startY = offset.dy % spacing;

    for (double x = startX; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = startY; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.offset != offset;
}

/// A wrapper that adds a subtle scale-down effect on press.
class StudioInteractiveWrapper extends StatefulWidget {
  const StudioInteractiveWrapper({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.97,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<StudioInteractiveWrapper> createState() => _StudioInteractiveWrapperState();
}

class _StudioInteractiveWrapperState extends State<StudioInteractiveWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
class ShapeToggle extends StatelessWidget {
  const ShapeToggle({
    super.key,
    required this.activeColor,
    required this.onSurface,
  });

  final Color activeColor;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    final studio = StudioProvider.of(context);
    final isCircle = studio.shape == DotShape.circle;
    
    return StudioInteractiveWrapper(
      onTap: () {
        HapticFeedback.selectionClick();
        studio.onShapeChanged(isCircle ? DotShape.roundedSquare : DotShape.circle);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.07),
          borderRadius: studio.borderRadius,
        ),
        child: Icon(
          isCircle ? Icons.circle_outlined : Icons.crop_square_rounded,
          size: 18,
          color: onSurface.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

/// A premium circular interactive icon button used for TopBar/AppBar actions.
class StudioIconButton extends StatefulWidget {
  const StudioIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 36.0,
    this.iconSize = 18.0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;
  final double iconSize;

  @override
  State<StudioIconButton> createState() => _StudioIconButtonState();
}

class _StudioIconButtonState extends State<StudioIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final provider = context.dependOnInheritedWidgetOfExactType<StudioProvider>();
    final isCircle = provider?.shape != DotShape.roundedSquare;

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.07),
                borderRadius: isCircle 
                    ? BorderRadius.circular(widget.size / 2) 
                    : BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

