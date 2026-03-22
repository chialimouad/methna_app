import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/reset_password_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final hintColor = isDark ? AppColors.textHintDark : AppColors.textHintLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Back arrow
                      _BackArrow(isDark: isDark),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'create_new_password'.tr,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'create_password_body'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryColor,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── New Password ──
                      Text(
                        'new_password'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => TextFormField(
                            controller: controller.newPasswordController,
                            obscureText: controller.obscureNew.value,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'please_enter_password'.tr;
                              }
                              if (v.length < 8) {
                                return 'password_min_length'.tr;
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              hintText: 'new_password'.tr,
                              hintStyle:
                                  TextStyle(color: hintColor, fontSize: 15),
                              prefixIcon: Icon(LucideIcons.lock,
                                  size: 20, color: hintColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureNew.value
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  size: 20,
                                  color: hintColor,
                                ),
                                onPressed: controller.toggleNewVisibility,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.error),
                              ),
                              focusedErrorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.error, width: 2),
                              ),
                            ),
                          )),

                      const SizedBox(height: 24),

                      // ── Confirm New Password ──
                      Text(
                        'confirm_new_password'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => TextFormField(
                            controller: controller.confirmPasswordController,
                            obscureText: controller.obscureConfirm.value,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'confirm_password_required'.tr;
                              }
                              if (v != controller.newPasswordController.text) {
                                return 'passwords_no_match'.tr;
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              hintText: 'confirm_new_password'.tr,
                              hintStyle:
                                  TextStyle(color: hintColor, fontSize: 15),
                              prefixIcon: Icon(LucideIcons.lock,
                                  size: 20, color: hintColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureConfirm.value
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  size: 20,
                                  color: hintColor,
                                ),
                                onPressed: controller.toggleConfirmVisibility,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.error),
                              ),
                              focusedErrorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.error, width: 2),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom: Continue button ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'save_new_password'.tr,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  )),
            ),
          ],
        ),
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
      onTap: () => Get.back(),
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
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
