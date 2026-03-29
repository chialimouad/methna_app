import 'package:flutter/foundation.dart';
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
    debugPrint('[Splash] Navigating to: $route');
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Check if we already redirected (e.g. by ApiService 401 safeguard)
    if (Get.currentRoute != route) {
      Get.offAllNamed(route);
    } else {
      debugPrint('[Splash] Already at destination: $route');
    }
  }

  Future<String> _resolveDestination() async {
    final isFirst = _storage.isFirstLaunch;
    final isOnboardingDone = _storage.isOnboardingDone;
    debugPrint('[Splash] isFirstLaunch=$isFirst, isOnboardingDone=$isOnboardingDone');
    
    if (isFirst) {
      debugPrint('[Splash] First launch → onboarding');
      return AppRoutes.onboarding;
    }

    // New: Check for incomplete signup draft to resume flow
    final draftRoute = _storage.getSignupDraftRoute();
    if (draftRoute != null && draftRoute.isNotEmpty && draftRoute.contains('signup')) {
      debugPrint('[Splash] Found signup draft → resuming at $draftRoute');
      return draftRoute;
    }
    
    final restored = await _auth.tryRestoreSession();
    debugPrint('[Splash] Session restored=$restored');
    
    if (restored) {
      final user = _auth.currentUser.value;
      if (user != null) {
        // Senior Compliance Check: Without these, user CANNOT enter the app
        
        // 1. Mandatory Photos (Min 2)
        final photoCount = user.photos?.length ?? 0;
        if (photoCount < 2) {
          debugPrint('[Splash] User missing photos ($photoCount) → photos flow');
          return AppRoutes.signupPhotos;
        }

        // 2. Mandatory Face/Selfie Verification
        if (user.selfieUrl == null || user.selfieUrl!.isEmpty) {
          debugPrint('[Splash] User missing selfie → selfie flow');
          return AppRoutes.signupSelfie;
        }
      }
      return AppRoutes.main;
    }
    
    return AppRoutes.login;
  }

}
