import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AccountSecurityScreen extends GetView<SettingsController> {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

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
                    'account_security'.tr,
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Remember me
                  _ToggleRow(
                    title: 'remember_me_toggle'.tr,
                    rxValue: controller.rememberMe,
                    onChanged: controller.toggleRememberMe,
                    textColor: textColor,
                  ),
                  _divider(isDark),

                  // Biometric ID
                  _ToggleRow(
                    title: 'biometric_id'.tr,
                    rxValue: controller.biometricId,
                    onChanged: controller.toggleBiometric,
                    textColor: textColor,
                  ),
                  _divider(isDark),

                  // Face ID
                  _ToggleRow(
                    title: 'face_id'.tr,
                    rxValue: controller.faceId,
                    onChanged: controller.toggleFaceId,
                    textColor: textColor,
                  ),
                  _divider(isDark),

                  // SMS Authenticator
                  _ToggleRow(
                    title: 'sms_authenticator'.tr,
                    rxValue: controller.smsAuth,
                    onChanged: controller.toggleSmsAuth,
                    textColor: textColor,
                  ),
                  _divider(isDark),

                  // Google Authenticator
                  _ToggleRow(
                    title: 'google_authenticator'.tr,
                    rxValue: controller.googleAuth,
                    onChanged: controller.toggleGoogleAuth,
                    textColor: textColor,
                  ),
                  _divider(isDark),

                  // Change Password
                  _ChevronRow(
                    title: 'change_password'.tr,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () => _showChangePasswordDialog(context, isDark),
                  ),
                  _divider(isDark),

                  // Device Management
                  _ChevronRow(
                    title: 'device_management'.tr,
                    subtitle: 'device_management_desc'.tr,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () => Get.snackbar(
                      'device_management'.tr,
                      'Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                  ),
                  _divider(isDark),

                  // Deactivate Account
                  _ChevronRow(
                    title: 'deactivate_account'.tr,
                    subtitle: 'deactivate_account_desc'.tr,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () => _showConfirm(
                      context,
                      'deactivate_account'.tr,
                      'deactivate_confirm'.tr,
                      'deactivate'.tr,
                      controller.deactivateAccount,
                    ),
                  ),
                  _divider(isDark),

                  // Delete Account
                  GestureDetector(
                    onTap: () => _showConfirm(
                      context,
                      'delete_account'.tr,
                      'delete_account_confirm'.tr,
                      'delete'.tr,
                      controller.deleteAccount,
                      isDestructive: true,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'delete_account'.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'delete_account_desc'.tr,
                            style: TextStyle(
                                fontSize: 12, color: secondaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
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

  void _showChangePasswordDialog(BuildContext context, bool isDark) {
    final oldPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    final obscureOld = true.obs;
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('change_password'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => TextField(
                    controller: oldPwCtrl,
                    obscureText: obscureOld.value,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld.value
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye),
                        onPressed: () => obscureOld.toggle(),
                      ),
                    ),
                  )),
              const SizedBox(height: 14),
              Obx(() => TextField(
                    controller: newPwCtrl,
                    obscureText: obscureNew.value,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew.value
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye),
                        onPressed: () => obscureNew.toggle(),
                      ),
                    ),
                  )),
              const SizedBox(height: 14),
              Obx(() => TextField(
                    controller: confirmPwCtrl,
                    obscureText: obscureConfirm.value,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm.value
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye),
                        onPressed: () => obscureConfirm.toggle(),
                      ),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          Obx(() => TextButton(
                onPressed: controller.isChangingPassword.value
                    ? null
                    : () async {
                        if (newPwCtrl.text != confirmPwCtrl.text) {
                          Get.snackbar('Error', 'Passwords do not match',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        final success = await controller.changePassword(
                            oldPwCtrl.text, newPwCtrl.text);
                        if (success) Get.back();
                      },
                child: controller.isChangingPassword.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('save'.tr,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
              )),
        ],
      ),
    );
  }

  void _showConfirm(BuildContext context, String title, String message,
      String action, VoidCallback onConfirm,
      {bool isDestructive = false}) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: Text(action,
                style: TextStyle(
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final String title;
  final RxBool rxValue;
  final ValueChanged<bool> onChanged;
  final Color textColor;

  const _ToggleRow({
    required this.title,
    required this.rxValue,
    required this.onChanged,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Obx(() => Switch(
                value: rxValue.value,
                onChanged: onChanged,
                activeThumbColor: AppColors.primary,
                activeTrackColor:
                    AppColors.primary.withValues(alpha: 0.4),
              )),
        ],
      ),
    );
  }
}

// ─── Chevron row ──────────────────────────────────────────────────────────
class _ChevronRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _ChevronRow({
    required this.title,
    this.subtitle,
    required this.textColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                          fontSize: 12, color: secondaryColor),
                    ),
                  ],
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
