import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/signup_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FaithReligionScreen extends GetView<SignupController> {
  const FaithReligionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : const Color(0xFFFFF8F0);
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: back arrow + progress ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  _BackArrow(isDark: isDark),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => _ProgressBar(
                          progress: controller.progressPercent,
                        )),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    // Title
                    Text(
                      'faith_religion'.tr,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Religious Sect & Prayers side by side ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Religious Sect (radio buttons)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('☪️ ',
                                      style: TextStyle(fontSize: 14)),
                                  Text(
                                    'select_sect'.tr,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Obx(() => Column(
                                    children: [
                                      'Sunni',
                                      'Shia',
                                      'Just Muslim'
                                    ].map((sect) {
                                      final selected =
                                          controller.selectedSect.value ==
                                              sect;
                                      return GestureDetector(
                                        onTap: () => controller
                                            .selectedSect.value = sect,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                  bottom: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  shape:
                                                      BoxShape.circle,
                                                  border: Border.all(
                                                    color: selected
                                                        ? AppColors
                                                            .primary
                                                        : secondaryColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: selected
                                                    ? Center(
                                                        child:
                                                            Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                sect,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )),
                            ],
                          ),
                        ),

                        // Prayers (pill buttons)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('🤲 ',
                                      style: TextStyle(fontSize: 14)),
                                  Text(
                                    'prayer_frequency'.tr,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Obx(() => Column(
                                    children: [
                                      'Always',
                                      'Usually',
                                      'Sometimes',
                                      'Never'
                                    ].map((prayer) {
                                      final selected = controller
                                              .selectedPrayerFrequency
                                              .value ==
                                          prayer;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(
                                                bottom: 8),
                                        child: GestureDetector(
                                          onTap: () => controller
                                              .selectedPrayerFrequency
                                              .value = prayer,
                                          child: AnimatedContainer(
                                            duration:
                                                const Duration(
                                                    milliseconds:
                                                        200),
                                            width: double.infinity,
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    vertical: 10),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? AppColors.primary
                                                  : Colors
                                                      .transparent,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(20),
                                              border: Border.all(
                                                color: selected
                                                    ? AppColors
                                                        .primary
                                                    : (isDark
                                                        ? AppColors
                                                            .borderDark
                                                        : AppColors
                                                            .borderLight),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                prayer,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                  color: selected
                                                      ? Colors
                                                          .white
                                                      : textColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Marriage Timeline ──
                    Row(
                      children: [
                        Text('💍 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Marriage Timeline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Obx(() => Row(
                          children: [
                            '1-3 MONTHS',
                            '3-6 MONTHS',
                            'UP TO 1 YEAR'
                          ].map((timeline) {
                            final selected = controller
                                    .selectedMarriageTimeline.value ==
                                timeline;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => controller
                                    .selectedMarriageTimeline
                                    .value = timeline,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: timeline != 'UP TO 1 YEAR'
                                          ? 8
                                          : 0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.borderLight),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      timeline,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : secondaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )),

                    const SizedBox(height: 28),

                    // ── Lifestyle & Diet ──
                    Row(
                      children: [
                        Text('🍃 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Lifestyle & Diet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Halal Diet toggle
                    Obx(() => _ToggleRow(
                          label: 'Halal Diet',
                          subtitle: 'Strictly follows',
                          value: controller.halalDiet.value,
                          onChanged: (v) =>
                              controller.halalDiet.value = v,
                          isDark: isDark,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                        )),
                    const SizedBox(height: 12),

                    // Non-Smoker toggle
                    Obx(() => _ToggleRow(
                          label: 'Non-Smoker',
                          subtitle: 'No tobacco',
                          value: controller.nonSmoker.value,
                          onChanged: (v) =>
                              controller.nonSmoker.value = v,
                          isDark: isDark,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                        )),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom: Continue button ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.goToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'continue_text'.tr,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: secondaryColor)),
          ],
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: Colors.grey.shade200,
        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
      ),
    );
  }
}

// ─── Reusable back arrow ──────────────────────────────────────────────────
class _BackArrow extends StatelessWidget {
  final bool isDark;
  const _BackArrow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<SignupController>().goBack(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          LucideIcons.chevronLeft,
          size: 16,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
