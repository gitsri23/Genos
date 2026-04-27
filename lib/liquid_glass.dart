import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────
//  LIQUID GLASS BUTTON  — iOS 26 style
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
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.91).animate(
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
      onTapDown: (_) { HapticFeedback.lightImpact(); _press.forward(); },
      onTapUp: (_) { _press.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: s,
          height: s,
          child: CustomPaint(
            painter: _LiquidGlassPainter(size: s),
            child: Center(
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: s * 0.38,
                shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassPainter extends CustomPainter {
  final double size;
  _LiquidGlassPainter({required this.size});

  @override
  void paint(Canvas canvas, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final r = s.width / 2;

    // 1. Dark base sphere
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.2, 0.2),
          radius: 0.85,
          colors: const [Color(0xFF4A4A4A), Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // 2. Outer rim sweep
    canvas.drawCircle(
      center,
      r - 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = SweepGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.35),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.2, 0.5, 0.75, 1.0],
          startAngle: -1.2,
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // 3. Top-left specular highlight
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.55),
          radius: 0.55,
          colors: [
            Colors.white.withOpacity(0.55),
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // 4. Sharp hotspot glint
    final hotspot = Offset(center.dx - r * 0.28, center.dy - r * 0.32);
    canvas.drawCircle(
      hotspot,
      r * 0.28,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(0.70), Colors.white.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: hotspot, radius: r * 0.3)),
    );

    // 5. Bottom refraction glow
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.1, 0.75),
          radius: 0.5,
          colors: [Colors.white.withOpacity(0.20), Colors.white.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // 6. Inner shadow ring (depth)
    canvas.drawCircle(
      center,
      r - r * 0.04,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
          stops: const [0.72, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_LiquidGlassPainter old) => old.size != size;
}

// ─────────────────────────────────────────
//  LIQUID GLASS PANEL  — for control bars
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
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));

    // Base gradient
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF3A3A3A), Color(0xFF111111)],
        ).createShader(Offset.zero & size),
    );

    // Top shine strip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.45),
          Radius.circular(radius)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.0)],
        ).createShader(Offset.zero & size),
    );

    // Rim
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(_PanelPainter old) => old.radius != radius;
}
