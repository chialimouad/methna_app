import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/otp_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top section: header + digits ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Back arrow
                    _BackArrow(isDark: isDark),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      'otp_verification'.tr,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle with masked email
                    Text(
                      '${'otp_body_prefix'.tr}${_maskEmail(controller.email)}${'otp_body_suffix'.tr}',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── OTP digit boxes ──
                    Obx(() {
                      final code = controller.otpText.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (i) {
                          final char = i < code.length ? code[i] : '';
                          final isActive = i == code.length;
                          return Container(
                            width: 48,
                            height: 56,
                            margin: EdgeInsets.only(
                                right: i < 5 ? 10 : 0),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primary
                                    : char.isNotEmpty
                                        ? AppColors.primary
                                            .withValues(alpha: 0.4)
                                        : (isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight),
                                width: isActive ? 2 : 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              char,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          );
                        }),
                      );
                    }),

                    const SizedBox(height: 28),

                    // Didn't receive + resend
                    Center(
                      child: Obx(() => Column(
                            children: [
                              GestureDetector(
                                onTap: controller.canResend.value
                                    ? controller.resendCode
                                    : null,
                                child: Text(
                                  'didnt_receive_email'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: controller.canResend.value
                                        ? AppColors.primary
                                        : secondaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!controller.canResend.value)
                                RichText(
                                  text: TextSpan(
                                    text: 'resend_code_in'.tr,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: secondaryColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${controller.countdown.value} s',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),

            // ── Custom number pad ──
            _NumberPad(
              controller: controller,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final masked = name.length > 2
        ? '${name.substring(0, 2)}${'*' * (name.length - 2)}'
        : name;
    return '$masked@${parts[1]}';
  }
}

// ─── Custom number pad ─────────────────────────────────────────────────────
class _NumberPad extends StatelessWidget {
  final OtpController controller;
  final bool isDark;

  const _NumberPad({required this.controller, required this.isDark});

  void _onDigit(String digit) {
    if (controller.otpController.text.length < 6) {
      controller.otpController.text += digit;
      controller.otpController.selection = TextSelection.collapsed(
          offset: controller.otpController.text.length);
      // Auto-verify when complete
      if (controller.otpController.text.length == 6) {
        controller.verifyOtp();
      }
    }
  }

  void _onDelete() {
    final text = controller.otpController.text;
    if (text.isNotEmpty) {
      controller.otpController.text = text.substring(0, text.length - 1);
      controller.otpController.selection = TextSelection.collapsed(
          offset: controller.otpController.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          _buildRow(['1', '2', '3'], textColor),
          const SizedBox(height: 8),
          // Row 2: 4, 5, 6
          _buildRow(['4', '5', '6'], textColor),
          const SizedBox(height: 8),
          // Row 3: 7, 8, 9
          _buildRow(['7', '8', '9'], textColor),
          const SizedBox(height: 8),
          // Row 4: *, 0, backspace
          Row(
            children: [
              _buildKey('*', textColor, enabled: false),
              const SizedBox(width: 8),
              _buildKey('0', textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onDelete,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.delete,
                        size: 22,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits, Color textColor) {
    return Row(
      children: digits.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < 2 ? 8 : 0),
            child: _buildKey(e.value, textColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String digit, Color textColor, {bool enabled = true}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => _onDigit(digit) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Text(
              digit == '*' ? '' : digit,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: enabled ? textColor : Colors.transparent,
              ),
            ),
          ),
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
