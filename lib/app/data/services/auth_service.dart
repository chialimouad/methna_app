import 'package:get/get.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/services/storage_service.dart';
import 'package:methna_app/app/data/services/socket_service.dart';
import 'package:methna_app/app/data/services/notification_service.dart';
import 'package:methna_app/app/data/services/monetization_service.dart';
import 'package:methna_app/app/data/services/subscription_service.dart';
import 'package:methna_app/app/data/models/user_model.dart';

class AuthService extends GetxService {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  // ─── Login ─────────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    final response = await _api.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });

    final data = response.data;
    await _storage.saveToken(data['accessToken']);
    if (data['refreshToken'] != null) {
      await _storage.saveRefreshToken(data['refreshToken']);
    }

    final user = UserModel.fromJson(data['user']);
    currentUser.value = user;
    await _storage.saveUser(data['user']);
    isLoggedIn.value = true;
    _onAuthenticated();
    return user;
  }

  // ─── Register ──────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? username,
    String? phone,
  }) async {
    final response = await _api.post(ApiConstants.register, data: {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'firstName': firstName,
      'lastName': lastName,
      'username': ?username,
      'phone': ?phone,
    });
    return response.data;
  }

  // ─── Forgot Password ──────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    await _api.post(ApiConstants.forgotPassword, data: {'email': email});
  }

  // ─── Verify OTP (email verification after register) ────────
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await _api.post(ApiConstants.verifyOtp, data: {
      'email': email,
      'otp': otp,
    });
    final data = response.data;
    // After successful OTP, backend returns tokens
    if (data['accessToken'] != null) {
      await _storage.saveToken(data['accessToken']);
      if (data['refreshToken'] != null) {
        await _storage.saveRefreshToken(data['refreshToken']);
      }
      if (data['user'] != null) {
        final user = UserModel.fromJson(data['user']);
        currentUser.value = user;
        await _storage.saveUser(data['user']);
        isLoggedIn.value = true;
      }
    }
    return data;
  }

  // ─── Resend OTP ────────────────────────────────────────────
  Future<void> resendOtp(String email) async {
    await _api.post(ApiConstants.resendOtp, data: {'email': email});
  }

  // ─── Verify Reset OTP ──────────────────────────────────────
  Future<Map<String, dynamic>> verifyResetOtp(String email, String otp) async {
    final response = await _api.post(ApiConstants.verifyResetOtp, data: {
      'email': email,
      'otp': otp,
    });
    return response.data;
  }

  // ─── Reset Password ───────────────────────────────────────
  Future<void> resetPassword(String email, String otpCode, String newPassword) async {
    await _api.post(ApiConstants.resetPassword, data: {
      'email': email,
      'otp': otpCode,
      'newPassword': newPassword,
    });
  }

  // ─── Get Current User ─────────────────────────────────────
  Future<UserModel> fetchMe() async {
    final response = await _api.get(ApiConstants.usersMe);
    final user = UserModel.fromJson(response.data);
    currentUser.value = user;
    await _storage.saveUser(response.data);
    return user;
  }

  // ─── Update FCM Token ──────────────────────────────────────
  Future<void> updateFcmToken(String fcmToken) async {
    await _api.patch(ApiConstants.updateFcmToken, data: {'fcmToken': fcmToken});
  }

  // ─── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      Get.find<SocketService>().disconnect();
    } catch (_) {}
    try {
      await _api.post(ApiConstants.logout);
    } catch (_) {}
    currentUser.value = null;
    isLoggedIn.value = false;
    await _storage.clearAll();
  }

  // ─── Restore Session ──────────────────────────────────────
  Future<bool> tryRestoreSession() async {
    final token = await _storage.getToken();
    if (token == null) return false;
    try {
      await fetchMe();
      isLoggedIn.value = true;
      _onAuthenticated();
      return true;
    } catch (_) {
      await _storage.clearTokens();
      return false;
    }
  }

  // ─── Post-auth setup: socket, notifications, monetization ──
  void _onAuthenticated() {
    try {
      Get.find<SocketService>().connect();
      Get.find<NotificationService>().fetchNotifications();
      Get.find<MonetizationService>().fetchStatus();
      Get.find<SubscriptionService>().fetchMySubscription();
    } catch (_) {}
  }

  String? get userId => currentUser.value?.id;
}
