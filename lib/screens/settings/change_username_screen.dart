import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChangeUsernameScreen extends GetView<SettingsController> {
  const ChangeUsernameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final usernameController = TextEditingController(text: controller.username);
    final isValid = true.obs;
    final isFocused = false.obs;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
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
                    'change_username'.tr,
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
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

            const SizedBox(height: 32),

            // ── Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.atSign, size: 36, color: Colors.white),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    ),
                    const SizedBox(height: 24),
                    
                    Center(
                      child: Text(
                        'Choose Your Username',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Your username is how others will find you',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryColor,
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                    
                    const SizedBox(height: 32),

                    // Username input with animations
                    Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isFocused.value
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : Colors.grey.shade200),
                          width: isFocused.value ? 2 : 1,
                        ),
                        boxShadow: isFocused.value
                            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isFocused.value
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.user,
                              size: 20,
                              color: isFocused.value ? AppColors.primary : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Focus(
                              onFocusChange: (focused) => isFocused.value = focused,
                              child: TextField(
                                controller: usernameController,
                                onChanged: (val) {
                                  isValid.value = val.trim().length >= 3 && !val.contains(' ');
                                },
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter username',
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ),
                          Obx(() => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isValid.value && usernameController.text.trim().isNotEmpty
                                ? Icon(LucideIcons.checkCircle2, color: AppColors.emerald, size: 22)
                                    .animate(onPlay: (c) => c.forward())
                                    .scale(duration: 200.ms)
                                : const SizedBox(width: 22),
                          )),
                          const SizedBox(width: 16),
                        ],
                      ),
                    )).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 16),
                    
                    // Rules/hints
                    _buildHint(LucideIcons.info, 'At least 3 characters', secondaryColor)
                        .animate().fadeIn(delay: 250.ms, duration: 200.ms),
                    const SizedBox(height: 8),
                    _buildHint(LucideIcons.alertCircle, 'No spaces allowed', secondaryColor)
                        .animate().fadeIn(delay: 300.ms, duration: 200.ms),
                    const SizedBox(height: 8),
                    _buildHint(LucideIcons.clock, 'Limited changes per month', secondaryColor)
                        .animate().fadeIn(delay: 350.ms, duration: 200.ms),

                    const Spacer(),

                    // Save button with animation
                    Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: controller.isSavingUsername.value || !isValid.value
                              ? [Colors.grey.shade300, Colors.grey.shade400]
                              : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: !controller.isSavingUsername.value && isValid.value
                            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: (controller.isSavingUsername.value || !isValid.value)
                            ? null
                            : () async {
                                final success = await controller.changeUsername(
                                    usernameController.text);
                                if (success) Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: controller.isSavingUsername.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              ).animate(onPlay: (c) => c.repeat()).rotate(duration: const Duration(seconds: 1))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.check, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'save'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    )).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHint(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: color),
        ),
      ],
    );
  }
}
