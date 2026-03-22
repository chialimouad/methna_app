import 'package:get/get.dart';
import 'package:methna_app/app/controllers/boost_controller.dart';

/// Binding for the Boost module – lazily creates BoostController.
class BoostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BoostController());
  }
}
