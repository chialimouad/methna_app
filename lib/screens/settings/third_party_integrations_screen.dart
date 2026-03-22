import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ThirdPartyIntegrationsScreen extends StatelessWidget {
  const ThirdPartyIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('integrations'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.info, color: AppColors.info, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Connect your social accounts to enhance your profile and make it easier for others to know you.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('SOCIAL ACCOUNTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.grey)),
          const SizedBox(height: 12),

          // Instagram
          _IntegrationTile(
            icon: LucideIcons.camera,
            title: 'Instagram',
            subtitle: 'Show your Instagram photos on your profile',
            color: const Color(0xFFE1306C),
            isConnected: false,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 10),

          // Snapchat
          _IntegrationTile(
            icon: LucideIcons.camera,
            title: 'Snapchat',
            subtitle: 'Share your Snapchat for easy connection',
            color: const Color(0xFFFFFC00),
            iconColor: Colors.black,
            isConnected: false,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 10),

          // Twitter/X
          _IntegrationTile(
            icon: LucideIcons.tag,
            title: 'X (Twitter)',
            subtitle: 'Display your latest posts on your profile',
            color: const Color(0xFF1DA1F2),
            isConnected: false,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 10),

          // Spotify
          _IntegrationTile(
            icon: LucideIcons.music,
            title: 'Spotify',
            subtitle: 'Show your top artists and what you listen to',
            color: const Color(0xFF1DB954),
            isConnected: true,
            connectedAs: '@ahmed_music',
            isDark: isDark,
            onTap: () {},
          ),

          const SizedBox(height: 24),
          const Text('VERIFICATION SERVICES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.grey)),
          const SizedBox(height: 12),

          // Google
          _IntegrationTile(
            icon: LucideIcons.signal,
            title: 'Google Account',
            subtitle: 'Quick login and identity verification',
            color: const Color(0xFF4285F4),
            isConnected: true,
            connectedAs: 'ahmed@gmail.com',
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 10),

          // Apple
          _IntegrationTile(
            icon: LucideIcons.apple,
            title: 'Apple ID',
            subtitle: 'Sign in with Apple for enhanced security',
            color: isDark ? Colors.white : Colors.black,
            isConnected: false,
            isDark: isDark,
            onTap: () {},
          ),

          const SizedBox(height: 24),
          const Text('MESSAGING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.grey)),
          const SizedBox(height: 12),

          // WhatsApp
          _IntegrationTile(
            icon: LucideIcons.messageCircle,
            title: 'WhatsApp',
            subtitle: 'Allow matched users to reach you on WhatsApp',
            color: const Color(0xFF25D366),
            isConnected: false,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 10),

          // Telegram
          _IntegrationTile(
            icon: LucideIcons.send,
            title: 'Telegram',
            subtitle: 'Share your Telegram for direct messaging',
            color: const Color(0xFF0088CC),
            isConnected: false,
            isDark: isDark,
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Disconnect all
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.link2Off, size: 18, color: AppColors.error),
              label: Text('disconnect_all'.tr, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _IntegrationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color? iconColor;
  final bool isConnected;
  final String? connectedAs;
  final bool isDark;
  final VoidCallback onTap;

  const _IntegrationTile({
    required this.icon, required this.title, required this.subtitle,
    required this.color, this.iconColor, required this.isConnected,
    this.connectedAs, required this.isDark, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: isConnected ? Border.all(color: color.withValues(alpha: 0.3), width: 1) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor ?? color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  isConnected ? 'Connected${connectedAs != null ? ' as $connectedAs' : ''}' : subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isConnected ? AppColors.success : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    fontWeight: isConnected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isConnected ? AppColors.error.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isConnected ? 'Disconnect' : 'Connect',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isConnected ? AppColors.error : color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
