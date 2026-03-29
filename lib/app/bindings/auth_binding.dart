import 'package:get/get.dart';
import 'package:methna_app/app/controllers/login_controller.dart';
import 'package:methna_app/app/controllers/forgot_password_controller.dart';
import 'package:methna_app/app/controllers/otp_controller.dart';
import 'package:methna_app/app/controllers/reset_password_controller.dart';
import 'package:methna_app/app/controllers/signup_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
    Get.lazyPut(() => OtpController(), fenix: true);
    Get.lazyPut(() => ResetPasswordController(), fenix: true);
    // permanent: survives navigation across all signup screens
    if (!Get.isRegistered<SignupController>()) {
      Get.put(SignupController(), permanent: true);
    }
  }
}
