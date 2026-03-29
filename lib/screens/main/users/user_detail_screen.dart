// AGENTIC_STABILIZATION_V2
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/controllers/home_controller.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/data/services/monetization_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/cloudinary_url.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/core/widgets/islamic_pattern_painter.dart';
import 'package:methna_app/core/widgets/mihrab_clipper.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final UserModel? userModel = args?['user'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (userModel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    // Explicit non-nullable promotion for closures
    final UserModel user = userModel;

    // Record profile view
    Get.find<MonetizationService>().recordProfileView(user.id);

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
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                leading: IconButton(
                  icon: _buildMihrabIconButton(LucideIcons.chevronLeft),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  IconButton(
                    icon: _buildMihrabIconButton(LucideIcons.moreVertical),
                    onPressed: () => _showUserActions(context, user),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _GalleryHeader(user: user),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.profile?.bio != null) ...[
                        Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(user.profile!.bio!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
                        const SizedBox(height: 24),
                      ],

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

                      if (user.profile?.interests != null && user.profile!.interests!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Interests', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.profile!.interests!.map((i) => _buildInterestTag(i)).toList(),
                        ),
                      ],

                      const SizedBox(height: 180),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, user, isDark),
    );
  }

  Widget _buildMihrabIconButton(IconData icon) {
    return Container(
      width: 44, height: 48,
      padding: const EdgeInsets.all(2),
      child: ClipPath(
        clipper: MihrabClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildInterestTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
    );
  }

  Widget _buildBottomBar(BuildContext context, UserModel user, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          _CircleActionBtn(
            icon: LucideIcons.x,
            color: AppColors.textHintLight,
            onTap: () {
              Get.find<HomeController>().passUser(user.id);
              Get.back();
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.goldPremiumGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Get.find<HomeController>().likeUser(user.id);
                  Get.back();
                },
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Text('Interested', style: TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _CircleActionBtn(
            icon: LucideIcons.award,
            color: AppColors.gold,
            onTap: () => _showComplimentDialog(context, user.id),
          ),
        ],
      ),
    );
  }

  void _showComplimentDialog(BuildContext context, String userId) {
    final controller = Get.find<HomeController>();
    final tc = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Compliment', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: tc,
          maxLength: 200,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Write something nice...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (tc.text.trim().isNotEmpty) {
                controller.complimentUser(userId, tc.text.trim());
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Send'),
          ),
        ],
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
            ListTile(
              leading: const Icon(LucideIcons.ban, color: AppColors.error),
              title: Text('block_user'.tr),
              onTap: () {
                Get.back();
                _confirmBlock(user);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.flag, color: Colors.orange),
              title: Text('report_user'.tr),
              onTap: () {
                Get.back();
                _showReportDialog(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBlock(UserModel user) {
    Get.find<SettingsController>().blockUser(user.id);
  }

  void _showReportDialog(UserModel user) {
    Get.find<SettingsController>().submitReport(user.id, 'Spam');
  }
}

class _GalleryHeader extends StatelessWidget {
  final UserModel user;
  const _GalleryHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final photos = user.photos ?? [];
    final displayPhotos = photos.isNotEmpty 
        ? photos.map((p) => p.url).toList() 
        : (user.mainPhotoUrl != null ? [user.mainPhotoUrl!] : []);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: displayPhotos.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(imageUrl: CloudinaryUrl.large(displayPhotos[index]), fit: BoxFit.cover);
          },
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20, left: 20, right: 20,
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
                    const Icon(LucideIcons.shieldCheck, color: AppColors.gold, size: 24),
                ],
              ),
              if (user.profile?.city != null)
                Text(user.profile!.city!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.4))),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
