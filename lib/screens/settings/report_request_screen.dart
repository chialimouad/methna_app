import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';

class ReportRequestScreen extends GetView<SettingsController> {
  const ReportRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA);
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final selectedType = 'feedback'.obs;
    final textController = TextEditingController();
    final isSubmitting = false.obs;

    final types = [
      {'id': 'feedback', 'title': 'General Feedback', 'icon': LucideIcons.messageSquare},
      {'id': 'bug', 'title': 'Report a Bug', 'icon': LucideIcons.bug},
      {'id': 'suggestion', 'title': 'Feature Suggestion', 'icon': LucideIcons.lightbulb},
    ];

    void submit() async {
      if (textController.text.trim().isEmpty) {
        Helpers.showSnackbar(message: 'Please enter a description', isError: true);
        return;
      }
      isSubmitting.value = true;
      final success = await controller.submitFeedback(
        selectedType.value,
        textController.text.trim(),
      );
      isSubmitting.value = false;
      if (success) {
        Get.back();
      }
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.chevronLeft, size: 16, color: textColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Report / Request',
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
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'How can we help?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a category and describe your issue or suggestion below.',
                    style: TextStyle(fontSize: 14, color: secondaryColor),
                  ),
                  const SizedBox(height: 24),

                  // Category Selector
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: List.generate(types.length, (index) {
                        final type = types[index];
                        return Obx(() => InkWell(
                          onTap: () => selectedType.value = type['id'] as String,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: index < types.length - 1
                                  ? Border(bottom: BorderSide(color: borderColor))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(type['icon'] as IconData, size: 20, color: selectedType.value == type['id'] ? AppColors.primary : secondaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    type['title'] as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: selectedType.value == type['id'] ? FontWeight.w700 : FontWeight.w500,
                                      color: selectedType.value == type['id'] ? textColor : secondaryColor,
                                    ),
                                  ),
                                ),
                                if (selectedType.value == type['id'])
                                  const Icon(LucideIcons.checkCircle2, color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        ));
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: textController,
                      maxLines: 6,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Please provide detailed information...',
                        hintStyle: TextStyle(color: secondaryColor.withValues(alpha: 0.5)),
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSubmitting.value ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: isSubmitting.value
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
