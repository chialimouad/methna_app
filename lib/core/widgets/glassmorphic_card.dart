import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphism-style card with frosted glass blur, border glow, and
/// optional 3D tilt on drag. Perfect for swipe cards and premium UI sections.
class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color tintColor;
  final double tintOpacity;
  final double borderOpacity;
  final bool enable3DTilt;
  final EdgeInsetsGeometry padding;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 15,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.12,
    this.borderOpacity = 0.25,
    this.enable3DTilt = false,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard> {
  double _rotateX = 0;
  double _rotateY = 0;

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enable3DTilt) return;
    setState(() {
      _rotateY = (details.localPosition.dx - 150) / 300 * 0.15;
      _rotateX = -(details.localPosition.dy - 200) / 400 * 0.15;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enable3DTilt) return;
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.tintColor.withValues(alpha: widget.tintOpacity),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.tintColor.withValues(alpha: widget.borderOpacity),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.enable3DTilt) {
      card = GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotateX)
            ..rotateY(_rotateY),
          transformAlignment: Alignment.center,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// A neumorphic-style card with soft shadows for a raised/pressed effect.
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isPressed;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.isPressed = false,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? const Color(0xFF234746) : const Color(0xFFF5F2EB));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                // Inset shadow effect via inner shadow simulation
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.7),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
              ]
            : [
                // Raised shadow effect
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 12,
                  offset: const Offset(4, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
                  blurRadius: 12,
                  offset: const Offset(-4, -4),
                ),
              ],
      ),
      child: child,
    );
  }
}
