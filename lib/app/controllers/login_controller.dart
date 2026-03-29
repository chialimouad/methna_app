import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/utils/helpers.dart';

class LoginController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    if (isLoading.value) return; // prevent double tap

    isLoading.value = true;
    debugPrint('[Login] login attempt: ${emailController.text.trim()}');
    try {
      await _auth.login(
        emailController.text.trim(),
        passwordController.text,
      );
      debugPrint('[Login] login SUCCESS');
      
      // Keep isLoading true to block further taps during transition
      Helpers.showLottieDialog(
        lottieAsset: 'assets/animations/success.json',
        title: 'Log in Successful!',
        message: 'Please wait.\nYou will be directed to the homepage.',
        barrierDismissible: false,
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.offAllNamed(AppRoutes.main);
      });
      
    } catch (e) {
      final message = _extractError(e);
      debugPrint('[Login] login FAILED: $message');
      isLoading.value = false;
      
      Helpers.showLottieDialog(
        lottieAsset: 'assets/animations/error.json',
        title: 'Login Failed',
        message: message,
      );
    }
  }

  void goToForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);
  void goToSignUp() => Get.toNamed(AppRoutes.signupUsername);

  String _extractError(dynamic e) {
    return Helpers.extractErrorMessage(e);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

