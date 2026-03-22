import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/splash_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashController controller;
  late final AnimationController _heartsController;
  late final List<_FloatingHeart> _hearts;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SplashController());
    _heartsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _hearts = List.generate(12, (_) => _FloatingHeart.random());
  }

  @override
  void dispose() {
    _heartsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8396B),
              Color(0xFFC2185B),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Floating hearts background ──
            AnimatedBuilder(
              animation: _heartsController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _HeartsPainter(
                    hearts: _hearts,
                    progress: _heartsController.value,
                  ),
                );
              },
            ),

            // ── Main content ──
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 4),

                    // Logo icon — speech bubble with heart
                    Obx(() => AnimatedOpacity(
                          opacity: controller.showLogo.value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 800),
                          child: AnimatedScale(
                            scale: controller.showLogo.value ? 1.0 : 0.3,
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.elasticOut,
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: CustomPaint(
                                painter: _LogoPainter(),
                              ),
                            ),
                          ),
                        )),

                    const SizedBox(height: 28),

                    // App name
                    Obx(() => AnimatedOpacity(
                          opacity: controller.showLogo.value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 600),
                          child: AnimatedSlide(
                            offset: controller.showLogo.value
                                ? Offset.zero
                                : const Offset(0, 0.4),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            child: Text(
                              AppConstants.appName,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        )),

                    const Spacer(flex: 4),

                    // Circular progress indicator
                    Obx(() => AnimatedOpacity(
                          opacity:
                              controller.animationProgress.value > 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              value: controller.animationProgress.value < 1.0
                                  ? null
                                  : 1.0,
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white.withValues(alpha: 0.9),
                              ),
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        )),

                    const SizedBox(height: 48),
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

// ─── Logo painter: speech-bubble with heart ───────────────────────────
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 4);
    final radius = size.width * 0.38;

    // White circle background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius, bgPaint);

    // Small tail / pointer at bottom
    final tailPath = Path()
      ..moveTo(center.dx - 8, center.dy + radius - 4)
      ..lineTo(center.dx - 14, center.dy + radius + 14)
      ..lineTo(center.dx + 6, center.dy + radius - 2)
      ..close();
    canvas.drawPath(tailPath, bgPaint);

    // Heart icon inside
    _drawHeart(canvas, Offset(center.dx, center.dy + 2), radius * 0.52,
        AppColors.primary);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size;
    final h = size;
    final x = center.dx - w / 2;
    final y = center.dy - h / 2;

    path.moveTo(x + w / 2, y + h);
    path.cubicTo(x + w / 2, y + h, x, y + h * 0.65, x, y + h * 0.35);
    path.cubicTo(x, y + h * 0.1, x + w * 0.25, y, x + w / 2, y + h * 0.2);
    path.cubicTo(x + w * 0.75, y, x + w, y + h * 0.1, x + w, y + h * 0.35);
    path.cubicTo(x + w, y + h * 0.65, x + w / 2, y + h, x + w / 2, y + h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Floating hearts data & painter ───────────────────────────────────
class _FloatingHeart {
  final double x; // 0..1 horizontal position
  final double startY; // 0..1 starting vertical
  final double size; // icon size
  final double speed; // multiplier
  final double opacity;

  _FloatingHeart({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory _FloatingHeart.random() {
    final rng = Random();
    return _FloatingHeart(
      x: rng.nextDouble(),
      startY: rng.nextDouble(),
      size: 10 + rng.nextDouble() * 18,
      speed: 0.3 + rng.nextDouble() * 0.7,
      opacity: 0.06 + rng.nextDouble() * 0.14,
    );
  }
}

class _HeartsPainter extends CustomPainter {
  final List<_FloatingHeart> hearts;
  final double progress;

  _HeartsPainter({required this.hearts, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final h in hearts) {
      final y = ((h.startY + progress * h.speed) % 1.2) * size.height;
      final x = h.x * size.width + sin(progress * 2 * pi + h.startY * 6) * 20;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: h.opacity)
        ..style = PaintingStyle.fill;

      _drawSmallHeart(canvas, Offset(x, y), h.size, paint);
    }
  }

  void _drawSmallHeart(Canvas canvas, Offset center, double s, Paint paint) {
    final path = Path();
    final x = center.dx - s / 2;
    final y = center.dy - s / 2;

    path.moveTo(x + s / 2, y + s);
    path.cubicTo(x + s / 2, y + s, x, y + s * 0.65, x, y + s * 0.35);
    path.cubicTo(x, y + s * 0.1, x + s * 0.25, y, x + s / 2, y + s * 0.2);
    path.cubicTo(x + s * 0.75, y, x + s, y + s * 0.1, x + s, y + s * 0.35);
    path.cubicTo(x + s, y + s * 0.65, x + s / 2, y + s, x + s / 2, y + s);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter old) => old.progress != progress;
}
