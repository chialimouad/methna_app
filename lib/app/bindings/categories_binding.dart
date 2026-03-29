import 'package:get/get.dart';
import 'package:methna_app/app/controllers/categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    // Register CategoriesController as permanent to persist across navigation
    if (!Get.isRegistered<CategoriesController>()) {
      Get.put(CategoriesController(), permanent: true);
    }
  }
}
