import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_stats.dart';
import 'dart:math' as math;

class AnimatedWelcomeWidget extends StatefulWidget {
  final UserStats userStats;

  const AnimatedWelcomeWidget({super.key, required this.userStats});

  @override
  State<AnimatedWelcomeWidget> createState() => _AnimatedWelcomeWidgetState();
}

class _AnimatedWelcomeWidgetState extends State<AnimatedWelcomeWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _levelController;
  late AnimationController _sparkleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _levelAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _levelController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _levelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.elasticOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _levelController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _sparkleController.repeat();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _levelController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Left side - App name and greeting
            Expanded(
              flex: 2,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userStats.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getGreeting()}, ${widget.userStats.userName}!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Ready to level up your studies?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: _sparkleAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _sparkleAnimation.value * 2 * math.pi,
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 16,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right side - Level and XP
            ScaleTransition(
              scale: _levelAnimation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              'L${widget.userStats.currentLevel}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _sparkleAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 5 +
                                  math.sin(_sparkleAnimation.value *
                                          2 *
                                          math.pi) *
                                      3,
                              right: 5 +
                                  math.cos(_sparkleAnimation.value *
                                          2 *
                                          math.pi) *
                                      3,
                              child: Icon(
                                Icons.star,
                                color: Colors.white.withValues(alpha: 0.6),
                                size: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level ${widget.userStats.currentLevel}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.userStats.levelProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.userStats.xpInCurrentLevel}/${widget.userStats.xpForNextLevel} XP',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
