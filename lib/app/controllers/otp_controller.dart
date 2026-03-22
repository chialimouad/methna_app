import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/utils/helpers.dart';

class OtpController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final TextEditingController otpController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool canResend = false.obs;
  final RxInt countdown = 60.obs;
  final RxString otpText = ''.obs;

  late String email;
  late String purpose; // 'reset_password' or 'verify_email'

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    purpose = args?['purpose'] ?? 'verify_email';
    otpController.addListener(() => otpText.value = otpController.text);
    _startCountdown();
  }

  void _startCountdown() {
    canResend.value = false;
    countdown.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      countdown.value--;
      if (countdown.value <= 0) {
        canResend.value = true;
        return false;
      }
      return true;
    });
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      Helpers.showSnackbar(message: 'Please enter the 6-digit code', isError: true);
      return;
    }

    isLoading.value = true;
    try {
      if (purpose == 'verify_email') {
        await _auth.verifyOtp(email, otp);
        Helpers.showSnackbar(message: 'Email verified successfully!');
        // Continue signup flow
        Get.offNamed(AppRoutes.signupFaithReligion);
      } else {
        await _auth.verifyResetOtp(email, otp);
        Helpers.showSnackbar(message: 'Code verified!');
        Get.offNamed(AppRoutes.resetPassword, arguments: {
          'email': email,
          'otpCode': otp,
        });
      }
    } catch (e) {
      Helpers.showSnackbar(message: 'Invalid or expired code', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (!canResend.value) return;
    try {
      if (purpose == 'verify_email') {
        await _auth.resendOtp(email);
      } else {
        await _auth.forgotPassword(email);
      }
      Helpers.showSnackbar(message: 'New code sent!');
      _startCountdown();
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to resend code', isError: true);
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
