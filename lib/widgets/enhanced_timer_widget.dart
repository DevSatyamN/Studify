import 'package:flutter/material.dart';
import 'dart:math' as math;

class EnhancedTimerWidget extends StatefulWidget {
  final Duration duration;
  final Duration remaining;
  final bool isRunning;
  final VoidCallback? onPlayPause;
  final VoidCallback? onReset;
  final VoidCallback? onComplete;

  const EnhancedTimerWidget({
    super.key,
    required this.duration,
    required this.remaining,
    required this.isRunning,
    this.onPlayPause,
    this.onReset,
    this.onComplete,
  });

  @override
  State<EnhancedTimerWidget> createState() => _EnhancedTimerWidgetState();
}

class _EnhancedTimerWidgetState extends State<EnhancedTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    if (widget.isRunning) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rotationController.stop();
  }

  @override
  void didUpdateWidget(EnhancedTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }

    if (widget.remaining.inSeconds == 0 && oldWidget.remaining.inSeconds > 0) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.duration.inSeconds > 0
        ? (widget.duration.inSeconds - widget.remaining.inSeconds) /
            widget.duration.inSeconds
        : 0.0;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_pulseAnimation, _rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 330,
                    height: 330,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Progress ring
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: SizedBox(
                    width: 310,
                    height: 310,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),

                // Inner pulsing circle
                Transform.scale(
                  scale: _pulseAnimation.value * 0.9,
                  child: Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(widget.remaining),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isRunning ? 'Focus Time' : 'Paused',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Control buttons
                Positioned(
                  bottom: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        onPressed: widget.onReset,
                        backgroundColor: theme.colorScheme.secondary,
                        child: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: widget.onPlayPause,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(
                          widget.isRunning ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
