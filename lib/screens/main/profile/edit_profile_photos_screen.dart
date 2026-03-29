import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/utils/cloudinary_url.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Profile Photos Editing Screen
/// Comprehensive photo management with drag-and-drop reordering, cropping, and verification
class EditProfilePhotosScreen extends StatefulWidget {
  const EditProfilePhotosScreen({super.key});

  @override
  State<EditProfilePhotosScreen> createState() => _EditProfilePhotosScreenState();
}

class _EditProfilePhotosScreenState extends State<EditProfilePhotosScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Mix of PhotoModel (from backend) and File (newly picked)
  List<dynamic> _photos = [];
  bool _isUploading = false;
  
  @override
  void initState() {
    super.initState();
    _loadExistingPhotos();
  }

  void _loadExistingPhotos() {
    final user = controller.user.value;
    if (user?.photos != null) {
      // Sort by order and set to state
      final existingPhotos = List<dynamic>.from(user!.photos!);
      existingPhotos.sort((a, b) => (a as PhotoModel).order.compareTo((b as PhotoModel).order));
      setState(() {
        _photos = existingPhotos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Photos',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          _InstructionsCard(textColor: textColor, cardBg: cardBg),
          
          const SizedBox(height: 20),
          
          // Photos grid
          Expanded(
            child: _PhotosGrid(
              photos: _photos,
              onPhotoTap: _showPhotoOptions,
              onAddPhoto: _addPhoto,
              onReorder: _reorderPhotos,
              textColor: textColor,
              cardBg: cardBg,
              borderColor: borderColor,
            ),
          ),
          
          // Bottom actions
          _BottomActions(
            onAddMore: _addPhoto,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 85,
      );
      
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          if (_photos.length < 6) {
            _photos.add(file);
          } else {
            Get.snackbar('Limit Reached', 'You can only have up to 6 photos');
          }
        });
      }
    } catch (e) {
      debugPrint('[EditPhotos] Error adding photo: $e');
      Get.snackbar('Error', 'Failed to add photo');
    }
  }

  void _showPhotoOptions(int index) {
    if (index >= _photos.length) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoOptionsBottomSheet(
        photoIndex: index,
        isMainPhoto: index == 0,
        onSetAsMain: () => _setAsMainPhoto(index),
        onDelete: () => _deletePhoto(index),
        onView: () => _viewPhoto(index),
        onEdit: () {}, // Temporary empty callback
      ),
    );
  }

  void _setAsMainPhoto(int index) {
    if (index < _photos.length) {
      setState(() {
        final photo = _photos.removeAt(index);
        _photos.insert(0, photo);
      });
      Get.back();
    }
  }

  void _deletePhoto(int index) {
    if (index < _photos.length) {
      setState(() {
        _photos.removeAt(index);
      });
      Get.back();
    }
  }

  void _viewPhoto(int index) {
    // Basic view logic
    Get.back();
  }

  void _reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex < _photos.length && newIndex < _photos.length) {
      setState(() {
        final photo = _photos.removeAt(oldIndex);
        _photos.insert(newIndex, photo);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_isUploading) return;
    
    setState(() => _isUploading = true);
    
    try {
      final initialPhotos = controller.user.value?.photos ?? [];
      final currentPhotos = _photos;
      
      // 1. Identify deleted photos
      for (var initial in initialPhotos) {
        bool stillExists = currentPhotos.any((p) => p is PhotoModel && p.id == initial.id);
        if (!stillExists) {
          await controller.deletePhoto(initial.id, refresh: false);
        }
      }
      
      // 2. Identify and upload new photos
      for (int i = 0; i < currentPhotos.length; i++) {
        final item = currentPhotos[i];
        if (item is File) {
          await controller.uploadPhoto(item, refresh: false);
        }
      }
      
      // 3. Refresh profile to get new PhotoModels from backend
      await controller.refreshProfile();
      final updatedUser = controller.user.value;
      
      // 4. Determine which photo ID should be main (the one at index 0 of our requested order)
      if (currentPhotos.isNotEmpty) {
        final firstItem = currentPhotos[0];
        String? targetMainId;
        
        if (firstItem is PhotoModel) {
          targetMainId = firstItem.id;
        } else if (firstItem is File) {
          // If the first item was a new file, find its new ID from the refreshed user photos
          // We assume the most recently added photo with this index/order matches
          // (Actually, the most reliable way is comparing URLs or checking the last photo added)
          final newPhotos = updatedUser?.photos ?? [];
          if (newPhotos.isNotEmpty) {
            // Find the photo that was just uploaded. 
            // Since we upload sequentially, we can try to find the one that isn't in initialPhotos
            final newlyUploaded = newPhotos.where((p) => !initialPhotos.any((ip) => ip.id == p.id)).toList();
            if (newlyUploaded.isNotEmpty) {
               targetMainId = newlyUploaded.first.id; // Simplification: first newly uploaded
            }
          }
        }
        
        if (targetMainId != null) {
          await controller.setMainPhoto(targetMainId, refresh: false);
        }
      }
      
      // 5. Final single refresh
      await controller.refreshProfile();
      
      Get.back();
      Helpers.showSnackbar(message: 'Profile photos updated successfully!');
    } catch (e, stackTrace) {
      debugPrint('[EditPhotos] Error saving: $e');
      debugPrint('[EditPhotos] Stack: $stackTrace');
      Helpers.showSnackbar(message: 'Failed to update photos', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}

class _InstructionsCard extends StatelessWidget {
  final Color textColor;
  final Color cardBg;

  const _InstructionsCard({
    required this.textColor,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(LucideIcons.info, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Photo Guidelines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GuidelineItem(icon: LucideIcons.star, text: 'First photo will be your main profile picture'),
          _GuidelineItem(icon: LucideIcons.users, text: 'Show your face clearly in all photos'),
          _GuidelineItem(icon: LucideIcons.image, text: 'High-quality photos get more matches'),
        ],
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuidelineItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosGrid extends StatefulWidget {
  final List<dynamic> photos;
  final Function(int) onPhotoTap;
  final VoidCallback onAddPhoto;
  final Function(int, int) onReorder;
  final Color textColor;
  final Color cardBg;
  final Color borderColor;

  const _PhotosGrid({
    required this.photos,
    required this.onPhotoTap,
    required this.onAddPhoto,
    required this.onReorder,
    required this.textColor,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  State<_PhotosGrid> createState() => _PhotosGridState();
}

class _PhotosGridState extends State<_PhotosGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: 6, // Always show 6 slots
      itemBuilder: (context, index) {
        if (index < widget.photos.length) {
          return _PhotoSlot(
            item: widget.photos[index],
            index: index,
            isMainPhoto: index == 0,
            onTap: () => widget.onPhotoTap(index),
            textColor: widget.textColor,
            cardBg: widget.cardBg,
            borderColor: widget.borderColor,
          );
        } else {
          return _EmptySlot(
            onTap: widget.onAddPhoto,
            cardBg: widget.cardBg,
            borderColor: widget.borderColor,
          );
        }
      },
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final dynamic item;
  final int index;
  final bool isMainPhoto;
  final VoidCallback onTap;
  final Color textColor;
  final Color cardBg;
  final Color borderColor;

  const _PhotoSlot({
    required this.item,
    required this.index,
    required this.isMainPhoto,
    required this.onTap,
    required this.textColor,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMainPhoto ? AppColors.primary : borderColor,
            width: isMainPhoto ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: item is File
                  ? Image.file(
                      item,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ErrorPlaceholder(),
                    )
                  : CachedNetworkImage(
                      imageUrl: CloudinaryUrl.getResizedUrl((item as PhotoModel).url, width: 400),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.withValues(alpha: 0.1),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => _ErrorPlaceholder(),
                    ),
            ),
            
            // Main photo badge
            if (isMainPhoto)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MAIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            
            // Edit indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.edit3,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final VoidCallback onTap;
  final Color cardBg;
  final Color borderColor;

  const _EmptySlot({
    required this.onTap,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? AppColors.textHintDark : AppColors.textHintLight;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              size: 32,
              color: hintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                color: hintColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(
          LucideIcons.imageOff,
          size: 32,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onAddMore;
  final bool isDark;

  const _BottomActions({
    required this.onAddMore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add more photos button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onAddMore,
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text('Add More Photos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoOptionsBottomSheet extends StatelessWidget {
  final int photoIndex;
  final bool isMainPhoto;
  final VoidCallback onSetAsMain;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _PhotoOptionsBottomSheet({
    required this.photoIndex,
    required this.isMainPhoto,
    required this.onSetAsMain,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Photo Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          
          // Options
          ListTile(
            leading: const Icon(LucideIcons.eye),
            title: const Text('View Fullscreen'),
            onTap: onView,
          ),
          
          if (!isMainPhoto)
            ListTile(
              leading: const Icon(LucideIcons.star),
              title: const Text('Set as Main Photo'),
              onTap: onSetAsMain,
            ),
          
          ListTile(
            leading: const Icon(LucideIcons.edit3),
            title: const Text('Edit Photo'),
            onTap: onEdit,
          ),
          
          if (!isMainPhoto)
            ListTile(
              leading: Icon(LucideIcons.trash2, color: Colors.red),
              title: const Text('Delete Photo', style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
