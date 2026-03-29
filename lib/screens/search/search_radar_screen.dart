import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/search_controller.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchRadarScreen extends StatelessWidget {
  const SearchRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchRadarController());
    final currentUser = Get.find<AuthService>().currentUser.value;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Pink overlay background (simulating map) ──
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.islamicGradient,
            ),
          ),

          // ── Faint grid lines to simulate map ──
          CustomPaint(
            painter: _MapGridPainter(),
            size: Size.infinite,
          ),

          // ── Centered user avatar with golden ring ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: currentUser?.mainPhotoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: currentUser!.mainPhotoUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                Helpers.getInitials(
                                    currentUser?.firstName,
                                    currentUser?.lastName),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // "Finding people near you" text
                Obx(() => Text(
                      controller.isSearching.value
                          ? 'Finding people near you'
                          : 'Found ${controller.foundUsers.length} people!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    )),
              ],
            ),
          ),

          // ── Scattered animated map marker pins ──
          _AnimatedMapPin(top: 60, right: 40, size: 24, delay: 0.0),
          _AnimatedMapPin(top: 120, right: 80, size: 20, delay: 0.3),
          _AnimatedMapPin(bottom: 180, left: 30, size: 22, delay: 0.6),
          _AnimatedMapPin(top: 200, left: 60, size: 18, delay: 0.9),
          _AnimatedMapPin(bottom: 260, right: 50, size: 20, delay: 1.2),
        ],
      ),
    );
  }
}

// ─── Animated map pin with bounce + pulse ─────────────────────────────────
class _AnimatedMapPin extends StatefulWidget {
  final double? top, bottom, left, right;
  final double size;
  final double delay;

  const _AnimatedMapPin({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    this.delay = 0.0,
  });

  @override
  State<_AnimatedMapPin> createState() => _AnimatedMapPinState();
}

class _AnimatedMapPinState extends State<_AnimatedMapPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: widget.left,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          final bounce = -6.0 * t;
          final opacity = 0.35 + 0.35 * t;
          final scale = 0.9 + 0.15 * t;
          return Transform.translate(
            offset: Offset(0, bounce),
            child: Transform.scale(
              scale: scale,
              child: Icon(
                LucideIcons.mapPin,
                size: widget.size,
                color: AppColors.gold.withValues(alpha: opacity),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Map grid painter (faint street-like lines) ───────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
