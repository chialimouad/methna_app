import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditProfileImagesScreen extends GetView<ProfileController> {
  const EditProfileImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Photos', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {
              // Save photos order/changes
              Get.back();
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: Obx(() {
        final photos = controller.user.value?.photos ?? [];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Drag to reorder. First photo is your main profile picture. Add up to 6 photos.',
                      style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main photo (large)
            const Text('Main Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showPhotoOptions(context, 0),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: photos.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(imageUrl: photos.first.url, fit: BoxFit.cover),
                            // Gradient
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12, left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                                child: const Text('MAIN', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                              ),
                            ),
                            Positioned(
                              bottom: 12, right: 12,
                              child: Row(
                                children: [
                                  _MiniAction(icon: LucideIcons.pencil, onTap: () => _showPhotoOptions(context, 0)),
                                  const SizedBox(width: 8),
                                  _MiniAction(icon: LucideIcons.crop, onTap: () {}),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.camera, size: 48, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
                          const SizedBox(height: 8),
                          Text('Add Main Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textHintDark : AppColors.textHintLight)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Additional photos grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Additional Photos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('${photos.length > 1 ? photos.length - 1 : 0}/5',
                    style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 5,
              itemBuilder: (context, index) {
                final photoIndex = index + 1;
                final hasPhoto = photoIndex < photos.length;

                if (hasPhoto) {
                  return GestureDetector(
                    onTap: () => _showPhotoOptions(context, photoIndex),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(imageUrl: photos[photoIndex].url, fit: BoxFit.cover),
                          Positioned(
                            top: 6, right: 6,
                            child: GestureDetector(
                              onTap: () => _confirmDelete(context, photoIndex),
                              child: Container(
                                width: 28, height: 28,
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(LucideIcons.x, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6, left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                              child: Text('${photoIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, style: BorderStyle.solid, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.plus, size: 28, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
                        const SizedBox(height: 4),
                        Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textHintDark : AppColors.textHintLight)),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Photo tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.lightbulb, color: AppColors.premium, size: 20),
                      SizedBox(width: 8),
                      Text('Photo Tips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TipRow(text: 'Use a clear face photo as your main picture'),
                  _TipRow(text: 'Add photos showing your hobbies and interests'),
                  _TipRow(text: 'Avoid group photos or photos with sunglasses'),
                  _TipRow(text: 'Use recent photos (within last 6 months)'),
                  _TipRow(text: 'Good lighting makes a big difference'),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }

  void _showPhotoOptions(BuildContext context, int index) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            _OptionTile(icon: LucideIcons.camera, title: 'Take Photo', color: AppColors.primary, onTap: () { Get.back(); _pickFromCamera(); }),
            _OptionTile(icon: LucideIcons.image, title: 'Choose from Gallery', color: AppColors.info, onTap: () { Get.back(); _pickImage(context); }),
            if (index > 0)
              _OptionTile(icon: LucideIcons.star, title: 'Set as Main Photo', color: AppColors.premium, onTap: () {
                Get.back();
                final photos = controller.user.value?.photos ?? [];
                if (index < photos.length) {
                  controller.setMainPhoto(photos[index].id);
                }
              }),
            _OptionTile(icon: LucideIcons.trash, title: 'Delete Photo', color: AppColors.error, onTap: () { Get.back(); _confirmDelete(context, index); }),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1080, imageQuality: 85);
    if (picked != null) {
      final photos = controller.user.value?.photos ?? [];
      await controller.uploadPhoto(File(picked.path), isMain: photos.isEmpty);
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 1080, imageQuality: 85);
    if (picked != null) {
      final photos = controller.user.value?.photos ?? [];
      await controller.uploadPhoto(File(picked.path), isMain: photos.isEmpty);
    }
  }

  void _confirmDelete(BuildContext context, int index) {
    final photos = controller.user.value?.photos ?? [];
    if (index >= photos.length) return;
    final photoId = photos[index].id;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Photo', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to remove this photo?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePhoto(photoId);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.checkCircle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3))),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color == AppColors.error ? AppColors.error : null)),
    );
  }
}
