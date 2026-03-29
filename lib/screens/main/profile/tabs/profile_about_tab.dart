import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// About Tab with detailed profile information
class ProfileAboutTab extends StatelessWidget {
  final UserModel user;
  
  const ProfileAboutTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final profile = user.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Section
          _SectionCard(
            title: 'Basic Information',
            icon: LucideIcons.user,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            children: [
              _InfoRow(
                icon: LucideIcons.calendar,
                label: 'Age',
                value: profile != null ? (profile.age?.toString() ?? 'Not specified') : 'Not specified',
                textColor: textColor,
              ),
              _InfoRow(
                icon: LucideIcons.mapPin,
                label: 'Location',
                value: '${profile?.city ?? ''}, ${profile?.country ?? ''}'.isEmpty 
                    ? 'Not specified' 
                    : '${profile!.city}, ${profile.country}',
                textColor: textColor,
              ),
              _InfoRow(
                icon: LucideIcons.heart,
                label: 'Marital Status',
                value: _formatMaritalStatus(profile?.maritalStatus),
                textColor: textColor,
              ),
              _InfoRow(
                icon: LucideIcons.graduationCap,
                label: 'Education',
                value: _formatEducation(profile?.education),
                textColor: textColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Professional Info Section
          _SectionCard(
            title: 'Professional Information',
            icon: LucideIcons.briefcase,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            children: [
              _InfoRow(
                icon: LucideIcons.user,
                label: 'Job Title',
                value: profile?.jobTitle ?? 'Not specified',
                textColor: textColor,
              ),
              _InfoRow(
                icon: LucideIcons.building,
                label: 'Company',
                value: profile?.company ?? 'Not specified',
                textColor: textColor,
              ),
              _InfoRow(
                icon: LucideIcons.ruler,
                label: 'Height',
                value: profile?.height != null ? '${profile!.height} cm' : 'Not specified',
                textColor: textColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Faith & Religion Section
          _SectionCard(
            title: 'Faith & Religion',
            icon: LucideIcons.moon,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            children: [
              _InfoRow(
                icon: LucideIcons.users,
                label: 'Sect',
                value: _formatSect(profile?.sect),
                textColor: textColor,
              ),
              _InfoRow(
                icon: LucideIcons.star,
                label: 'Religious Level',
                value: _formatReligiousLevel(profile?.religiousLevel),
                textColor: textColor,
              ),
              _InfoRow(
                icon: LucideIcons.clock,
                label: 'Prayer Frequency',
                value: _formatPrayerFrequency(profile?.prayerFrequency),
                textColor: textColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bio Section
          if (profile?.bio?.isNotEmpty == true)
            _SectionCard(
              title: 'About Me',
              icon: LucideIcons.fileText,
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile!.bio!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),

          // Interests Section
          if (profile?.interests?.isNotEmpty == true)
            _SectionCard(
              title: 'Interests',
              icon: LucideIcons.heart,
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile!.interests!.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        Helpers.capitalizeFirst(interest),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          const SizedBox(height: 20),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.editProfile),
              icon: const Icon(LucideIcons.edit, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMaritalStatus(String? status) {
    switch (status) {
      case 'never_married':
        return 'Never Married';
      case 'divorced':
        return 'Divorced';
      case 'widowed':
        return 'Widowed';
      case 'married':
        return 'Married';
      default:
        return 'Not specified';
    }
  }

  String _formatEducation(String? education) {
    switch (education) {
      case 'high_school':
        return 'High School';
      case 'bachelors':
        return "Bachelor's";
      case 'masters':
        return "Master's";
      case 'phd':
        return 'PhD';
      case 'other':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  String _formatSect(String? sect) {
    switch (sect) {
      case 'sunni':
        return 'Sunni';
      case 'shia':
        return 'Shia';
      case 'ibadi':
        return 'Ibadi';
      case 'other':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  String _formatReligiousLevel(String? level) {
    switch (level) {
      case 'very_practicing':
        return 'Very Practicing';
      case 'practicing':
        return 'Practicing';
      case 'moderate':
        return 'Moderate';
      case 'liberal':
        return 'Liberal';
      default:
        return 'Not specified';
    }
  }

  String _formatPrayerFrequency(String? frequency) {
    switch (frequency) {
      case 'actively_practicing':
        return 'Actively Practicing';
      case 'occasionally':
        return 'Occasionally';
      case 'not_practicing':
        return 'Not Practicing';
      default:
        return 'Not specified';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color cardBg;
  final Color borderColor;
  final Color textColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.cardBg,
    required this.borderColor,
    required this.textColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: secondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w600,
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
