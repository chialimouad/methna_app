import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/screens/settings/static_content_screen.dart' as methna_app;
import 'package:lucide_icons/lucide_icons.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launch(String url, [String? title]) async {
    if (url.startsWith('http') && !url.contains('play.google.com')) {
      Get.to(() => methna_app.StaticContentScreen(title: title ?? 'Content'));
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Helpers.showSnackbar(message: 'Could not open link', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final items = <_HelpItem>[
      _HelpItem(
        'faq'.tr,
        LucideIcons.helpCircle,
        const Color(0xFF9C27B0),
        () => Get.toNamed(AppRoutes.faq),
      ),
      _HelpItem(
        'contact_support'.tr,
        LucideIcons.headphones,
        const Color(0xFF2196F3),
        () => Get.toNamed(AppRoutes.contactSupport),
      ),
      _HelpItem(
        'terms_conditions'.tr,
        LucideIcons.fileText,
        const Color(0xFF4CAF50),
        () => _launch('https://methna.app/terms', 'Terms & Conditions'),
      ),
      _HelpItem(
        'privacy_policy'.tr,
        LucideIcons.shield,
        const Color(0xFFFF9800),
        () => _launch('https://methna.app/privacy', 'Privacy Policy'),
      ),
      _HelpItem(
        'partner'.tr,
        LucideIcons.heartHandshake,
        const Color(0xFF00BCD4),
        () => _launch('https://methna.app/partner', 'Partner with Us'),
      ),
      _HelpItem(
        'job_vacancy'.tr,
        LucideIcons.briefcase,
        const Color(0xFF795548),
        () => _launch('https://methna.app/careers', 'Job Vacancies'),
      ),
      _HelpItem(
        'accessibility'.tr,
        LucideIcons.accessibility,
        const Color(0xFF607D8B),
        () => _launch('https://methna.app/accessibility', 'Accessibility'),
      ),
      _HelpItem(
        'feedback'.tr,
        LucideIcons.messageSquare,
        const Color(0xFFE91E63),
        () => _showFeedbackDialog(context, isDark),
      ),
      _HelpItem(
        'about_us'.tr,
        LucideIcons.info,
        AppColors.primary,
        () => _showAboutDialog(context),
      ),
      _HelpItem(
        'rate_us'.tr,
        LucideIcons.star,
        const Color(0xFFFFBE0B),
        () => _launch('https://play.google.com/store/apps/details?id=com.methna.app', 'Rate Us'),
      ),
      _HelpItem(
        'visit_website'.tr,
        LucideIcons.globe,
        const Color(0xFF4ECDC4),
        () => _launch('https://methna.app', 'Website'),
      ),
      _HelpItem(
        'follow_social'.tr,
        LucideIcons.share2,
        const Color(0xFFFF6B6B),
        () => _launch('https://linktr.ee/methnaapp', 'Social Links'),
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
                    'help_support'.tr,
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

            // ── Content ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                separatorBuilder: (_, i) => Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.dividerDark
                      : Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: item.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: item.iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon,
                                size: 18, color: item.iconColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          Icon(LucideIcons.chevronRight,
                              size: 22,
                              color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.heart, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('Methna',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Methna is a Muslim matchmaking app designed to help you find your life partner in a halal, respectful, and modern way.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, bool isDark) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('feedback'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Your feedback',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              if (messageCtrl.text.trim().isEmpty) {
                Helpers.showSnackbar(
                    message: 'Please enter your feedback', isError: true);
                return;
              }
              _launch(
                  'mailto:support@methna.app?subject=${Uri.encodeComponent(subjectCtrl.text)}&body=${Uri.encodeComponent(messageCtrl.text)}');
              Get.back();
            },
            child: Text('send'.tr,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _HelpItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  _HelpItem(this.title, this.icon, this.iconColor, this.onTap);
}
