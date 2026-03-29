// AGENTIC_STABILIZATION_V2
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/notification_controller.dart';
import 'package:methna_app/app/data/models/notification_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/widgets/islamic_pattern_painter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF9F6F2),
      body: Stack(
        children: [
          Positioned.fill(
            child: IslamicPatternWidget(
              opacity: isDark ? 0.03 : 0.05,
              color: isDark ? Colors.white : AppColors.emerald,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                _buildCategoryFilter(isDark),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                    }
                    if (controller.notifications.isEmpty) {
                      return _buildEmptyState(isDark);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: controller.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return _buildNotificationTile(notification, isDark);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Icon(LucideIcons.chevronLeft, color: isDark ? Colors.white : AppColors.secondary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(gradient: AppColors.goldPremiumGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.bell, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            'notifications'.tr,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.secondary),
          ),
          const Spacer(),
          // Mark all as read button
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return GestureDetector(
                onTap: () => controller.markAllAsRead(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'mark_all_read'.tr,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    final categories = ['all', 'message', 'like', 'match', 'visit', 'system'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return ChoiceChip(
              label: Text('cat_$cat'.tr, style: TextStyle(
                fontSize: 13, 
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.secondary : (isDark ? Colors.white70 : Colors.black87),
              )),
              selected: isSelected,
              onSelected: (val) => controller.selectedCategory.value = cat,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              selectedColor: AppColors.gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? AppColors.gold : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05))),
              ),
              showCheckmark: false,
              elevation: 0,
              pressElevation: 0,
            );
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellOff, size: 64, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 16),
          Text('no_notifications'.tr, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification, bool isDark) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notification.type) {
      case 'match':
        iconData = LucideIcons.heart;
        iconColor = const Color(0xFFFF2D55);
        bgColor = const Color(0xFFFF2D55).withValues(alpha: 0.1);
        break;
      case 'like':
      case 'super_like':
        iconData = LucideIcons.star;
        iconColor = AppColors.gold;
        bgColor = AppColors.gold.withValues(alpha: 0.1);
        break;
      case 'message':
        iconData = LucideIcons.messageCircle;
        iconColor = AppColors.emerald;
        bgColor = AppColors.emerald.withValues(alpha: 0.1);
        break;
      case 'visit':
        iconData = LucideIcons.eye;
        iconColor = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.1);
        break;
      case 'system':
      default:
        iconData = LucideIcons.info;
        iconColor = Colors.grey;
        bgColor = Colors.grey.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead 
            ? AppColors.gold.withValues(alpha: 0.05)
            : AppColors.gold.withValues(alpha: 0.2),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
