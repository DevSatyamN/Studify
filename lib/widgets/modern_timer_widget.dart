import 'dart:math' as math;
import 'package:flutter/material.dart';

class ModernTimerWidget extends StatefulWidget {
  final double progress;
  final String timeText;
  final bool isBreak;
  final bool isRunning;

  const ModernTimerWidget({
    super.key,
    required this.progress,
    required this.timeText,
    this.isBreak = false,
    this.isRunning = false,
  });

  @override
  State<ModernTimerWidget> createState() => _ModernTimerWidgetState();
}

class _ModernTimerWidgetState extends State<ModernTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _breathController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _breathAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ));

    if (widget.isRunning) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _waveController.repeat();
    _particleController.repeat();
    _breathController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _waveController.stop();
    _particleController.stop();
    _breathController.stop();
  }

  @override
  void didUpdateWidget(ModernTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated background waves
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(320, 320),
                painter: WaveBackgroundPainter(
                  animation: _waveController.value,
                  isBreak: widget.isBreak,
                ),
              );
            },
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(320, 320),
                painter: ParticlePainter(
                  animation: _particleController.value,
                  isBreak: widget.isBreak,
                  isRunning: widget.isRunning,
                ),
              );
            },
          ),

          // Main progress ring
          CustomPaint(
            size: const Size(280, 280),
            painter: ModernProgressPainter(
              progress: widget.progress,
              isBreak: widget.isBreak,
            ),
          ),

          // Breathing center circle
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isRunning ? _breathAnimation.value : 1.0,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: widget.isBreak
                          ? [
                              const Color(0xFF10B981).withOpacity(0.8),
                              const Color(0xFF059669),
                            ]
                          : [
                              const Color(0xFF3B82F6).withOpacity(0.8),
                              const Color(0xFF1E40AF),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isBreak
                                ? const Color(0xFF10B981)
                                : const Color(0xFF3B82F6))
                            .withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.timeText,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.isBreak ? 'Break Time' : 'Focus Time',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WaveBackgroundPainter extends CustomPainter {
  final double animation;
  final bool isBreak;

  WaveBackgroundPainter({required this.animation, required this.isBreak});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke;

    // Create multiple wave rings
    for (int i = 0; i < 4; i++) {
      final radius = 60.0 + (i * 30) + (animation * 20);
      final opacity = (1.0 - (i * 0.2)) * 0.3;

      paint
        ..color = (isBreak ? const Color(0xFF10B981) : const Color(0xFF3B82F6))
            .withOpacity(opacity)
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final double animation;
  final bool isBreak;
  final bool isRunning;

  ParticlePainter({
    required this.animation,
    required this.isBreak,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isRunning) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Create floating particles
    for (int i = 0; i < 12; i++) {
      final angle = (2 * math.pi * i / 12) + (animation * 2 * math.pi);
      final radius = 120 + (math.sin(animation * 2 * math.pi + i) * 20);
      final opacity = (math.sin(animation * 2 * math.pi + i * 0.5) + 1) / 2;

      final particleCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      paint.color =
          (isBreak ? const Color(0xFF10B981) : const Color(0xFF3B82F6))
              .withOpacity(opacity * 0.6);

      canvas.drawCircle(particleCenter, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ModernProgressPainter extends CustomPainter {
  final double progress;
  final bool isBreak;

  ModernProgressPainter({required this.progress, required this.isBreak});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background track
    paint
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, paint);

    // Progress arc with gradient effect
    final rect = Rect.fromCircle(center: center, radius: radius);
    paint
      ..strokeWidth = 12
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        colors: isBreak
            ? [
                const Color(0xFF10B981),
                const Color(0xFF34D399),
                const Color(0xFF6EE7B7),
              ]
            : [
                const Color(0xFF3B82F6),
                const Color(0xFF60A5FA),
                const Color(0xFF93C5FD),
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

    // Progress indicator dot
    if (progress > 0) {
      final dotAngle = -math.pi / 2 + (2 * math.pi * progress);
      final dotCenter = Offset(
        center.dx + radius * math.cos(dotAngle),
        center.dy + radius * math.sin(dotAngle),
      );

      paint
        ..shader = null
        ..color = Colors.white
        ..strokeWidth = 0
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotCenter, 8, paint);

      paint
        ..color = isBreak ? const Color(0xFF10B981) : const Color(0xFF3B82F6)
        ..strokeWidth = 0;

      canvas.drawCircle(dotCenter, 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
