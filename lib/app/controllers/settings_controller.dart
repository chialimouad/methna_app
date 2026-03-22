import 'package:get/get.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/data/services/storage_service.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';

import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/helpers.dart';

class SettingsController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();
  final ApiService _api = Get.find<ApiService>();

  // ─── Theme ──────────────────────────────────────────────
  final RxString themeMode = 'system'.obs;

  // ─── Privacy ────────────────────────────────────────────
  final RxBool showOnlineStatus = true.obs;
  final RxBool showDistance = true.obs;
  final RxBool showLastSeen = true.obs;
  final RxBool showAge = true.obs;
  final RxBool privacyMode = false.obs;
  final RxString visibility = 'everyone'.obs;

  // ─── Notification settings ─────────────────────────────
  final RxBool isLoadingNotifSettings = false.obs;
  final RxMap<String, bool> notifSettings = <String, bool>{
    'newMatches': true,
    'newMessages': true,
    'likesAndSuperLikes': true,
    'profileVisitors': false,
    'eventsAndActivities': false,
    'matchesActivity': true,
    'safetyAlerts': true,
    'promotionsNews': false,
    'inAppRecommendations': false,
    'weeklyActivitySummary': false,
    'connectionRequests': true,
    'surveyFeedback': false,
  }.obs;

  // ─── Blocked users ─────────────────────────────────────
  final RxList<UserModel> blockedUsers = <UserModel>[].obs;
  final RxBool isLoadingBlocked = false.obs;

  // ─── Username ──────────────────────────────────────────
  final RxBool isSavingUsername = false.obs;

  UserModel? get currentUser => _auth.currentUser.value;
  String get username => currentUser?.username ?? '';

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _storage.themeMode;
    _loadSecuritySettings();
    _loadPrivacySettings();
    fetchNotificationSettings();
    fetchBlockedUsers();
  }

  void _loadPrivacySettings() {
    showOnlineStatus.value = _storage.getBool('privacy_showOnline') ?? true;
    showDistance.value = _storage.getBool('privacy_showDistance') ?? true;
    showLastSeen.value = _storage.getBool('privacy_showLastSeen') ?? true;
    showAge.value = _storage.getBool('privacy_showAge') ?? true;
    privacyMode.value = _storage.getBool('privacy_privacyMode') ?? false;
    visibility.value = _storage.getString('privacy_visibility') ?? 'everyone';
  }

  // ═══════════════════════════════════════════════════════════
  // THEME
  // ═══════════════════════════════════════════════════════════
  void changeTheme(String mode) {
    themeMode.value = mode;
    _storage.setThemeMode(mode);
    switch (mode) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // USERNAME
  // ═══════════════════════════════════════════════════════════
  Future<bool> changeUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) {
      Helpers.showSnackbar(message: 'Username cannot be empty', isError: true);
      return false;
    }
    isSavingUsername.value = true;
    try {
      await _api.patch(ApiConstants.usersMe, data: {
        'username': newUsername.trim(),
      });
      await _auth.fetchMe();
      Helpers.showSnackbar(message: 'Username updated successfully');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to update username', isError: true);
      return false;
    } finally {
      isSavingUsername.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATION SETTINGS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchNotificationSettings() async {
    isLoadingNotifSettings.value = true;
    
    // Load local first
    for (final key in notifSettings.keys.toList()) {
      final localVal = _storage.getBool('notif_$key');
      if (localVal != null) {
        notifSettings[key] = localVal;
      }
    }

    try {
      final response = await _api.get(ApiConstants.notificationSettings);
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        for (final key in notifSettings.keys.toList()) {
          if (data.containsKey(key)) {
            notifSettings[key] = data[key] == true;
            _storage.saveBool('notif_$key', data[key] == true);
          }
        }
      }
    } catch (_) {}
    finally {
      isLoadingNotifSettings.value = false;
    }
  }

  Future<void> updateNotifSetting(String key, bool value) async {
    notifSettings[key] = value;
    _storage.saveBool('notif_$key', value);
    try {
      await _api.patch(ApiConstants.notificationSettings, data: {key: value});
    } catch (_) {
      // Keep local value even on API failure
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BLOCKED USERS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchBlockedUsers() async {
    isLoadingBlocked.value = true;
    try {
      final response = await _api.get(ApiConstants.blockedUsers);
      final list = response.data is List ? response.data : response.data['users'] ?? [];
      blockedUsers.value = (list as List).map((u) => UserModel.fromJson(u)).toList();
    } catch (_) {}
    finally {
      isLoadingBlocked.value = false;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _api.delete(ApiConstants.unblockUser(userId));
      blockedUsers.removeWhere((u) => u.id == userId);
      Helpers.showSnackbar(message: 'User unblocked');
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to unblock user', isError: true);
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _api.post(ApiConstants.blockUser(userId));
      Helpers.showSnackbar(message: 'User blocked');
      fetchBlockedUsers();
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to block user', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REPORTS
  // ═══════════════════════════════════════════════════════════
  Future<bool> submitReport(String reportedUserId, String reason, {String? details}) async {
    try {
      await _api.post(ApiConstants.createReport, data: {
        'reportedId': reportedUserId,
        'reason': reason,
        'details': details,
      });
      Helpers.showSnackbar(message: 'Report submitted');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to submit report', isError: true);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVACY
  // ═══════════════════════════════════════════════════════════
  Future<void> updatePrivacy({bool? showOnline, bool? showDist, bool? showLastSeenVal, bool? showAgeVal, bool? privacyModeVal}) async {
    // 1. Optimistic UI update
    if (showOnline != null) showOnlineStatus.value = showOnline;
    if (showDist != null) showDistance.value = showDist;
    if (showLastSeenVal != null) showLastSeen.value = showLastSeenVal;
    if (showAgeVal != null) showAge.value = showAgeVal;
    if (privacyModeVal != null) privacyMode.value = privacyModeVal;

    // 2. Persist to storage
    _storage.saveBool('privacy_showOnline', showOnlineStatus.value);
    _storage.saveBool('privacy_showDistance', showDistance.value);
    _storage.saveBool('privacy_showLastSeen', showLastSeen.value);
    _storage.saveBool('privacy_showAge', showAge.value);
    _storage.saveBool('privacy_privacyMode', privacyMode.value);

    // 3. API
    try {
      final data = <String, dynamic>{};
      if (showOnline != null) data['showOnlineStatus'] = showOnline;
      if (showDist != null) data['showDistance'] = showDist;
      if (showLastSeenVal != null) data['showLastSeen'] = showLastSeenVal;
      if (showAgeVal != null) data['showAge'] = showAgeVal;
      if (privacyModeVal != null) data['privacyMode'] = privacyModeVal;
      if (data.isEmpty) return;

      await _api.patch(ApiConstants.updatePrivacy, data: data);
    } catch (_) {}
  }

  Future<void> updateVisibility(String val) async {
    visibility.value = val;
    _storage.saveString('privacy_visibility', val);
    try {
      await _api.patch(ApiConstants.updatePrivacy, data: {'visibility': val});
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // ACCOUNT
  // ═══════════════════════════════════════════════════════════
  Future<void> logout() async {
    await _auth.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> deleteAccount() async {
    try {
      Helpers.showLoading(message: 'deleting_account'.tr);
      await _api.delete(ApiConstants.usersMe);
      Helpers.hideLoading();
      await _auth.logout();
      Get.offAllNamed(AppRoutes.login);
      Helpers.showSnackbar(message: 'account_deleted'.tr);
    } catch (e) {
      Helpers.hideLoading();
      Helpers.showSnackbar(message: 'delete_account_failed'.tr, isError: true);
    }
  }

  Future<void> deactivateAccount() async {
    try {
      await _api.patch(ApiConstants.usersMe, data: {'status': 'deactivated'});
      await _auth.logout();
      Get.offAllNamed(AppRoutes.login);
      Helpers.showSnackbar(message: 'account_deactivated'.tr);
    } catch (e) {
      Helpers.showSnackbar(message: 'deactivate_account_failed'.tr, isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CHANGE PASSWORD
  // ═══════════════════════════════════════════════════════════
  final RxBool isChangingPassword = false.obs;

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (oldPassword.trim().isEmpty || newPassword.trim().isEmpty) {
      Helpers.showSnackbar(message: 'Please fill in all fields', isError: true);
      return false;
    }
    if (newPassword.trim().length < 8) {
      Helpers.showSnackbar(message: 'Password must be at least 8 characters', isError: true);
      return false;
    }
    isChangingPassword.value = true;
    try {
      await _api.patch(ApiConstants.changePassword, data: {
        'oldPassword': oldPassword.trim(),
        'newPassword': newPassword.trim(),
      });
      Helpers.showSnackbar(message: 'Password changed successfully');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to change password', isError: true);
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SECURITY TOGGLES (local persistence)
  // ═══════════════════════════════════════════════════════════
  final RxBool rememberMe = true.obs;
  final RxBool biometricId = false.obs;
  final RxBool faceId = false.obs;
  final RxBool smsAuth = false.obs;
  final RxBool googleAuth = false.obs;

  void _loadSecuritySettings() {
    rememberMe.value = _storage.getBool('security_remember_me') ?? true;
    biometricId.value = _storage.getBool('security_biometric') ?? false;
    faceId.value = _storage.getBool('security_face_id') ?? false;
    smsAuth.value = _storage.getBool('security_sms_auth') ?? false;
    googleAuth.value = _storage.getBool('security_google_auth') ?? false;
  }

  void toggleRememberMe(bool val) {
    rememberMe.value = val;
    _storage.saveBool('security_remember_me', val);
  }

  void toggleBiometric(bool val) {
    biometricId.value = val;
    _storage.saveBool('security_biometric', val);
  }

  void toggleFaceId(bool val) {
    faceId.value = val;
    _storage.saveBool('security_face_id', val);
  }

  void toggleSmsAuth(bool val) {
    smsAuth.value = val;
    _storage.saveBool('security_sms_auth', val);
  }

  void toggleGoogleAuth(bool val) {
    googleAuth.value = val;
    _storage.saveBool('security_google_auth', val);
  }

  // ═══════════════════════════════════════════════════════════
  // FEEDBACK / REPORT
  // ═══════════════════════════════════════════════════════════
  Future<bool> sendFeedback(String subject, String message) async {
    if (message.trim().isEmpty) {
      Helpers.showSnackbar(message: 'Please enter your feedback', isError: true);
      return false;
    }
    try {
      await _api.post(ApiConstants.createReport, data: {
        'reason': 'feedback',
        'details': '[$subject] $message',
      });
      Helpers.showSnackbar(message: 'Feedback sent successfully');
      return true;
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to send feedback', isError: true);
      return false;
    }
  }
}
