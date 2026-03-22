import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/controllers/home_controller.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/data/services/monetization_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final UserModel? user = args?['user'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Record profile view when screen opens
    if (user != null) {
      Get.find<MonetizationService>().recordProfileView(user.id);
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Photo header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 18),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 18),
                ),
                onPressed: () => _showUserActions(context, user),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  user.mainPhotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: user.mainPhotoUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.primarySurface,
                          child: Center(
                            child: Text(
                              Helpers.getInitials(user.firstName, user.lastName),
                              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ),
                        ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${user.firstName ?? user.username ?? 'User'}, ${user.profile?.age ?? ''}',
                                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (user.selfieVerified)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: AppColors.verified, shape: BoxShape.circle),
                                child: const Icon(LucideIcons.check, color: Colors.white, size: 16),
                              ),
                          ],
                        ),
                        if (user.profile?.city != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(user.profile!.city!, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio
                  if (user.profile?.bio != null) ...[
                    Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(user.profile!.bio!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
                    const SizedBox(height: 24),
                  ],

                  // Quick info chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (user.profile?.gender != null)
                        _InfoChip(icon: LucideIcons.user, label: user.profile!.gender!.capitalize!),
                      if (user.profile?.maritalStatus != null)
                        _InfoChip(icon: LucideIcons.heart, label: user.profile!.maritalStatus!.capitalize!),
                      if (user.profile?.height != null)
                        _InfoChip(icon: LucideIcons.ruler, label: '${user.profile!.height} cm'),
                      if (user.profile?.education != null)
                        _InfoChip(icon: LucideIcons.graduationCap, label: user.profile!.education!),
                      if (user.profile?.jobTitle != null)
                        _InfoChip(icon: LucideIcons.briefcase, label: user.profile!.jobTitle!),
                      if (user.profile?.religiousLevel != null)
                        _InfoChip(icon: LucideIcons.moon, label: user.profile!.religiousLevel!),
                    ],
                  ),

                  // Interests
                  if (user.profile?.interests != null && user.profile!.interests!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Interests', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.profile!.interests!.map((i) => Chip(
                            label: Text(i, style: const TextStyle(fontSize: 13)),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                            side: BorderSide.none,
                          )).toList(),
                    ),
                  ],

                  // Photos
                  if (user.photos != null && user.photos!.length > 1) ...[
                    const SizedBox(height: 24),
                    Text('Photos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: user.photos!.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: user.photos![index].url,
                              width: 150,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomAction(
              icon: LucideIcons.x,
              color: AppColors.pass,
              label: 'Pass',
              onTap: () {
                Get.find<HomeController>().passUser(user.id);
                Get.back();
              },
            ),
            _BottomAction(
              icon: LucideIcons.heart,
              color: AppColors.like,
              label: 'Like',
              onTap: () {
                Get.find<HomeController>().likeUser(user.id);
                Get.back();
              },
            ),
            _BottomAction(
              icon: LucideIcons.rotateCcw,
              color: AppColors.premium,
              label: 'Rematch',
              onTap: () {
                Get.find<HomeController>().requestRematch(user.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserActions(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(LucideIcons.ban, color: AppColors.error),
              title: Text('block_user'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('block_user_desc'.tr, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              onTap: () {
                Get.back();
                _confirmBlock(context, user);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.flag, color: Color(0xFFFF9800)),
              title: Text('report_user'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('report_user_desc'.tr, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              onTap: () {
                Get.back();
                _showReportDialog(context, user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBlock(BuildContext context, UserModel user) {
    Helpers.showLottieDialog(
      lottieAsset: 'assets/animations/warning.json',
      title: 'block_user'.tr,
      message: '${'block_confirm'.tr} ${user.firstName ?? user.username ?? 'this user'}?',
      confirmText: 'block'.tr,
      showCancelButton: true,
      onConfirm: () {
        Get.find<SettingsController>().blockUser(user.id);
        Get.back();
      },
    );
  }

  void _showReportDialog(BuildContext context, UserModel user) {
    final reasons = ['Inappropriate content', 'Fake profile', 'Harassment', 'Spam', 'Other'];
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('report_user'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((reason) => ListTile(
            dense: true,
            title: Text(reason),
            onTap: () {
              Get.back();
              Get.find<SettingsController>().submitReport(user.id, reason);
            },
          )).toList(),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.dividerLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _BottomAction({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
