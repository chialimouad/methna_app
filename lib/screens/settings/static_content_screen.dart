import 'package:flutter/material.dart';

import 'package:methna_app/app/theme/app_colors.dart';

class StaticContentScreen extends StatelessWidget {
  final String title;

  const StaticContentScreen({super.key, required this.title});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About $title',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This is the native, completely localized in-app content specifically tailored for your app\'s $title. It functions as a placeholder since a native implementation was specifically requested to replace external web navigation.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Methna App ensures that your privacy, security, and usage experience is seamless without leaving the application. Detailed native documentation and formatting can be rendered completely here natively without standard WebViews.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
