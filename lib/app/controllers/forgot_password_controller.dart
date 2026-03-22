import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/utils/helpers.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  Future<void> sendResetCode() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _auth.forgotPassword(emailController.text.trim());
      Helpers.showSnackbar(message: 'Verification code sent to your email');
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'email': emailController.text.trim(),
          'purpose': 'reset_password',
        },
      );
    } catch (e) {
      Helpers.showSnackbar(message: 'Could not send code. Check your email.', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
