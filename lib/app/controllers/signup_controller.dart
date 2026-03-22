import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/app/data/services/location_service.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/helpers.dart';

class SignupController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final ApiService _api = Get.find<ApiService>();

  // ─── Step tracking (derived from route, never manually incremented) ──
  final RxInt currentStep = 0.obs;
  static const int totalSteps = 12;

  // ─── Step 1: Username ──────────────────────────────────────
  final usernameController = TextEditingController();
  final RxBool usernameAvailable = false.obs;
  final RxBool checkingUsername = false.obs;

  // ─── Step 2: Gender ────────────────────────────────────────
  final RxString selectedGender = ''.obs;

  // ─── Step 3: Marital Status ────────────────────────────────
  final RxString selectedMaritalStatus = ''.obs;

  // ─── Step 4: Profile Details ───────────────────────────────
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  final profileFormKey = GlobalKey<FormState>();

  // ─── Step 5: Email Verification ────────────────────────────
  final otpController = TextEditingController();

  // ─── Step 6: Faith & Religion ──────────────────────────────
  final RxString selectedSect = ''.obs;
  final RxString selectedReligiousLevel = ''.obs;
  final RxString selectedPrayerFrequency = ''.obs;
  final RxString selectedMarriageTimeline = ''.obs;
  final RxBool halalDiet = true.obs;
  final RxBool nonSmoker = true.obs;

  // ─── Step 7: Hobbies & Interests ──────────────────────────
  final RxList<String> selectedHobbies = <String>[].obs;

  // ─── Step 8: Profession & Personal ─────────────────────────
  final jobTitleController = TextEditingController();
  final RxString selectedEducation = ''.obs;
  final companyController = TextEditingController();
  final heightController = TextEditingController();
  final bioController = TextEditingController();

  // ─── Step 9: Photos ────────────────────────────────────────
  final RxList<File> selectedPhotos = <File>[].obs;
  final RxInt mainPhotoIndex = 0.obs;

  // ─── Step 10: Selfie ──────────────────────────────────────
  final Rx<File?> selfiePhoto = Rx<File?>(null);

  // ─── Step 11: Location ─────────────────────────────────────
  final RxBool locationEnabled = false.obs;

  // ─── Loading states ────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool agreePrivacy = false.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  // ─── Data constants ────────────────────────────────────────
  final List<String> genders = ['Male', 'Female'];
  final List<String> maritalStatuses = ['Never Married', 'Divorced', 'Widowed', 'Married'];
  final List<String> sects = ['Sunni', 'Shia', 'Sufi', 'Other', 'Prefer not to say'];
  final List<String> religiousLevels = ['Very Practicing', 'Practicing', 'Moderate', 'Liberal'];
  final List<String> prayerFrequencies = ['Actively Practicing', 'Occasionally', 'Not Practicing'];
  final List<String> educationLevels = ['High School', 'Bachelors', 'Masters', 'Doctorate', 'Islamic Studies', 'Other'];
  final List<String> hobbiesList = [
    'Reading', 'Travel', 'Cooking', 'Sports', 'Photography',
    'Music', 'Art', 'Gaming', 'Fitness', 'Nature',
    'Volunteering', 'Writing', 'Fashion', 'Technology', 'Movies',
    'Hiking', 'Swimming', 'Cycling', 'Yoga', 'Meditation',
    'Dancing', 'Coffee', 'Shopping', 'Camping', 'Fishing',
  ];

  // ─── Route → step index map (source of truth for progress) ──
  static const _routeToStep = {
    '/signup/username': 0,
    '/signup/gender': 1,
    '/signup/marital-status': 2,
    '/signup/profile-details': 3,
    '/signup/birthday': 4,
    '/signup/email-verification': 5,
    '/signup/faith-religion': 6,
    '/signup/hobbies': 7,
    '/signup/profession': 8,
    '/signup/photos': 9,
    '/signup/selfie': 10,
    '/signup/location': 11,
  };

  /// Derive progress from the ACTUAL current route — never desyncs.
  double get progressPercent {
    final current = currentStep.value; // Force Rx read for Obx
    final step = _routeToStep[Get.currentRoute] ?? current;
    return (step + 1) / totalSteps;
  }

  /// Call this from every signup screen's build method to sync the step.
  void syncStep(String route) {
    final idx = _routeToStep[route];
    if (idx != null) currentStep.value = idx;
  }

  // ─── Ordered route list ────────────────────────────────────
  final List<String> stepRoutes = [
    AppRoutes.signupUsername,      // 0
    AppRoutes.signupGender,        // 1
    AppRoutes.signupMaritalStatus, // 2
    AppRoutes.signupProfileDetails,// 3
    AppRoutes.signupBirthday,      // 4
    AppRoutes.signupEmailVerification, // 5
    AppRoutes.signupFaithReligion, // 6
    AppRoutes.signupHobbies,       // 7
    AppRoutes.signupProfession,    // 8
    AppRoutes.signupPhotos,        // 9
    AppRoutes.signupSelfie,        // 10
    AppRoutes.signupLocation,      // 11
  ];

  /// Navigate to a specific next route explicitly.
  /// Each screen calls this with its KNOWN next route — no counter involved.
  void navigateTo(String route) {
    syncStep(route);
    Get.toNamed(route);
  }

  /// Safe to use for ALL back arrows — syncs step with whatever is below.
  void goBack() {
    Get.back();
    // After pop, sync step with the new visible route
    Future.microtask(() {
      final idx = _routeToStep[Get.currentRoute];
      if (idx != null) currentStep.value = idx;
    });
  }

  // ──── LEGACY COMPAT: keep goToNextStep for screens that still use it ────
  void goToNextStep() {
    // Sync step from current route first, then advance
    final currentIdx = _routeToStep[Get.currentRoute] ?? currentStep.value;
    final nextIdx = currentIdx + 1;
    if (nextIdx < totalSteps) {
      currentStep.value = nextIdx;
      Get.toNamed(stepRoutes[nextIdx]);
    }
  }

  // ─── Register account & advance to email verification ────
  Future<void> registerAccount() async {
    if (isLoading.value) return; // debounce
    isLoading.value = true;
    try {
      final result = await _auth.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        username: usernameController.text.trim().isNotEmpty
            ? usernameController.text.trim()
            : null,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );

      // Check if backend reported email send failure
      final emailSent = result['emailSent'] == true;
      if (emailSent) {
        Helpers.showSnackbar(message: 'Account created! Check your email for verification code.');
      } else {
        Helpers.showSnackbar(
          message: 'Account created but email delivery failed. Tap "Resend" on the next screen.',
          isError: true,
          duration: const Duration(seconds: 5),
        );
      }
      goToNextStep();
    } catch (e) {
      Helpers.showSnackbar(message: Helpers.extractErrorMessage(e), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Verify OTP after registration ─────────────────────
  Future<void> verifyEmailOtp() async {
    isLoading.value = true;
    try {
      await _auth.verifyOtp(
        emailController.text.trim(),
        otpController.text.trim(),
      );
      Helpers.showSnackbar(message: 'Email verified! Continue setting up your profile.');
      goToNextStep();
    } catch (e) {
      Helpers.showSnackbar(message: Helpers.extractErrorMessage(e), isError: true);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Resend OTP ───────────────────────────────────────
  Future<void> resendOtp() async {
    try {
      await _auth.resendOtp(emailController.text.trim());
      Helpers.showSnackbar(message: 'New OTP sent to your email');
    } catch (e) {
      Helpers.showSnackbar(message: 'Please wait before requesting another code', isError: true);
    }
  }

  // ─── Helper: map display label → backend enum value ────
  String _toEnumValue(String label) {
    return label.toLowerCase().replaceAll(' ', '_');
  }

  // ─── Step 6-8: Update profile ──────────────────────────
  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      await _api.post(ApiConstants.createOrUpdateProfile, data: {
        'gender': selectedGender.value.toLowerCase(),
        'dateOfBirth': dateOfBirth.value?.toIso8601String().split('T')[0],
        'maritalStatus': _toEnumValue(selectedMaritalStatus.value),
        if (selectedSect.value.isNotEmpty)
          'sect': _toEnumValue(selectedSect.value),
        if (selectedReligiousLevel.value.isNotEmpty)
          'religiousLevel': _toEnumValue(selectedReligiousLevel.value),
        if (selectedPrayerFrequency.value.isNotEmpty)
          'prayerFrequency': _toEnumValue(selectedPrayerFrequency.value),
        'interests': selectedHobbies.toList(),
        if (selectedEducation.value.isNotEmpty)
          'education': _toEnumValue(selectedEducation.value),
        if (jobTitleController.text.isNotEmpty)
          'jobTitle': jobTitleController.text.trim(),
        if (companyController.text.isNotEmpty)
          'company': companyController.text.trim(),
        if (heightController.text.isNotEmpty)
          'height': int.tryParse(heightController.text),
      });
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to update profile', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Step 9: Upload photos to backend ──────────────────
  Future<void> uploadPhotos() async {
    isLoading.value = true;
    try {
      for (int i = 0; i < selectedPhotos.length; i++) {
        final file = selectedPhotos[i];
        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(file.path, filename: 'photo_$i.jpg'),
        });
        await _api.upload(ApiConstants.uploadPhoto, formData);
      }
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to upload some photos', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Step 9: Upload photos ─────────────────────────────────
  void addPhoto(File file) {
    if (selectedPhotos.length < 6) {
      selectedPhotos.add(file);
    }
  }

  void removePhoto(int index) {
    selectedPhotos.removeAt(index);
    if (mainPhotoIndex.value >= selectedPhotos.length) {
      mainPhotoIndex.value = 0;
    }
  }

  void setMainPhoto(int index) => mainPhotoIndex.value = index;

  // ─── Step 10: Set selfie ──────────────────────────────────
  void setSelfie(File file) => selfiePhoto.value = file;

  // ─── Upload selfie to backend for verification ────────────
  Future<void> uploadSelfie() async {
    if (selfiePhoto.value == null) return;
    try {
      final formData = FormData.fromMap({
        'selfie': await MultipartFile.fromFile(
          selfiePhoto.value!.path,
          filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });
      await _api.upload(ApiConstants.selfieUpload, formData);
    } catch (e) {
      Helpers.showSnackbar(message: 'Selfie upload failed. You can retry from settings.', isError: true);
    }
  }

  // ─── Complete signup → go to main ─────────────────────────
  Future<void> completeSignup() async {
    isLoading.value = true;
    try {
      // 1. Update profile data (gender, religion, interests, etc.)
      await updateProfile();

      // 2. Upload selected photos
      if (selectedPhotos.isNotEmpty) {
        await uploadPhotos();
      }

      // 3. Upload selfie for verification
      if (selfiePhoto.value != null) {
        await uploadSelfie();
      }

      // 4. Update location if granted
      if (locationEnabled.value) {
        try {
          final locationService = Get.find<LocationService>();
          final position = await locationService.getCurrentPosition();
          if (position != null) {
            await _api.patch(ApiConstants.updateLocation, data: {
              'latitude': position.latitude,
              'longitude': position.longitude,
            });
          }
        } catch (_) {}
      }

      // 4. Refresh user data
      await _auth.fetchMe();

      Helpers.showSnackbar(message: 'Welcome to Methna!');
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Helpers.showSnackbar(message: 'Something went wrong', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Toggle hobby ─────────────────────────────────────────
  void toggleHobby(String hobby) {
    if (selectedHobbies.contains(hobby)) {
      selectedHobbies.remove(hobby);
    } else {
      selectedHobbies.add(hobby);
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    jobTitleController.dispose();
    companyController.dispose();
    heightController.dispose();
    super.onClose();
  }
}
