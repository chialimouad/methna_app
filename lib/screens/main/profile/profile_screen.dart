import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/core/widgets/baraka_meter.dart';
import 'package:methna_app/core/widgets/intent_badge.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            );
          }

          final profile = user.profile;
          final completion = controller.profileCompletion;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Top bar: Profile title + settings button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Text('profile'.tr, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor)),
                    const Spacer(),
                    GestureDetector(
                      onTap: controller.openSettings,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(LucideIcons.settings, size: 20, color: textColor),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── LARGE SQUARE profile photo ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          controller.mainPhoto != null
                              ? CachedNetworkImage(
                                  imageUrl: controller.mainPhoto!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.primarySurface,
                                  child: Center(
                                    child: Text(
                                      Helpers.getInitials(user.firstName, user.lastName),
                                      style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                          // Bottom gradient overlay with name
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${user.firstName ?? user.username ?? "User"}, ${profile?.age ?? ""}',
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                      if (controller.isVerified) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: AppColors.verified, shape: BoxShape.circle),
                                          child: const Icon(LucideIcons.check, color: Colors.white, size: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (profile?.city != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.mapPin, color: Colors.white70, size: 14),
                                        const SizedBox(width: 4),
                                        Text(profile!.city!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // Edit button
                          Positioned(
                            top: 12, right: 12,
                            child: GestureDetector(
                              onTap: controller.openEditProfile,
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.pencil, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Complete profile banner ──
              if (completion < 100)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: controller.openEditProfile,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF9B59FF)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44, height: 44,
                            child: CustomPaint(
                              painter: _CompletionRingPainter(completion / 100),
                              child: Center(
                                child: Text('$completion%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('complete_profile'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text('complete_profile_desc'.tr, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                              ],
                            ),
                          ),
                          Icon(LucideIcons.chevronRight, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ── Baraka Meter + Intent Mode ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Your Baraka', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BarakaMeter(
                        score: profile?.profileCompletionPercentage ?? 0,
                        level: (profile?.profileCompletionPercentage ?? 0) >= 80 ? 'excellent' : (profile?.profileCompletionPercentage ?? 0) >= 50 ? 'good' : 'low',
                        compact: false,
                      ),
                      if (profile?.intentMode != null) ...[
                        const SizedBox(height: 12),
                        IntentBadge(intentMode: profile!.intentMode!, compact: false),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Bio Section ──
              if (profile?.bio != null && profile!.bio!.isNotEmpty)
                _InfoSection(
                  title: 'About Me',
                  icon: LucideIcons.quote,
                  isDark: isDark, cardBg: cardBg, borderColor: borderColor, textColor: textColor, secondaryColor: secondaryColor,
                  child: Text(profile.bio!, style: TextStyle(fontSize: 14, color: textColor, height: 1.5)),
                ),

              // ── Lifestyle Section ──
              _InfoSection(
                title: 'Lifestyle',
                icon: LucideIcons.heart,
                isDark: isDark, cardBg: cardBg, borderColor: borderColor, textColor: textColor, secondaryColor: secondaryColor,
                child: Wrap(
                  spacing: 8, runSpacing: 10,
                  children: [
                    if (profile?.maritalStatus != null) _InfoTag(icon: LucideIcons.users, label: profile!.maritalStatus!.capitalize!, isDark: isDark),
                    if (profile?.gender != null) _InfoTag(icon: LucideIcons.user, label: profile!.gender!.capitalize!, isDark: isDark),
                    if (profile?.education != null) _InfoTag(icon: LucideIcons.graduationCap, label: profile!.education!.capitalize!, isDark: isDark),
                    if (profile?.jobTitle != null) _InfoTag(icon: LucideIcons.briefcase, label: profile!.jobTitle!, isDark: isDark),
                    if (profile?.height != null) _InfoTag(icon: LucideIcons.ruler, label: '${profile!.height} cm', isDark: isDark),
                  ],
                ),
              ),

              // ── Faith & Religion ──
              if (profile?.sect != null || profile?.religiousLevel != null || profile?.prayerFrequency != null)
                _InfoSection(
                  title: 'Faith & Religion',
                  icon: LucideIcons.bookOpen,
                  isDark: isDark, cardBg: cardBg, borderColor: borderColor, textColor: textColor, secondaryColor: secondaryColor,
                  child: Wrap(
                    spacing: 8, runSpacing: 10,
                    children: [
                      if (profile?.sect != null) _InfoTag(icon: LucideIcons.moon, label: profile!.sect!.capitalize!, isDark: isDark),
                      if (profile?.religiousLevel != null) _InfoTag(icon: LucideIcons.sparkles, label: profile!.religiousLevel!.capitalize!, isDark: isDark),
                      if (profile?.prayerFrequency != null) _InfoTag(icon: LucideIcons.clock, label: profile!.prayerFrequency!.capitalize!, isDark: isDark),
                    ],
                  ),
                ),

              // ── Interests ──
              if (profile?.interests != null && profile!.interests!.isNotEmpty)
                _InfoSection(
                  title: 'interests'.tr,
                  icon: LucideIcons.sparkle,
                  isDark: isDark, cardBg: cardBg, borderColor: borderColor, textColor: textColor, secondaryColor: secondaryColor,
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: profile!.interests!.map((i) => _InterestChip(label: i)).toList(),
                  ),
                ),

              const SizedBox(height: 100),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Completion ring painter ─────────────────────────────────────────────
class _CompletionRingPainter extends CustomPainter {
  final double progress;
  _CompletionRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    canvas.drawCircle(center, r, Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r), -pi / 2, 2 * pi * progress, false,
      Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CompletionRingPainter old) => old.progress != progress;
}

// ─── Reusable info section card ──────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final Color cardBg, borderColor, textColor, secondaryColor;
  final Widget child;

  const _InfoSection({
    required this.title, required this.icon,
    required this.isDark, required this.cardBg, required this.borderColor,
    required this.textColor, required this.secondaryColor, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Info tag (icon + label pill) ────────────────────────────────────────
class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoTag({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF5F0FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
        ],
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
