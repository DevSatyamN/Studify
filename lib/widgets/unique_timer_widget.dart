import 'dart:math' as math;
import 'package:flutter/material.dart';

class UniqueTimerWidget extends StatefulWidget {
  final double progress;
  final String timeText;
  final bool isBreak;

  const UniqueTimerWidget({
    super.key,
    required this.progress,
    required this.timeText,
    this.isBreak = false,
  });

  @override
  State<UniqueTimerWidget> createState() => _UniqueTimerWidgetState();
}

class _UniqueTimerWidgetState extends State<UniqueTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: OuterRingPainter(
                    progress: widget.progress,
                    isBreak: widget.isBreak,
                  ),
                ),
              );
            },
          ),

          // Middle pulsing ring
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: CustomPaint(
                  size: const Size(250, 250),
                  painter: MiddleRingPainter(
                    progress: widget.progress,
                    isBreak: widget.isBreak,
                  ),
                ),
              );
            },
          ),

          // Inner progress ring
          CustomPaint(
            size: const Size(200, 200),
            painter: InnerProgressPainter(
              progress: widget.progress,
              isBreak: widget.isBreak,
            ),
          ),

          // Center time display
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: widget.isBreak
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [const Color(0xFF1E88E5), const Color(0xFF1976D2)],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (widget.isBreak ? Colors.green : const Color(0xFF1E88E5))
                          .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.timeText,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OuterRingPainter extends CustomPainter {
  final double progress;
  final bool isBreak;

  OuterRingPainter({required this.progress, required this.isBreak});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Background ring
    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(center, radius, paint);

    // Progress ring with gradient effect
    final rect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = SweepGradient(
      colors: isBreak
          ? [
              Colors.green.shade300,
              Colors.green.shade500,
              Colors.green.shade300
            ]
          : [
              const Color(0xFF42A5F5),
              const Color(0xFF1E88E5),
              const Color(0xFF42A5F5)
            ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MiddleRingPainter extends CustomPainter {
  final double progress;
  final bool isBreak;

  MiddleRingPainter({required this.progress, required this.isBreak});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Dotted ring
    const dotCount = 24;
    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * math.pi * i) / dotCount;
      final opacity = i < (dotCount * progress) ? 0.8 : 0.2;

      paint.color = (isBreak ? Colors.green : const Color(0xFF1E88E5))
          .withOpacity(opacity);

      final dotCenter = Offset(
        center.dx + radius * math.cos(angle - math.pi / 2),
        center.dy + radius * math.sin(angle - math.pi / 2),
      );

      canvas.drawCircle(dotCenter, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class InnerProgressPainter extends CustomPainter {
  final double progress;
  final bool isBreak;

  InnerProgressPainter({required this.progress, required this.isBreak});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Background
    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(center, radius, paint);

    // Progress with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = LinearGradient(
      colors: isBreak
          ? [Colors.green.shade400, Colors.green.shade600]
          : [const Color(0xFF1E88E5), const Color(0xFF1976D2)],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
