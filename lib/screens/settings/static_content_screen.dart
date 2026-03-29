import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';

class StaticContentScreen extends GetView<SettingsController> {
  final String title;
  final String contentType;

  const StaticContentScreen({
    super.key,
    required this.title,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: controller.fetchAppContent(contentType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.fileWarning, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 24),
                    Text(
                      'Content Unavailable',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This content is currently being updated by our team. Please check back later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: secondaryColor, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(
              snapshot.data!,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: secondaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
