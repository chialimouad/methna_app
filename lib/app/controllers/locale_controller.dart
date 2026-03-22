import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/storage_service.dart';

class LocaleController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const _storageKey = 'app_language';

  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  bool get isArabic => currentLocale.value.languageCode == 'ar';
  bool get isRTL => isArabic;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final saved = _storage.getString(_storageKey);
    if (saved != null && saved.contains('_')) {
      final parts = saved.split('_');
      currentLocale.value = Locale(parts[0].toLowerCase(), parts[1]);
    }
  }

  void changeLocale(String langCode, String countryCode) {
    final locale = Locale(langCode, countryCode);
    currentLocale.value = locale;
    _storage.saveString(_storageKey, '${langCode}_$countryCode');
    Get.updateLocale(locale);
  }

  void switchToEnglish() => changeLocale('en', 'US');
  void switchToArabic() => changeLocale('ar', 'DZ');

  /// Helper to get text direction for current locale
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;
}
