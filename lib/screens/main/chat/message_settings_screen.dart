import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MessageSettingsScreen extends StatelessWidget {
  const MessageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Message Settings', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Chat Preferences
          _Header(title: 'CHAT PREFERENCES', isDark: isDark),
          _ToggleTile(
            icon: LucideIcons.checkCheck,
            title: 'Read Receipts',
            subtitle: 'Let others know when you\'ve read their messages',
            value: true,
            onChanged: (_) {},
            color: AppColors.info,
          ),
          _ToggleTile(
            icon: LucideIcons.keyboard,
            title: 'Typing Indicators',
            subtitle: 'Show when you are typing a message',
            value: true,
            onChanged: (_) {},
            color: AppColors.secondary,
          ),
          _ToggleTile(
            icon: LucideIcons.eye,
            title: 'Message Preview',
            subtitle: 'Show message content in notifications',
            value: true,
            onChanged: (_) {},
            color: AppColors.primary,
          ),

          const SizedBox(height: 8),
          _Header(title: 'NOTIFICATIONS', isDark: isDark),
          _ToggleTile(
            icon: LucideIcons.bellRing,
            title: 'Message Notifications',
            subtitle: 'Get notified when you receive new messages',
            value: true,
            onChanged: (_) {},
            color: AppColors.warning,
          ),
          _ToggleTile(
            icon: LucideIcons.volume2,
            title: 'Message Sound',
            subtitle: 'Play a sound when receiving messages',
            value: true,
            onChanged: (_) {},
            color: AppColors.success,
          ),
          _ToggleTile(
            icon: LucideIcons.smartphone,
            title: 'Vibration',
            subtitle: 'Vibrate when receiving messages',
            value: false,
            onChanged: (_) {},
            color: AppColors.secondary,
          ),

          const SizedBox(height: 8),
          _Header(title: 'PRIVACY', isDark: isDark),
          _ActionTile(
            icon: LucideIcons.filter,
            title: 'Message Filtering',
            subtitle: 'Filter out unwanted or inappropriate messages',
            color: AppColors.primary,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('On', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
            ),
            onTap: () {},
          ),
          _ToggleTile(
            icon: LucideIcons.link,
            title: 'Block Links',
            subtitle: 'Prevent receiving messages with links',
            value: false,
            onChanged: (_) {},
            color: AppColors.error,
          ),
          _ToggleTile(
            icon: LucideIcons.image,
            title: 'Auto-Download Media',
            subtitle: 'Automatically download shared photos',
            value: true,
            onChanged: (_) {},
            color: AppColors.info,
          ),

          const SizedBox(height: 8),
          _Header(title: 'CHAT APPEARANCE', isDark: isDark),
          _ActionTile(
            icon: LucideIcons.type,
            title: 'Chat Font Size',
            subtitle: 'Adjust the size of text in conversations',
            color: AppColors.secondary,
            trailing: const Text('Medium', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            onTap: () => _showFontSizeDialog(context),
          ),
          _ActionTile(
            icon: LucideIcons.wallpaper,
            title: 'Chat Wallpaper',
            subtitle: 'Customize chat background',
            color: AppColors.primary,
            onTap: () {},
          ),
          _ActionTile(
            icon: LucideIcons.messageCircle,
            title: 'Bubble Style',
            subtitle: 'Choose message bubble appearance',
            color: AppColors.warning,
            trailing: const Text('Modern', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            onTap: () {},
          ),

          const SizedBox(height: 8),
          _Header(title: 'DATA', isDark: isDark),
          _ActionTile(
            icon: LucideIcons.archive,
            title: 'Archived Chats',
            subtitle: 'View your archived conversations',
            color: AppColors.info,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.info)),
            ),
            onTap: () {},
          ),
          _ActionTile(
            icon: LucideIcons.uploadCloud,
            title: 'Chat Backup',
            subtitle: 'Back up your conversations',
            color: AppColors.success,
            onTap: () {},
          ),
          _ActionTile(
            icon: LucideIcons.trash2,
            title: 'Delete All Chats',
            subtitle: 'Remove all your conversations',
            color: AppColors.error,
            onTap: () => _showDeleteAllDialog(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chat Font Size', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FontOption(label: 'Small', isSelected: false),
            _FontOption(label: 'Medium', isSelected: true),
            _FontOption(label: 'Large', isSelected: false),
            _FontOption(label: 'Extra Large', isSelected: false),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete All Chats', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This will permanently delete all your conversations and messages. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Delete All', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final bool isDark;
  const _Header({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1,
          color: isDark ? AppColors.textHintDark : AppColors.textHintLight)),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _ToggleTile({required this.icon, required this.title, required this.subtitle,
      required this.value, required this.onChanged, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.title, required this.subtitle,
      required this.color, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 22),
    );
  }
}

class _FontOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FontOption({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Get.back(),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          color: isSelected ? AppColors.primary : null)),
      trailing: isSelected ? const Icon(LucideIcons.checkCircle, color: AppColors.primary) : null,
    );
  }
}
