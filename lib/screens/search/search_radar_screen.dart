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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
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
                      color: const Color(0xFFD4A574),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
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
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
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

          // ── Scattered map marker pins ──
          Positioned(
            top: 60,
            right: 40,
            child: Icon(LucideIcons.mapPin,
                size: 24,
                color: AppColors.primaryDark.withValues(alpha: 0.6)),
          ),
          Positioned(
            top: 120,
            right: 80,
            child: Icon(LucideIcons.mapPin,
                size: 20,
                color: AppColors.primaryDark.withValues(alpha: 0.5)),
          ),
          Positioned(
            bottom: 180,
            left: 30,
            child: Icon(LucideIcons.mapPin,
                size: 22,
                color: AppColors.primaryDark.withValues(alpha: 0.5)),
          ),
        ],
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
