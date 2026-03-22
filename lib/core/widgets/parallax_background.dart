import 'package:flutter/material.dart';

/// A parallax background that shifts based on scroll position or drag offset.
/// Ideal for swipe card backgrounds.
class ParallaxBackground extends StatelessWidget {
  final Widget child;
  final double offsetX;
  final double offsetY;
  final double intensity;

  const ParallaxBackground({
    super.key,
    required this.child,
    this.offsetX = 0,
    this.offsetY = 0,
    this.intensity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(offsetX * intensity, offsetY * intensity),
      child: Transform.scale(
        scale: 1.1, // Slightly larger to prevent edge gaps during parallax
        child: child,
      ),
    );
  }
}

/// Animated parallax that responds to device tilt or drag position.
class AnimatedParallaxCard extends StatefulWidget {
  final Widget child;
  final Widget? background;
  final double maxParallax;

  const AnimatedParallaxCard({
    super.key,
    required this.child,
    this.background,
    this.maxParallax = 20,
  });

  @override
  State<AnimatedParallaxCard> createState() => _AnimatedParallaxCardState();
}

class _AnimatedParallaxCardState extends State<AnimatedParallaxCard> {
  double _dx = 0;
  double _dy = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dx = (_dx + details.delta.dx).clamp(
            -widget.maxParallax,
            widget.maxParallax,
          );
          _dy = (_dy + details.delta.dy).clamp(
            -widget.maxParallax,
            widget.maxParallax,
          );
        });
      },
      onPanEnd: (_) {
        setState(() {
          _dx = 0;
          _dy = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.background != null)
              Transform.translate(
                offset: Offset(-_dx * 0.5, -_dy * 0.5),
                child: widget.background,
              ),
            Transform.translate(
              offset: Offset(_dx * 0.2, _dy * 0.2),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
