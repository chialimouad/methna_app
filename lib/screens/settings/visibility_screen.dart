import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';

class VisibilityScreen extends GetView<SettingsController> {
  const VisibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.chevronLeft,
                          size: 16, color: textColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'visibility'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'visibility_desc'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Everyone
                  Obx(() => _RadioRow(
                        label: 'everyone'.tr,
                        isSelected: controller.visibility.value == 'everyone',
                        textColor: textColor,
                        onTap: () => controller.updateVisibility('everyone'),
                      )),
                  const SizedBox(height: 20),

                  // Only Matches
                  Obx(() => _RadioRow(
                        label: 'only_matches'.tr,
                        isSelected: controller.visibility.value == 'matches',
                        textColor: textColor,
                        onTap: () => controller.updateVisibility('matches'),
                      )),
                  const SizedBox(height: 20),

                  // Nobody
                  Obx(() => _RadioRow(
                        label: 'nobody'.tr,
                        isSelected: controller.visibility.value == 'nobody',
                        textColor: textColor,
                        onTap: () => controller.updateVisibility('nobody'),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Radio row ────────────────────────────────────────────────────────────
class _RadioRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;

  static const _purple = AppColors.primary;

  const _RadioRow({
    required this.label,
    required this.isSelected,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _purple : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _purple,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
