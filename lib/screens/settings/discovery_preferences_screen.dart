import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/home_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DiscoveryPreferencesScreen extends StatelessWidget {
  const DiscoveryPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('discovery_preferences'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Interested In
              _SectionTitle(title: 'interested_in'.tr, isDark: isDark),
              const SizedBox(height: 12),
              _SelectionGroup(
                options: ['everyone'.tr, 'men'.tr, 'women'.tr],
                selected: controller.genderFilter.value == 'all'
                    ? 'everyone'.tr
                    : controller.genderFilter.value == 'male'
                        ? 'men'.tr
                        : 'women'.tr,
                onSelect: (v) {
                  controller.genderFilter.value = v == 'everyone'.tr ? 'all' : v == 'men'.tr ? 'male' : 'female';
                },
                isDark: isDark,
              ),

              const SizedBox(height: 28),

              // Age Range
              _SectionTitle(
                title: 'age_range'.tr,
                subtitle: '${controller.minAge.value} - ${controller.maxAge.value} years',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: RangeValues(controller.minAge.value.toDouble(), controller.maxAge.value.toDouble()),
                min: 18,
                max: 70,
                divisions: 52,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withValues(alpha: 0.15),
                labels: RangeLabels('${controller.minAge.value}', '${controller.maxAge.value}'),
                onChanged: (v) {
                  controller.minAge.value = v.start.round();
                  controller.maxAge.value = v.end.round();
                },
              ),

              const SizedBox(height: 28),

              // Maximum Distance
              _SectionTitle(
                title: 'max_distance'.tr,
                subtitle: '${controller.maxDistance.value.round()} km',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              Slider(
                value: controller.maxDistance.value,
                min: 1,
                max: 200,
                divisions: 199,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withValues(alpha: 0.15),
                label: '${controller.maxDistance.value.round()} km',
                onChanged: (v) => controller.maxDistance.value = v,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 km', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textHintDark : AppColors.textHintLight)),
                  Text('200 km', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textHintDark : AppColors.textHintLight)),
                ],
              ),

              const SizedBox(height: 28),

              // Religion Preference
              _SectionTitle(title: 'religion_preference'.tr, isDark: isDark),
              const SizedBox(height: 12),
              _SelectionGroup(
                options: ['any'.tr, 'sunni'.tr, 'shia'.tr, 'ibadi'.tr],
                selected: 'any'.tr,
                onSelect: (_) {},
                isDark: isDark,
              ),

              const SizedBox(height: 28),

              // Marital Status Preference
              _SectionTitle(title: 'marital_status'.tr, isDark: isDark),
              const SizedBox(height: 12),
              _SelectionGroup(
                options: ['any'.tr, 'single'.tr, 'divorced'.tr, 'widowed'.tr],
                selected: 'any'.tr,
                onSelect: (_) {},
                isDark: isDark,
              ),

              const SizedBox(height: 28),

              // Education Preference
              _SectionTitle(title: 'education'.tr, isDark: isDark),
              const SizedBox(height: 12),
              _SelectionGroup(
                options: ['any'.tr, 'High School', 'Bachelor', 'Master', 'PhD'],
                selected: 'any'.tr,
                onSelect: (_) {},
                isDark: isDark,
              ),

              const SizedBox(height: 28),

              // Only show verified profiles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.verified.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.badgeCheck, color: AppColors.verified, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('verified_profiles_only'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('only_verified_desc'.tr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: false,
                      onChanged: (_) {},
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Only show online
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.online.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.circle, color: AppColors.online, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('online_users_only'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('only_online_desc'.tr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: false,
                      onChanged: (_) {},
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Apply
              ElevatedButton(
                onPressed: () {
                  controller.saveFilters();
                  controller.fetchDiscoverUsers();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('apply_preferences'.tr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),

              const SizedBox(height: 20),
            ],
          )),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDark;
  const _SectionTitle({required this.title, this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        if (subtitle != null)
          Text(subtitle!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ],
    );
  }
}

class _SelectionGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isDark;
  const _SelectionGroup({required this.options, required this.selected, required this.onSelect, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((o) {
        final isSelected = o == selected;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.cardDark : AppColors.dividerLight),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1.5),
            ),
            child: Text(o, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : null)),
          ),
        );
      }).toList(),
    );
  }
}
