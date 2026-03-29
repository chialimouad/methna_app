import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/utils/cloudinary_url.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(() {
        final user = controller.user.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSimpleHeader(user, isDark),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                child: Column(
                  children: [
                    // Profile Card
                    _buildProfileCard(user, isDark),
                    const SizedBox(height: 24),
                    
                    // Quick Stats
                    _buildQuickStats(user, isDark),
                    const SizedBox(height: 32),
                    
                    // Bio
                    if (user.profile?.bio?.isNotEmpty ?? false) ...[
                      _buildSimpleBio(user, isDark),
                      const SizedBox(height: 32),
                    ],
                    
                    // About Me Section
                    _buildAboutSection(user, isDark),
                    const SizedBox(height: 32),
                    
                    // Interests
                    if (user.profile?.interests?.isNotEmpty ?? false) ...[
                      _buildInterestsSection(user.profile!.interests!, isDark),
                      const SizedBox(height: 32),
                    ],
                    
                    // Verification Badge
                    _buildVerificationCard(user, isDark),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSimpleHeader(UserModel user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 22),
          ),
        ),
      ),
      actions: [
        _buildHeaderAction(LucideIcons.edit3, () => controller.openEditProfile()),
        _buildHeaderAction(LucideIcons.settings, () => controller.openSettings()),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (user.mainPhotoUrl != null)
              CachedNetworkImage(
                imageUrl: CloudinaryUrl.large(user.mainPhotoUrl),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  ),
                ),
                child: Center(
                  child: Text(
                    Helpers.getInitials(user.firstName ?? '', user.lastName ?? ''),
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            // Simple gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserModel user, bool isDark) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (user.selfieVerified) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.badgeCheck, color: AppColors.emerald, size: 20),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(LucideIcons.mapPin, '${user.profile?.city ?? ''}, ${user.profile?.country ?? ''}', isDark),
                const SizedBox(width: 12),
                _buildInfoChip(LucideIcons.cake, '${user.profile?.age ?? "?"} yrs', isDark),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(UserModel user, bool isDark) {
    final score = controller.barakaScore;
    
    return Row(
      children: [
        _buildStatItem('Profile', '$score%', LucideIcons.sparkles, AppColors.primary, isDark),
        const SizedBox(width: 12),
        _buildStatItem('Boosts', '${user.profileBoostsCount}', LucideIcons.zap, AppColors.gold, isDark),
        const SizedBox(width: 12),
        _buildStatItem('Likes', '${user.sentComplimentsCount}', LucideIcons.heart, AppColors.error, isDark),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBio(UserModel user, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.quote, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('About Me', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.profile?.bio ?? '',
            style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Widget _buildAboutSection(UserModel user, bool isDark) {
    final details = <_DetailItem>[
      _DetailItem(label: 'Sect', value: user.profile?.sect, icon: LucideIcons.shield),
      _DetailItem(label: 'Prayer', value: user.profile?.prayerFrequency, icon: LucideIcons.sunrise),
      _DetailItem(label: 'Nationality', value: user.profile?.nationality, icon: LucideIcons.globe),
      _DetailItem(label: 'Education', value: user.profile?.education, icon: LucideIcons.graduationCap),
      _DetailItem(label: 'Profession', value: user.profile?.jobTitle, icon: LucideIcons.briefcase),
      _DetailItem(label: 'Height', value: user.profile?.height != null ? '${user.profile!.height} cm' : null, icon: LucideIcons.ruler),
      _DetailItem(label: 'Status', value: user.profile?.maritalStatus, icon: LucideIcons.heart),
      _DetailItem(label: 'Looking For', value: user.profile?.marriageIntention, icon: LucideIcons.search),
    ];
    
    final active = details.where((i) => i.value != null && i.value!.isNotEmpty).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.user, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: active.map((item) => _buildDetailChip(item, isDark)).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildDetailChip(_DetailItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            item.value!.replaceAll('_', ' ').capitalizeFirst!,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(List<String> interests, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.heart, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Interests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                interest.tr,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            )).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 400.ms);
  }

  Widget _buildVerificationCard(UserModel user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shieldCheck, color: AppColors.emerald, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Verification', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          _buildVerifyRow('Email', user.email, user.emailVerified, isDark),
          const SizedBox(height: 12),
          _buildVerifyRow('Selfie', user.selfieVerified ? 'Verified' : 'Pending', user.selfieVerified, isDark),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildVerifyRow(String label, String value, bool isOk, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
        Icon(
          isOk ? LucideIcons.checkCircle2 : LucideIcons.clock,
          color: isOk ? AppColors.emerald : Colors.orange,
          size: 20,
        ),
      ],
    );
  }
}

class _ModernSecurityRow extends StatelessWidget {
  final String label, val;
  final bool isOk, isDark;
  final IconData icon;

  const _ModernSecurityRow({required this.label, required this.val, required this.isOk, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isOk ? AppColors.emerald : Colors.orange).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Icon(isOk ? LucideIcons.badgeCheck : LucideIcons.badgeAlert, color: isOk ? AppColors.emerald : Colors.orange, size: 28),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String? value;
  final IconData icon;
  _DetailItem({required this.label, this.value, required this.icon});
}

class _VerificationRow extends StatelessWidget {
  final String label, value;
  final bool isVerified, isDark;
  final IconData icon;

  const _VerificationRow({required this.label, required this.value, required this.isVerified, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w700)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Icon(isVerified ? LucideIcons.checkCircle2 : LucideIcons.alertCircle, color: isVerified ? AppColors.emerald : Colors.orange, size: 20),
      ],
    );
  }
}
