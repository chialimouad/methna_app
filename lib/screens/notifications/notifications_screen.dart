import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:methna_app/app/data/services/notification_service.dart';
import 'package:methna_app/app/data/models/notification_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final service = Get.find<NotificationService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA);
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    service.fetchNotifications();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(LucideIcons.chevronLeft, size: 18, color: textColor),
                    ),
                  ),
                  const Spacer(),
                  Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Notification list ──
            Expanded(
              child: Obx(() {
                if (service.notifications.isEmpty) {
                  return const AnimatedEmptyState(
                    lottieAsset: 'assets/animations/no_notifications.json',
                    title: 'No notifications yet',
                    subtitle: 'Check back later for new matches, messages,\nand app updates.',
                    fallbackIcon: LucideIcons.bellOff,
                  );
                }

                final notifications = service.notifications.toList();

                // Group by date
                final grouped = <String, List<NotificationModel>>{};
                final now = DateTime.now();
                final todayDate = DateTime(now.year, now.month, now.day);
                final yesterdayDate = todayDate.subtract(const Duration(days: 1));

                for (final n in notifications) {
                  final nDate = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
                  String label;
                  if (nDate == todayDate) {
                    label = 'Today';
                  } else if (nDate == yesterdayDate) {
                    label = 'Yesterday';
                  } else {
                    label = DateFormat('MMM dd, yyyy').format(n.createdAt);
                  }
                  grouped.putIfAbsent(label, () => []);
                  grouped[label]!.add(n);
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: grouped.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                        child: Text(entry.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: secondaryColor)),
                      ),
                      ...entry.value.map((n) => _NotificationTile(
                        notification: n,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: () => service.markAsRead(n.id),
                      )),
                    ];
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textColor,
    required this.secondaryColor,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'match': return LucideIcons.heart;
      case 'like': return LucideIcons.thumbsUp;
      case 'super_like': return LucideIcons.star;
      case 'message': return LucideIcons.messageCircle;
      case 'subscription': return LucideIcons.crown;
      case 'boost': return LucideIcons.zap;
      case 'profile_view': return LucideIcons.eye;
      case 'verification': return LucideIcons.shieldCheck;
      default: return LucideIcons.bell;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'match': return const Color(0xFFE91E63);
      case 'like': return const Color(0xFFFF6B6B);
      case 'super_like': return const Color(0xFFFF9800);
      case 'message': return const Color(0xFF2196F3);
      case 'subscription': return AppColors.primary;
      case 'boost': return const Color(0xFFFFC107);
      case 'profile_view': return const Color(0xFF9C27B0);
      case 'verification': return const Color(0xFF4CAF50);
      default: return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? AppColors.primary.withValues(alpha: 0.04) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: unread ? AppColors.primary.withValues(alpha: 0.12) : borderColor, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, size: 20, color: _iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(fontSize: 14, fontWeight: unread ? FontWeight.w700 : FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: secondaryColor, height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.timeAgo(notification.createdAt),
                    style: TextStyle(fontSize: 11, color: secondaryColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
