import 'dart:ui';
import 'package:flutter/material.dart';

class BlurryDialog extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;

  const BlurryDialog({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // Backdrop blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // Content
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class BlurryBottomSheet extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;

  const BlurryBottomSheet({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}
