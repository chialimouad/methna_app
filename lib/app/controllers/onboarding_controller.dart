import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/storage_service.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:lucide_icons/lucide_icons.dart';


class OnboardingController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  List<OnboardingPage> get pages => [
    OnboardingPage(
      pageIndex: 0,
      title: 'onboarding_title_1'.tr,
      description: 'onboarding_desc_1'.tr,
      icon: LucideIcons.heart,
      gradient: const [Color(0xFFE8396B), Color(0xFFFF6B9D)],
      bgGradient: const [Color(0xFFFFF0F3), Color(0xFFFFE0E8)],
      illustrationIcon: LucideIcons.heart,
      accentIcon: LucideIcons.sparkles,
    ),
    OnboardingPage(
      pageIndex: 1,
      title: 'onboarding_title_2'.tr,
      description: 'onboarding_desc_2'.tr,
      icon: LucideIcons.messageSquare,
      gradient: const [Color(0xFFC2185B), Color(0xFFE8396B)],
      bgGradient: const [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
      illustrationIcon: LucideIcons.users,
      accentIcon: LucideIcons.wifi,
    ),
    OnboardingPage(
      pageIndex: 2,
      title: 'onboarding_title_3'.tr,
      description: 'onboarding_desc_3'.tr,
      icon: LucideIcons.badgeCheck,
      gradient: const [Color(0xFFE8396B), Color(0xFFFF8A65)],
      bgGradient: const [Color(0xFFFFF3E0), Color(0xFFFFE0E8)],
      illustrationIcon: LucideIcons.shield,
      accentIcon: LucideIcons.lock,
    ),
  ];

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() => completeOnboarding();

  Future<void> completeOnboarding() async {
    debugPrint('[Onboarding] completeOnboarding called');
    await _storage.setOnboardingDone();
    await _storage.setFirstLaunch(false);
    debugPrint('[Onboarding] isFirstLaunch after set: ${_storage.isFirstLaunch}');
    debugPrint('[Onboarding] isOnboardingDone after set: ${_storage.isOnboardingDone}');
    Get.offAllNamed(AppRoutes.login);
  }

  void onPageChanged(int index) => currentPage.value = index;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingPage {
  final int pageIndex;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<Color> bgGradient;
  final IconData illustrationIcon;
  final IconData accentIcon;

  OnboardingPage({
    required this.pageIndex,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.bgGradient,
    required this.illustrationIcon,
    required this.accentIcon,
  });
}
