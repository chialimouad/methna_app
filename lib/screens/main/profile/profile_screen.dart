import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  static const _purple = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA);
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          final user = controller.user.value;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.userCircle, size: 64, color: secondaryColor),
                  const SizedBox(height: 16),
                  Text('Could not load profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 8),
                  Text('Check your connection and try again', style: TextStyle(fontSize: 13, color: secondaryColor)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: controller.refreshProfile,
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Top bar: logo + Profile + UPGRADE + settings ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    // Logo placeholder
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_purple, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.heart,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'profile'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // UPGRADE pill
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: _purple),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.star,
                                size: 12, color: _purple),
                            const SizedBox(width: 4),
                            Text(
                              'upgrade'.tr,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: controller.openSettings,
                      child: Icon(LucideIcons.settings,
                          size: 24, color: textColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Complete profile banner ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: controller.openEditProfile,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_purple, Color(0xFF9B59FF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Percentage circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${controller.profileCompletion}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'complete_profile'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'complete_profile_desc'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(LucideIcons.chevronRight,
                            size: 16,
                            color:
                                Colors.white.withValues(alpha: 0.7)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Profile photo (large circle) ──
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: controller.mainPhoto != null
                            ? CachedNetworkImage(
                                imageUrl: controller.mainPhoto!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.primarySurface,
                                child: Center(
                                  child: Text(
                                    Helpers.getInitials(
                                        user.firstName, user.lastName),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Name (Age) ──
              Center(
                child: Text(
                  '${user.firstName ?? user.username ?? 'User'} (${user.profile?.age ?? ''})',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Gender + Location ──
              if (user.profile?.gender != null)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.user,
                          size: 16, color: secondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        user.profile!.gender!.capitalize!,
                        style: TextStyle(
                            fontSize: 14, color: secondaryColor),
                      ),
                    ],
                  ),
                ),

              if (user.profile?.city != null) ...[
                const SizedBox(height: 4),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.mapPin,
                          size: 16, color: secondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        user.profile!.city!,
                        style: TextStyle(
                            fontSize: 14, color: secondaryColor),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Interests ──
              if (user.profile?.interests != null &&
                  user.profile!.interests!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'interests'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.profile!.interests!
                        .map((i) => _InterestChip(label: i))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Relationship Goals ──
              if (user.profile?.maritalStatus != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                          color: isDark
                              ? AppColors.dividerDark
                              : Colors.grey.shade200),
                      const SizedBox(height: 8),
                      Text(
                        'relationship_goals'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${user.profile!.maritalStatus!.capitalize!} 💑',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 80),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Interest chip with emoji ─────────────────────────────────────────────
class _InterestChip extends StatelessWidget {
  final String label;
  const _InterestChip({required this.label});

  String get _emoji {
    final lower = label.toLowerCase();
    if (lower.contains('travel')) return '✈️';
    if (lower.contains('movie') || lower.contains('film')) return '🎬';
    if (lower.contains('art')) return '🎨';
    if (lower.contains('tech')) return '📱';
    if (lower.contains('science')) return '🔬';
    if (lower.contains('music')) return '🎵';
    if (lower.contains('sport') || lower.contains('fitness')) return '⚽';
    if (lower.contains('cook') || lower.contains('food')) return '🍳';
    if (lower.contains('read') || lower.contains('book')) return '📚';
    if (lower.contains('photo')) return '📷';
    if (lower.contains('gaming') || lower.contains('game')) return '🎮';
    if (lower.contains('nature') || lower.contains('hik')) return '🌿';
    if (lower.contains('yoga')) return '🧘';
    if (lower.contains('coffee')) return '☕';
    if (lower.contains('swim')) return '🏊';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        '$label $_emoji',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
