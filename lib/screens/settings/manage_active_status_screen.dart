import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManageActiveStatusScreen extends StatelessWidget {
  const ManageActiveStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final showActiveStatus = true.obs;
    final showRecentlyActive = false.obs;

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
                    'manage_active_status'.tr,
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
                  // Show Active Status
                  _ToggleSection(
                    title: 'show_active_status'.tr,
                    subtitle:
                        'show_active_status_desc'.tr,
                    rxValue: showActiveStatus,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                  ),

                  Divider(
                    height: 32,
                    color: isDark
                        ? AppColors.dividerDark
                        : Colors.grey.shade200,
                  ),

                  // Show Recently Active Status
                  _ToggleSection(
                    title: 'show_recently_active'.tr,
                    subtitle:
                        'show_recently_active_desc'.tr,
                    rxValue: showRecentlyActive,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
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

// ─── Toggle section ───────────────────────────────────────────────────────
class _ToggleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final RxBool rxValue;
  final Color textColor;
  final Color secondaryColor;

  const _ToggleSection({
    required this.title,
    required this.subtitle,
    required this.rxValue,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Obx(() => Switch(
                  value: rxValue.value,
                  onChanged: (v) => rxValue.value = v,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor:
                      AppColors.primary.withValues(alpha: 0.4),
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: secondaryColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
