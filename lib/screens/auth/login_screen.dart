import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/login_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/validators.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

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
                        'welcome_back'.tr,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'login_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryColor,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 36),

                      Text(
                        'Email or Username',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: Validators.loginIdentifier,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email or username',
                          hintStyle: TextStyle(color: hintColor, fontSize: 15),
                          prefixIcon: Icon(LucideIcons.mail,
                              size: 20, color: hintColor),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.primary, width: 2),
                          ),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.error),
                          ),
                          focusedErrorBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.error, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Password field ──
                      Text(
                        'password'.tr,
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
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            validator: Validators.password,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              hintText: 'password_hint'.tr,
                              hintStyle:
                                  TextStyle(color: hintColor, fontSize: 15),
                              prefixIcon: Icon(LucideIcons.lock,
                                  size: 20, color: hintColor),
                              suffixIcon: GestureDetector(
                                onTap: controller.togglePasswordVisibility,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    controller.obscurePassword.value
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                    size: 20,
                                    color: hintColor,
                                  ),
                                ),
                              ),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
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

                      const SizedBox(height: 16),

                      // ── Remember me + Forgot password row ──
                      Row(
                        children: [
                          // Remember me
                          Obx(() => SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: controller.rememberMe.value,
                                  onChanged: (v) =>
                                      controller.rememberMe.value =
                                          v ?? false,
                                  fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.primary : null),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                      color: borderColor, width: 1.5),
                                ),
                              )),
                          const SizedBox(width: 8),
                          Text(
                            'remember_me'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: controller.goToForgotPassword,
                            child: Text(
                              'forgot_password'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // ── Don't have an account? Sign up ──
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'no_account'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.goToSignUp,
                              child: Text(
                                'sign_up'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom: Log in button ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
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
                              'login'.tr,
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
