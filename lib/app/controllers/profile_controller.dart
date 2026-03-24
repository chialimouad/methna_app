import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/helpers.dart';

class ProfileController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser.value;
    _auth.currentUser.listen((u) => user.value = u);
    // If user is null at init time, fetch it
    if (user.value == null) {
      debugPrint('[ProfileController] user is null at init, fetching...');
      refreshProfile();
    }
  }

  Future<void> refreshProfile() async {
    isLoading.value = true;
    try {
      await _auth.fetchMe();
      user.value = _auth.currentUser.value;
    } catch (e) {
      debugPrint('[ProfileController] refreshProfile error: $e');
    }
    finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final userData = <String, dynamic>{};
      final profileData = <String, dynamic>{};
      
      data.forEach((key, value) {
        if (key == 'firstName' || key == 'lastName') {
          userData[key] = value;
        } else {
          profileData[key] = value;
        }
      });

      if (userData.isNotEmpty) {
        await _api.patch(ApiConstants.usersMe, data: userData);
      }

      if (profileData.isNotEmpty) {
        await _api.post(ApiConstants.createOrUpdateProfile, data: profileData);
      }

      await _auth.fetchMe();
      user.value = _auth.currentUser.value;
      Helpers.showSnackbar(message: 'Profile updated');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to update profile', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Photo Management ───────────────────────────────────
  Future<bool> uploadPhoto(File file, {bool isMain = false}) async {
    isUploading.value = true;
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(file.path, filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        'isMain': isMain,
      });
      await _api.upload(ApiConstants.uploadPhoto, formData);
      await _auth.fetchMe();
      user.value = _auth.currentUser.value;
      Helpers.showSnackbar(message: 'Photo uploaded');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to upload photo', isError: true);
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    try {
      await _api.delete(ApiConstants.deletePhoto(photoId));
      await _auth.fetchMe();
      user.value = _auth.currentUser.value;
      Helpers.showSnackbar(message: 'Photo deleted');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to delete photo', isError: true);
      return false;
    }
  }

  Future<bool> setMainPhoto(String photoId) async {
    try {
      await _api.patch(ApiConstants.setMainPhoto(photoId));
      await _auth.fetchMe();
      user.value = _auth.currentUser.value;
      Helpers.showSnackbar(message: 'Main photo updated');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to set main photo', isError: true);
      return false;
    }
  }

  void openSettings() => Get.toNamed(AppRoutes.settings);
  void openEditProfile() => Get.toNamed(AppRoutes.editProfile);

  String get fullName => user.value?.fullName ?? '';
  String? get mainPhoto => user.value?.mainPhotoUrl;
  int get profileCompletion => user.value?.profile?.profileCompletionPercentage ?? 0;
  bool get isVerified => user.value?.selfieVerified ?? false;
  bool get isPremium => user.value?.isPremium ?? false;
}
