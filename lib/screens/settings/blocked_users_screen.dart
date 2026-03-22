import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BlockedUsersScreen extends GetView<SettingsController> {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA),
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
                  Obx(() => Text(
                    '${'blocked_users'.tr} (${controller.blockedUsers.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
                  )),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Grid ──
            Expanded(
              child: Obx(() {
                if (controller.isLoadingBlocked.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.blockedUsers.isEmpty) {
                  return const AnimatedEmptyState(
                    lottieAsset: 'assets/animations/no_blocked_users.json',
                    title: 'No blocked users',
                    subtitle: 'Users you block will appear here.\nThey won\'t be able to see your profile or message you.',
                    fallbackIcon: LucideIcons.shieldOff,
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: controller.blockedUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.blockedUsers[index];
                    return _UserCard(
                      user: user,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      isDark: isDark,
                      onUnblock: () => _confirmUnblock(context, user),
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

  void _confirmUnblock(BuildContext context, UserModel user) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('unblock_user'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text('${'unblock_confirm'.tr} ${user.firstName ?? user.username ?? 'this user'}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              controller.unblockUser(user.id);
            },
            child: Text('unblock'.tr,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── User card ────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserModel user;
  final Color textColor;
  final Color secondaryColor;
  final bool isDark;
  final VoidCallback onUnblock;

  const _UserCard({
    required this.user,
    required this.textColor,
    required this.secondaryColor,
    required this.isDark,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUnblock,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            if (user.mainPhotoUrl != null && user.mainPhotoUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: user.mainPhotoUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: isDark ? AppColors.cardDark : Colors.grey.shade300,
                child: Center(
                  child: Text(
                    Helpers.getInitials(user.firstName, user.lastName),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                  ),
                ),
              ),

            // Gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 28, 12, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName ?? user.username ?? 'User'}${user.profile?.age != null ? ' (${user.profile!.age})' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'blocked'.tr,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
