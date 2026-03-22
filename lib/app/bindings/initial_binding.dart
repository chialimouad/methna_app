import 'package:get/get.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/data/services/monetization_service.dart';
import 'package:methna_app/app/data/services/verification_service.dart';
import 'package:methna_app/app/data/services/subscription_service.dart';
import 'package:methna_app/app/data/services/biometric_service.dart';
import 'package:methna_app/app/data/services/boost_service.dart';
import 'package:methna_app/app/data/services/analytics_service.dart';
import 'package:methna_app/app/data/services/cache_service.dart';
import 'package:methna_app/app/controllers/splash_controller.dart';
import 'package:methna_app/app/controllers/navigation_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services NOT already initialized in main.dart
    Get.put(CacheService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(MonetizationService(), permanent: true);
    Get.put(VerificationService(), permanent: true);
    Get.put(SubscriptionService(), permanent: true);
    Get.put(BiometricService(), permanent: true);
    Get.put(BoostService(), permanent: true);
    Get.put(AnalyticsService(), permanent: true);

    // Global controllers
    Get.put(NavigationController(), permanent: true);

    // Splash
    Get.lazyPut(() => SplashController());
  }
}
