import 'package:get/get.dart';
import 'package:methna_app/app/controllers/users_controller.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsersController>()) {
      Get.put(UsersController(), permanent: true);
    }
  }
}
