import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/locale_controller.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppAppearanceScreen extends GetView<SettingsController> {
  const AppAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    String themeLabel() {
      switch (controller.themeMode.value) {
        case 'light':
          return 'light'.tr;
        case 'dark':
          return 'dark'.tr;
        default:
          return 'system_default'.tr;
      }
    }

    final localeCtrl = Get.find<LocaleController>();
    String langLabel() {
      return localeCtrl.isArabic ? 'language_arabic'.tr : 'language_english'.tr;
    }

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
                    'app_appearance'.tr,
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
              child: Obx(() => ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Theme
                      _ValueRow(
                        title: 'theme'.tr,
                        value: themeLabel(),
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: () => _showThemeSheet(context),
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.dividerDark
                            : Colors.grey.shade200,
                      ),

                      // App Language
                      _ValueRow(
                        title: 'app_language'.tr,
                        value: langLabel(),
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: () =>
                            Get.toNamed(AppRoutes.appLanguage),
                      ),

                      const SizedBox(height: 32),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final sheetBg = isDark ? AppColors.cardDark : Colors.white;

    final tempSelected = controller.themeMode.value.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'choose_theme'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),

            const SizedBox(height: 20),

            // Radio options
            Obx(() => Column(
                  children: [
                    _RadioOption(
                      label: 'system_default'.tr,
                      value: 'system',
                      groupValue: tempSelected.value,
                      textColor: textColor,
                      onTap: () => tempSelected.value = 'system',
                    ),
                    const SizedBox(height: 14),
                    _RadioOption(
                      label: 'light'.tr,
                      value: 'light',
                      groupValue: tempSelected.value,
                      textColor: textColor,
                      onTap: () => tempSelected.value = 'light',
                    ),
                    const SizedBox(height: 14),
                    _RadioOption(
                      label: 'dark'.tr,
                      value: 'dark',
                      groupValue: tempSelected.value,
                      textColor: textColor,
                      onTap: () => tempSelected.value = 'dark',
                    ),
                  ],
                )),

            const SizedBox(height: 24),

            // Cancel / OK buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        controller
                            .changeTheme(tempSelected.value);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'ok'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ─── Value row ────────────────────────────────────────────────────────────
class _ValueRow extends StatelessWidget {
  final String title;
  final String value;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _ValueRow({
    required this.title,
    required this.value,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontSize: 14, color: secondaryColor),
            ),
            const SizedBox(width: 4),
            Icon(LucideIcons.chevronRight,
                size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ─── Radio option ─────────────────────────────────────────────────────────
class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Color textColor;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
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
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
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
                        color: AppColors.primary,
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
