import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────
//  LIQUID GLASS BUTTON  — translucent, video shows through
// ─────────────────────────────────────────

class LiquidGlassButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  const LiquidGlassButton({
    Key? key,
    required this.icon,
    this.size = 72,
    this.onTap,
  }) : super(key: key);

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.88).animate(
        CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _press.forward();
      },
      onTapUp: (_) {
        _press.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: s,
          height: s,
          child: CustomPaint(
            painter: _GlassBallPainter(size: s),
            child: Center(
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: s * 0.38,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBallPainter extends CustomPainter {
  final double size;
  _GlassBallPainter({required this.size});

  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    final r = s.width / 2;

    // 1. Translucent base — video shows through (like original UI)
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.15, 0.15),
          radius: 1.0,
          colors: [
            const Color(0x88555555), // lighter center
            const Color(0xBB222222), // darker edge
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // 2. Top-left specular — main glass shine
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 0.65,
          colors: [
            Colors.white.withOpacity(0.40),
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // 3. Small sharp hotspot glint
    final hot = Offset(c.dx - r * 0.26, c.dy - r * 0.30);
    canvas.drawCircle(
      hot,
      r * 0.22,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.55),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: hot, radius: r * 0.22)),
    );

    // 4. Bottom refraction glow
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.1, 0.80),
          radius: 0.45,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // 5. Outer rim light
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = SweepGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.30),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.18, 0.5, 0.75, 1.0],
          startAngle: -1.2,
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_GlassBallPainter old) => old.size != size;
}

// ─────────────────────────────────────────
//  LIQUID GLASS PANEL  — seek bar container
// ─────────────────────────────────────────

class LiquidGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const LiquidGlassPanel({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.radius = 22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PanelPainter(radius: radius),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _PanelPainter extends CustomPainter {
  final double radius;
  _PanelPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));

    // Base — semi-transparent dark, not fully opaque
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xCC1A1A1A),
    );

    // Top shine strip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
          Radius.circular(radius)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    // Rim
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withOpacity(0.18),
    );
  }

  @override
  bool shouldRepaint(_PanelPainter old) => old.radius != radius;
}
