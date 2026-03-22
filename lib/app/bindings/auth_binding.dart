import 'package:get/get.dart';
import 'package:methna_app/app/controllers/login_controller.dart';
import 'package:methna_app/app/controllers/forgot_password_controller.dart';
import 'package:methna_app/app/controllers/otp_controller.dart';
import 'package:methna_app/app/controllers/reset_password_controller.dart';
import 'package:methna_app/app/controllers/signup_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => ForgotPasswordController());
    Get.lazyPut(() => OtpController());
    Get.lazyPut(() => ResetPasswordController());
    Get.put(SignupController());
  }
}
