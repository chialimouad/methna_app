import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:methna_app/app/theme/app_colors.dart';

class AnimatedEmptyState extends StatelessWidget {
  final String lottieAsset;
  final String title;
  final String subtitle;
  final double width;
  final IconData? fallbackIcon;
  final Color? fallbackColor;

  const AnimatedEmptyState({
    super.key,
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
    this.width = 200,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              lottieAsset,
              width: width,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Return a beautiful fallback icon if lottie asset fails to load
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: (fallbackColor ?? AppColors.primary).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    fallbackIcon ?? Icons.inbox_rounded,
                    size: 60,
                    color: fallbackColor ?? AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
