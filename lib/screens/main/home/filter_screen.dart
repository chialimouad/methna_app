import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/home_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/data/services/monetization_service.dart';
import 'package:methna_app/screens/settings/subscription_screen.dart';

class FilterScreen extends GetView<HomeController> {
  const FilterScreen({super.key});

  static const _purple = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : const Color(0xFFFFFBF7);
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    // useKm now lives in controller — no local var needed

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.fetchDiscoverUsers();
                      Get.back();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.chevronLeft,
                          size: 16, color: textColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Discovery Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Content ──
            Expanded(
              child: Obx(() => ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Location row
                      _SettingRow(
                        title: 'Location',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Change',
                              style: TextStyle(
                                  fontSize: 14, color: secondaryColor),
                            ),
                            const SizedBox(width: 4),
                            Icon(LucideIcons.chevronRight,
                                size: 20, color: secondaryColor),
                          ],
                        ),
                        subtitle:
                            'Change your location to find nearby members in other cities.',
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Change Location'),
                              content: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter city name...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.snackbar('Success', 'Location updated');
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      _divider(isDark),

                      // Go Global
                      _SettingRow(
                        title: 'Go Global',
                        trailing: Obx(() => Switch(
                              value: controller.goGlobalFilter.value,
                              onChanged: (v) =>
                                  controller.goGlobalFilter.value = v,
                              activeThumbColor: _purple,
                            )),
                        subtitle:
                            'Going global will allow you to see people from all over the world.',
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                      ),

                      _divider(isDark),

                      // Show Me
                      _SettingRow(
                        title: 'Show Me',
                        trailing: Text(
                          _genderLabel(controller.genderFilter.value),
                          style: TextStyle(
                              fontSize: 14, color: secondaryColor),
                        ),
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: () => _showGenderPicker(context, isDark),
                      ),

                      _divider(isDark),

