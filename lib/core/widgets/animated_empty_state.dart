import 'package:flutter/material.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/widgets/animated_icons.dart';

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

  Widget _buildAnimatedIcon() {
    final c = fallbackColor ?? AppColors.primary;
    final s = width * 0.65;

    // Map lottie asset names to pure Flutter animated icons
    final lower = lottieAsset.toLowerCase();
    if (lower.contains('heart') || lower.contains('like') || lower.contains('match')) {
      return AnimatedHeartIcon(size: s, color: c);
    } else if (lower.contains('search') || lower.contains('discover') || lower.contains('no_user')) {
      return AnimatedSearchIcon(size: s, color: c);
    } else if (lower.contains('location') || lower.contains('map') || lower.contains('pin')) {
      return AnimatedLocationIcon(size: s, color: c);
    } else if (lower.contains('chat') || lower.contains('message') || lower.contains('inbox')) {
      return AnimatedChatIcon(size: s, color: c);
    } else if (lower.contains('check') || lower.contains('success') || lower.contains('done')) {
      return AnimatedCheckIcon(size: s, color: c);
    } else if (lower.contains('bell') || lower.contains('notif')) {
      return AnimatedBellIcon(size: s, color: c);
    } else if (lower.contains('star') || lower.contains('sparkle') || lower.contains('premium')) {
      return AnimatedSparkleIcon(size: s, color: c);
    }
    // Default: pulsing heart
    return AnimatedHeartIcon(size: s, color: c);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedIcon(),
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
