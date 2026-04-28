import 'package:flutter/material.dart';
import '../../core/colors.dart';

class BackgroundCircles extends StatelessWidget {
  final Animation<double> animation;

  const BackgroundCircles({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 80 + animation.value,
              left: 40,
              child: AnimatedCircle(size: 128, color: appPrimary.withValues(alpha: 0.2)),
            ),
            Positioned(
              top: 240 - animation.value,
              right: 32,
              child: AnimatedCircle(size: 96, color: appAccent.withValues(alpha: 0.2)),
            ),
            Positioned(
              bottom: 160 + animation.value * 0.5,
              left: 24,
              child: AnimatedCircle(size: 80, color: appSuccess.withValues(alpha: 0.2)),
            ),
          ],
        );
      },
    );
  }
}

class AnimatedCircle extends StatelessWidget {
  final double size;
  final Color color;

  const AnimatedCircle({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 1.5,
            spreadRadius: size * 0.5,
          ),
        ],
      ),
    );
  }
}