                      // Show Distances In
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Show Distances in',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(() => Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : Colors.grey.shade200,
                                    borderRadius:
                                        BorderRadius.circular(22),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              controller.useKm.value = true,
                                          child: Container(
                                            alignment:
                                                Alignment.center,
                                            decoration: BoxDecoration(
                                              color: controller.useKm.value
                                                  ? _purple
                                                  : Colors
                                                      .transparent,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(22),
                                            ),
                                            child: Text(
                                              'Km',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: controller.useKm.value
                                                    ? Colors.white
                                                    : secondaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              controller.useKm.value = false,
                                          child: Container(
                                            alignment:
                                                Alignment.center,
                                            decoration: BoxDecoration(
                                              color: !controller.useKm.value
                                                  ? _purple
                                                  : Colors
                                                      .transparent,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(22),
                                            ),
                                            child: Text(
                                              'Mi',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: !controller.useKm.value
                                                    ? Colors.white
                                                    : secondaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      _divider(isDark),

                      // Distance Range
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Distance Range',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '${controller.maxDistance.value.round()} ${controller.useKm.value ? "km" : "mi"}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: _purple,
                                inactiveTrackColor:
                                    _purple.withValues(alpha: 0.15),
                                thumbColor: _purple,
                                overlayColor:
                                    _purple.withValues(alpha: 0.1),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value:
                                    controller.maxDistance.value,
                                min: 1,
                                max: 200,
                                onChanged: (v) =>
                                    controller.maxDistance.value = v,
                              ),
                            ),
                            Text(
                              'Set the maximum distance for potential matches.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryColor),
                            ),
                          ],
                        ),
                      ),

                      _divider(isDark),

                      // Age Range
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Age Range',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '${controller.minAge.value} - ${controller.maxAge.value}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: _purple,
                                inactiveTrackColor:
                                    _purple.withValues(alpha: 0.15),
                                thumbColor: _purple,
                                overlayColor:
                                    _purple.withValues(alpha: 0.1),
                                trackHeight: 4,
                              ),
                              child: RangeSlider(
                                values: RangeValues(
                                  controller.minAge.value
                                      .toDouble(),
                                  controller.maxAge.value
                                      .toDouble(),
                                ),
                                min: 18,
                                max: 70,
                                onChanged: (values) {
                                  controller.minAge.value =
                                      values.start.round();
                                  controller.maxAge.value =
                                      values.end.round();
                                },
                              ),
                            ),
                            Text(
                              'Define the preferred age range for potential matches.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryColor),
                            ),
                          ],
                        ),
                      ),

                      _buildAdvancedFilters(context, isDark, textColor, secondaryColor),

                      const SizedBox(height: 24),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.saveFilters();
                            controller.fetchDiscoverUsers();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Reset button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: () {
                            controller.genderFilter.value = 'all';
                            controller.minAge.value = 18;
                            controller.maxAge.value = 45;
                            controller.maxDistance.value = 50;
                            controller.educationFilter.value = '';
                            controller.religiousLevelFilter.value = '';
                            controller.prayerFrequencyFilter.value = '';
                            controller.marriageIntentionFilter.value = '';
                            controller.livingSituationFilter.value = '';
                            controller.interestsFilter.clear();
                            controller.verifiedOnlyFilter.value = false;
                            controller.goGlobalFilter.value = false;
                          },
                          child: Text('Reset All Filters', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w600)),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? AppColors.dividerDark : Colors.grey.shade200,
    );
  }

  String _genderLabel(String value) {
    switch (value) {
      case 'male':
        return 'Men';
      case 'female':
        return 'Women';
      default:
        return 'Everyone';
    }
  }

  static const _allInterests = [
    'Travel', 'Reading', 'Cooking', 'Fitness', 'Photography', 'Music',
    'Movies', 'Art', 'Gaming', 'Hiking', 'Swimming', 'Yoga', 'Fashion',
    'Technology', 'Writing', 'Dancing', 'Volunteering', 'Sports',
    'Coffee', 'Nature', 'Pets', 'Cars', 'Gardening', 'DIY',
  ];

  String _educationLabel(String value) {
    switch (value) {
      case 'high_school': return 'High School';
      case 'bachelors': return "Bachelor's";
      case 'masters': return "Master's";
      case 'phd': return 'PhD';
      case 'other': return 'Other';
      default: return 'Any';
    }
  }

  String _religiousLabel(String value) {
    switch (value) {
      case 'very_religious': return 'Very Religious';
      case 'religious': return 'Religious';
      case 'moderate': return 'Moderate';
      case 'not_religious': return 'Not Religious';
      default: return 'Any';
    }
  }

  String _prayerLabel(String value) {
    switch (value) {
      case 'actively_practicing': return 'Actively Practicing';
      case 'occasionally': return 'Occasionally';
      case 'not_practicing': return 'Not Practicing';
      default: return 'Any';
    }
  }

  String _intentionLabel(String value) {
    switch (value) {
      case 'within_months': return 'Within Months';
      case 'within_year': return 'Within a Year';
      case 'one_to_two_years': return '1-2 Years';
      case 'not_sure': return 'Not Sure';
      case 'just_exploring': return 'Just Exploring';
      default: return 'Any';
    }
  }

  String _livingSituationLabel(String value) {
    switch (value) {
      case 'alone': return 'Alone';
      case 'with_family': return 'With Family';
      case 'with_roommates': return 'With Roommates';
      case 'with_spouse': return 'With Spouse';
      default: return 'Any';
    }
  }

  void _showOptionPicker(
    BuildContext context,
    bool isDark,
    String title, {
    required List<String> options,
    required List<String> labels,
    required String current,
    required ValueChanged<String> onSelect,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...List.generate(options.length, (i) {
              return ListTile(
                title: Text(labels[i]),
                trailing: current == options[i]
                    ? const Icon(LucideIcons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onSelect(options[i]);
                  Get.back();
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Show Me',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...['all', 'male', 'female'].map((v) {
              return Obx(() => ListTile(
                    title: Text(_genderLabel(v)),
                    trailing: controller.genderFilter.value == v
                        ? const Icon(LucideIcons.check,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      controller.genderFilter.value = v;
                      Get.back();
                    },
                  ));
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters(BuildContext context, bool isDark, Color textColor, Color secondaryColor) {
    final monetization = Get.find<MonetizationService>();
    
    return Obx(() {
      final hasAdvanced = monetization.hasFeature('advanced_filters');
      
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _divider(isDark),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const Icon(LucideIcons.sparkles, color: AppColors.premium, size: 20),
                const SizedBox(width: 8),
                Text('Advanced Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: hasAdvanced ? textColor : AppColors.premium)),
              ],
            ),
          ),
          
          _SettingRow(
            title: 'Education',
            trailing: Text(
              _educationLabel(controller.educationFilter.value),
              style: TextStyle(fontSize: 14, color: secondaryColor),
            ),
            textColor: textColor,
            secondaryColor: secondaryColor,
            onTap: hasAdvanced ? () => _showOptionPicker(
              context, isDark, 'Education',
              options: ['', 'high_school', 'bachelors', 'masters', 'phd', 'other'],
              labels: ['Any', 'High School', "Bachelor's", "Master's", 'PhD', 'Other'],
              current: controller.educationFilter.value,
              onSelect: (v) => controller.educationFilter.value = v,
            ) : null,
          ),
          _divider(isDark),
          _SettingRow(
            title: 'Religious Level',
            trailing: Text(
              _religiousLabel(controller.religiousLevelFilter.value),
              style: TextStyle(fontSize: 14, color: secondaryColor),
            ),
            textColor: textColor,
            secondaryColor: secondaryColor,
            onTap: hasAdvanced ? () => _showOptionPicker(
              context, isDark, 'Religious Level',
              options: ['', 'very_religious', 'religious', 'moderate', 'not_religious'],
              labels: ['Any', 'Very Religious', 'Religious', 'Moderate', 'Not Religious'],
              current: controller.religiousLevelFilter.value,
              onSelect: (v) => controller.religiousLevelFilter.value = v,
            ) : null,
          ),
          _divider(isDark),
          _SettingRow(
            title: 'Prayer Level',
            trailing: Text(
              _prayerLabel(controller.prayerFrequencyFilter.value),
              style: TextStyle(fontSize: 14, color: secondaryColor),
            ),
            textColor: textColor,
            secondaryColor: secondaryColor,
            onTap: hasAdvanced ? () => _showOptionPicker(
              context, isDark, 'Prayer Level',
              options: ['', 'actively_practicing', 'occasionally', 'not_practicing'],
              labels: ['Any', 'Actively Practicing', 'Occasionally', 'Not Practicing'],
              current: controller.prayerFrequencyFilter.value,
              onSelect: (v) => controller.prayerFrequencyFilter.value = v,
            ) : null,
          ),
          _divider(isDark),
          _SettingRow(
            title: 'Marriage Intention',
            trailing: Text(
              _intentionLabel(controller.marriageIntentionFilter.value),
              style: TextStyle(fontSize: 14, color: secondaryColor),
            ),
            textColor: textColor,
            secondaryColor: secondaryColor,
            onTap: hasAdvanced ? () => _showOptionPicker(
              context, isDark, 'Marriage Intention',
              options: ['', 'within_months', 'within_year', 'one_to_two_years', 'not_sure', 'just_exploring'],
              labels: ['Any', 'Within Months', 'Within a Year', '1-2 Years', 'Not Sure', 'Just Exploring'],
              current: controller.marriageIntentionFilter.value,
              onSelect: (v) => controller.marriageIntentionFilter.value = v,
            ) : null,
          ),
          _divider(isDark),
          _SettingRow(
            title: 'Living Situation',
            trailing: Text(
              _livingSituationLabel(controller.livingSituationFilter.value),
              style: TextStyle(fontSize: 14, color: secondaryColor),
            ),
            textColor: textColor,
            secondaryColor: secondaryColor,
            onTap: hasAdvanced ? () => _showOptionPicker(
              context, isDark, 'Living Situation',
              options: ['', 'alone', 'with_family', 'with_roommates', 'with_spouse'],
              labels: ['Any', 'Alone', 'With Family', 'With Roommates', 'With Spouse'],
              current: controller.livingSituationFilter.value,
              onSelect: (v) => controller.livingSituationFilter.value = v,
            ) : null,
          ),
          _divider(isDark),
          _SettingRow(
            title: 'Verified Only',
            trailing: Switch(
              value: controller.verifiedOnlyFilter.value,
              onChanged: hasAdvanced ? (v) => controller.verifiedOnlyFilter.value = v : null,
              activeThumbColor: _purple,
            ),
            subtitle: 'Only show profiles that have completed selfie verification.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),
          _divider(isDark),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Interests',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    Text(
                      controller.interestsFilter.isEmpty ? 'Any' : '${controller.interestsFilter.length} selected',
                      style: TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Filter by shared interests.', style: TextStyle(fontSize: 12, color: secondaryColor)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _allInterests.map((interest) {
                    final selected = controller.interestsFilter.contains(interest);
                    return GestureDetector(
                      onTap: hasAdvanced ? () {
                        if (selected) {
                          controller.interestsFilter.remove(interest);
                        } else {
                          controller.interestsFilter.add(interest);
                        }
                      } : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? _purple.withValues(alpha: 0.12) : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? _purple : Colors.transparent, width: 1.5),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? _purple : secondaryColor),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      );

      if (hasAdvanced) return content;

      return Container(
        margin: const EdgeInsets.only(top: 16),
        child: Stack(
          children: [
            Opacity(opacity: 0.3, child: IgnorePointer(child: content)),
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.premium.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.lock, color: AppColors.premium, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text('Unlock Advanced Filters', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                          const SizedBox(height: 8),
                          Text('Find your perfect match with education, religion, and interests filters.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: secondaryColor)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Get.to(() => const SubscriptionScreen()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.premium,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Setting row ──────────────────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final String? subtitle;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.title,
    this.trailing,
    this.subtitle,
    required this.textColor,
    required this.secondaryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                ?trailing,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: secondaryColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
