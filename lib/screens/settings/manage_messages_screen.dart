import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';

import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManageMessagesScreen extends GetView<SettingsController> {
  const ManageMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final receiveDMs = controller.receiveDMs;
    final readReceipts = controller.readReceipts;
    final typingIndicator = controller.typingIndicator;
    final autoDownloadMedia = controller.autoDownloadMedia;

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
                    'chat_settings'.tr,
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

            const SizedBox(height: 24),

            // ── Content ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Receive Direct Messages
                  _ToggleSection(
                    title: 'receive_direct_messages'.tr,
                    subtitle: 'receive_direct_messages_desc'.tr,
                    rxValue: receiveDMs,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onChanged: (v) {
                      controller.updateChatSetting('receiveDMs', v);
                    },
                  ),

                  Divider(
                    height: 32,
                    color: isDark ? AppColors.dividerDark : Colors.grey.shade200,
                  ),

                  // Read Receipts
                  _ToggleSection(
                    title: 'read_receipts'.tr,
                    subtitle: 'read_receipts_desc'.tr,
                    rxValue: readReceipts,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onChanged: (v) {
                      controller.updateChatSetting('readReceipts', v);
                    },
                  ),

                  Divider(
                    height: 32,
                    color: isDark ? AppColors.dividerDark : Colors.grey.shade200,
                  ),

                  // Typing Indicator
                  _ToggleSection(
                    title: 'Typing Indicator', // using english fallback
                    subtitle: 'Show when you are typing a message',
                    rxValue: typingIndicator,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onChanged: (v) {
                      controller.updateChatSetting('typingIndicator', v);
                    },
                  ),

                  Divider(
                    height: 32,
                    color: isDark ? AppColors.dividerDark : Colors.grey.shade200,
                  ),

                  // Auto Download Media
                  _ToggleSection(
                    title: 'Auto-Download Media',
                    subtitle: 'Automatically download photos and voice messages when received',
                    rxValue: autoDownloadMedia,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onChanged: (v) {
                      controller.updateChatSetting('autoDownloadMedia', v);
                    },
                  ),

                  Divider(
                    height: 32,
                    color: isDark ? AppColors.dividerDark : Colors.grey.shade200,
                  ),

                  // Notification toggles for messages
                  _ToggleSection(
                    title: 'message_notifications'.tr,
                    subtitle: 'message_notifications_desc'.tr,
                    rxValue: RxBool(controller.notifSettings['newMessages'] ?? true),
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onChanged: (v) {
                      controller.updateNotifSetting('newMessages', v);
                    },
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
}

// ─── Toggle section ───────────────────────────────────────────────────────
class _ToggleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final RxBool rxValue;
  final Color textColor;
  final Color secondaryColor;
  final ValueChanged<bool>? onChanged;

  const _ToggleSection({
    required this.title,
    required this.subtitle,
    required this.rxValue,
    required this.textColor,
    required this.secondaryColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            Obx(() => Switch(
                  value: rxValue.value,
                  onChanged: (v) {
                    if (onChanged != null) {
                      onChanged!(v);
                    } else {
                      rxValue.value = v;
                    }
                  },
                  activeThumbColor: AppColors.primary,
                  activeTrackColor:
                      AppColors.primary.withValues(alpha: 0.4),
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: secondaryColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
