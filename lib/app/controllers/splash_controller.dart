import 'package:get/get.dart';
import 'package:methna_app/app/data/services/storage_service.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/routes/app_routes.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _auth = Get.find<AuthService>();

  final RxDouble animationProgress = 0.0.obs;
  final RxBool showLogo = false.obs;
  final RxBool showTagline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Start auth check in parallel with animation
    final navFuture = _resolveDestination();

    // Phase 1: Show logo with fade + scale
    await Future.delayed(const Duration(milliseconds: 200));
    showLogo.value = true;

    // Phase 2: Show tagline
    await Future.delayed(const Duration(milliseconds: 500));
    showTagline.value = true;

    // Phase 3: Progress bar animation
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i <= 100; i += 4) {
      animationProgress.value = i / 100;
      await Future.delayed(const Duration(milliseconds: 15));
    }

    // Phase 4: Wait for auth check to complete, then navigate
    final route = await navFuture;
    await Future.delayed(const Duration(milliseconds: 200));
    Get.offAllNamed(route);
  }

  Future<String> _resolveDestination() async {
    if (_storage.isFirstLaunch) return AppRoutes.onboarding;
    final restored = await _auth.tryRestoreSession();
    return restored ? AppRoutes.main : AppRoutes.login;
  }

}
