import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DataAnalyticsScreen extends StatelessWidget {
  const DataAnalyticsScreen({super.key});

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
                    'data_analytics'.tr,
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

            const SizedBox(height: 24),

            // ── Content ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Data Usage
                  _DataItem(
                    title: 'data_usage'.tr,
                    subtitle:
                        'data_usage_desc'.tr,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.dividerDark
                        : Colors.grey.shade200,
                  ),

                  // Ad Preferences
                  _DataItem(
                    title: 'ad_preferences'.tr,
                    subtitle:
                        'ad_preferences_desc'.tr,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.dividerDark
                        : Colors.grey.shade200,
                  ),

                  // Download My Data
                  _DataItem(
                    title: 'download_my_data'.tr,
                    subtitle:
                        'download_my_data_desc'.tr,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data item ────────────────────────────────────────────────────────────
class _DataItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _DataItem({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight,
                size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
