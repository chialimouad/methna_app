import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:methna_app/app/controllers/signup_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddPhotosScreen extends GetView<SignupController> {
  const AddPhotosScreen({super.key});

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, imageQuality: 85);
    if (picked != null) {
      controller.addPhoto(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bgColor =
        isDark ? AppColors.backgroundDark : const Color(0xFFFFF8F0);
    final hintColor =
        isDark ? AppColors.textHintDark : AppColors.textHintLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Main photo upload area ──
                    Obx(() {
                      final hasMain =
                          controller.selectedPhotos.isNotEmpty;
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: borderColor, width: 1.5),
                          ),
                          child: hasMain
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(19),
                                      child: Image.file(
                                        controller.selectedPhotos[0],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.removePhoto(0),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration:
                                              const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              LucideIcons.x,
                                              color: Colors.white,
                                              size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.camera,
                                      size: 36,
                                      color: hintColor,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'main_photo'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors
                                                .textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'add_photos_subtitle'.tr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // ── 4 smaller photo slots (2x2 grid) ──
                    Obx(() => GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            // Photos index offset by 1 (main photo is index 0)
                            final photoIndex = index + 1;
                            final hasPhoto = photoIndex <
                                controller.selectedPhotos.length;

                            if (hasPhoto) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    child: Image.file(
                                      controller.selectedPhotos[
                                          photoIndex],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => controller
                                          .removePhoto(photoIndex),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration:
                                            const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            LucideIcons.x,
                                            color: Colors.white,
                                            size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            // Empty slot with + icon
                            return GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.cardDark
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.plus,
                                    size: 28,
                                    color: hintColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        )),

                    const SizedBox(height: 16),
                  ],
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
                      onPressed:
                          controller.selectedPhotos.isNotEmpty
                              ? controller.goToNextStep
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        disabledForegroundColor: Colors.white70,
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
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
