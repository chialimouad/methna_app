import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:methna_app/app/controllers/signup_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SelfieVerificationScreen extends GetView<SignupController> {
  const SelfieVerificationScreen({super.key});

  /// Take a selfie, then run ML Kit face detection on it.
  /// Only accepts the photo if exactly one face is detected, the face is
  /// not too small, and eyes are open (anti-spoofing heuristic).
  Future<void> _takeSelfie(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file = File(picked.path);

    // Show a quick loading overlay while detecting faces
    if (!context.mounted) return;
    _showFaceCheckDialog(context);

    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true, // smile + eye-open probability
          enableLandmarks: true,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      // Dismiss loading
      if (!context.mounted) return;
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (faces.isEmpty) {
        _showError('No face detected. Please take a clear selfie showing your full face.');
        return;
      }
      if (faces.length > 1) {
        _showError('Multiple faces detected. Please make sure only your face is visible.');
        return;
      }

      final face = faces.first;

      // Check face size — bounding box should be at least 15% of the image width
      // (prevents photos of photos from far away)
      final boxWidth = face.boundingBox.width;
      if (boxWidth < 100) {
        _showError('Your face is too far from the camera. Please hold the phone closer.');
        return;
      }

      // Check eyes are open (anti-spoofing: closed eyes / photo of a photo)
      final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
      if (leftEyeOpen < 0.3 && rightEyeOpen < 0.3) {
        _showError('Please keep your eyes open for the selfie verification.');
        return;
      }

      // Check head rotation — excessive tilt/rotation suggests not a real selfie
      final headY = face.headEulerAngleY ?? 0; // left-right rotation
      final headZ = face.headEulerAngleZ ?? 0; // tilt
      if (headY.abs() > 36 || headZ.abs() > 36) {
        _showError('Please face the camera directly without tilting your head.');
        return;
      }

      // ✅ All checks passed — accept the selfie
      controller.setSelfie(file);
      _showSuccess();
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showError('Face detection failed. Please try again.');
    }
  }

  void _showFaceCheckDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verifying your face...', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    Get.snackbar(
      'Verification Failed',
      msg,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
  }

  void _showSuccess() {
    Get.snackbar(
      'Face Verified',
      'Your selfie has been accepted!',
      backgroundColor: AppColors.verified,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFFFF8F0);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // "IDENTITY CHECK" label
                    Text(
                      'identity_check'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'selfie_verification'.tr,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'selfie_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: secondaryColor, height: 1.5),
                    ),
                    const SizedBox(height: 48),

                    // ── Selfie circle ──
                    Obx(() {
                      final hasSelfie = controller.selfiePhoto.value != null;
                      return GestureDetector(
                        onTap: () => _takeSelfie(context),
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ring — green if verified
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: hasSelfie
                                        ? AppColors.verified
                                        : (isDark ? AppColors.borderDark : Colors.grey.shade300),
                                    width: 3,
                                  ),
                                ),
                              ),
                              // Inner content
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                                ),
                                child: hasSelfie
                                    ? ClipOval(
                                        child: Image.file(
                                          controller.selfiePhoto.value!,
                                          fit: BoxFit.cover,
                                          width: 160,
                                          height: 160,
                                        ),
                                      )
                                    : Icon(
                                        LucideIcons.smile,
                                        size: 56,
                                        color: isDark ? AppColors.textHintDark : Colors.grey.shade400,
                                      ),
                              ),
                              // Verified badge (when selfie accepted)
                              if (hasSelfie)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.verified,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.check, color: Colors.white, size: 22),
                                  ),
                                ),
                              // Camera badge (when no selfie yet)
                              if (!hasSelfie)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.cardDark : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      LucideIcons.camera,
                                      size: 18,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    // ── Face detection requirements ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          _Requirement(
                            icon: LucideIcons.smile,
                            text: 'Show your full face clearly',
                            secondaryColor: secondaryColor,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 10),
                          _Requirement(
                            icon: LucideIcons.eye,
                            text: 'Keep both eyes open',
                            secondaryColor: secondaryColor,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 10),
                          _Requirement(
                            icon: LucideIcons.scan,
                            text: 'Face the camera directly',
                            secondaryColor: secondaryColor,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 10),
                          _Requirement(
                            icon: LucideIcons.sun,
                            text: 'Use good lighting',
                            secondaryColor: secondaryColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Security badges ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.lock, size: 14, color: secondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'encrypted'.tr,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('•', style: TextStyle(color: secondaryColor, fontSize: 10)),
                        const SizedBox(width: 16),
                        Icon(LucideIcons.badgeCheck, size: 14, color: secondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'ai_identity_match'.tr,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom: Continue button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.selfiePhoto.value == null) {
                      _takeSelfie(context);
                    } else {
                      controller.goToNextStep();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'continue_match'.tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color secondaryColor;
  final Color textColor;

  const _Requirement({
    required this.icon,
    required this.text,
    required this.secondaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 13, color: textColor)),
      ],
    );
  }
}
