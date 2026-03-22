import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/locale_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppLanguageScreen extends StatelessWidget {
  const AppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final localeCtrl = Get.find<LocaleController>();

    final languages = <_LanguageItem>[
      _LanguageItem(
        langCode: 'en',
        countryCode: 'US',
        label: 'language_english'.tr,
        nativeLabel: 'English',
        flag: '🇸',
      ),
      _LanguageItem(
        langCode: 'ar',
        countryCode: 'DZ',
        label: 'language_arabic'.tr,
        nativeLabel: 'العربية',
        flag: '🇩🇿',
      ),
    ];

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
                    'app_language'.tr,
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

            const SizedBox(height: 20),

            // ── Language list ──
            Expanded(
              child: Obx(() {
                final currentLang = localeCtrl.currentLocale.value.languageCode;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: languages.length,
                  separatorBuilder: (_, i) => Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.dividerDark
                        : Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = currentLang == lang.langCode;
                    return GestureDetector(
                      onTap: () {
                        localeCtrl.changeLocale(
                            lang.langCode, lang.countryCode);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            // Flag
                            Container(
                              width: 36,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.nativeLabel,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                LucideIcons.check,
                                size: 20,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageItem {
  final String langCode;
  final String countryCode;
  final String label;
  final String nativeLabel;
  final String flag;
  const _LanguageItem({
    required this.langCode,
    required this.countryCode,
    required this.label,
    required this.nativeLabel,
    required this.flag,
  });
}
