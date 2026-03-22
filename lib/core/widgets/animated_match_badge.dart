import 'package:flutter/material.dart';
import 'package:methna_app/app/theme/app_colors.dart';

/// An animated badge that pulses and glows when a new match is found.
/// Attach to profile avatars or notification icons.
class AnimatedMatchBadge extends StatefulWidget {
  final int count;
  final double size;
  final bool animate;

  const AnimatedMatchBadge({
    super.key,
    required this.count,
    this.size = 22,
    this.animate = true,
  });

  @override
  State<AnimatedMatchBadge> createState() => _AnimatedMatchBadgeState();
}

class _AnimatedMatchBadgeState extends State<AnimatedMatchBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnim = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.animate && widget.count > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMatchBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > 0 && widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.count == 0 || !widget.animate) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _scaleAnim.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                if (widget.animate)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: _glowAnim.value,
                    spreadRadius: _glowAnim.value * 0.3,
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.count > 99 ? '99+' : '${widget.count}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Builder wrapper that uses AnimatedBuilder pattern.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder._internal(
      animation: animation,
      builder: builder,
      child: child,
    );
  }

  // Use ListenableBuilder under the hood
  static Widget _internal({
    required Animation<double> animation,
    required Widget Function(BuildContext, Widget?) builder,
    Widget? child,
  }) {
    return ListenableBuilder(
      listenable: animation,
      builder: (context, child) => builder(context, child),
      child: child,
    );
  }
}
