import 'package:get/get.dart';
import 'package:methna_app/app/data/services/boost_service.dart';

/// Controller for the Boost screen / feature.
class BoostController extends GetxController {
  final BoostService _boostService = Get.find<BoostService>();

  BoostStatus get status => _boostService.status.value;
  RxBool get isLoading => _boostService.isLoading;

  @override
  void onInit() {
    super.onInit();
    _boostService.fetchStatus();
  }

  /// Activate a profile boost.
  Future<void> activateBoost() async {
    final success = await _boostService.activateBoost();
    if (success) {
      Get.snackbar('Boost Activated!', 'Your profile is now boosted ✨',
          snackPosition: SnackPosition.TOP);
    } else {
      Get.snackbar('Error', 'Failed to activate boost. Try again.',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Purchase a boost package.
  Future<void> purchaseBoost(String packageId) async {
    final result = await _boostService.purchaseBoost(packageId);
    if (result != null) {
      await _boostService.fetchStatus();
      Get.snackbar('Success', 'Boost purchased!',
          snackPosition: SnackPosition.TOP);
    }
  }

  /// Refresh boost status.
  @override
  Future<void> refresh() => _boostService.fetchStatus();
}
