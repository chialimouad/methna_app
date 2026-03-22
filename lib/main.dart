import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:methna_app/app/bindings/initial_binding.dart';
import 'package:methna_app/app/controllers/locale_controller.dart';
import 'package:methna_app/app/data/services/storage_service.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/services/socket_service.dart';
import 'package:methna_app/app/data/services/location_service.dart';
import 'package:methna_app/app/data/services/notification_service.dart';
import 'package:methna_app/app/routes/app_pages.dart';
import 'package:methna_app/app/theme/app_theme.dart';
import 'package:methna_app/app/translations/app_translations.dart';
import 'package:methna_app/core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  // Initialize core services before app starts
  await _initServices();

  runApp(const MethnaApp());
}

Future<void> _initServices() async {
  await Get.putAsync(() => StorageService().init(), permanent: true);
  await Get.putAsync(() => ApiService().init(), permanent: true);
  await Get.putAsync(() => SocketService().init(), permanent: true);
  await Get.putAsync(() => LocationService().init(), permanent: true);
  await Get.putAsync(() => NotificationService().init(), permanent: true);

  // Initialize locale controller (depends on StorageService)
  Get.put(LocaleController(), permanent: true);
}

Locale _getSavedLocale(StorageService storage) {
  final code = storage.getString('app_language');
  if (code != null && code.contains('_')) {
    final parts = code.split('_');
    return Locale(parts[0].toLowerCase(), parts[1]);
  }
  return const Locale('en', 'US');
}

ThemeMode _getSavedThemeMode(StorageService storage) {
  switch (storage.themeMode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class MethnaApp extends StatelessWidget {
  const MethnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final savedLocale = _getSavedLocale(storage);

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _getSavedThemeMode(storage),

      // Routes
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,

      // Bindings
      initialBinding: InitialBinding(),

      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Translations
      translations: AppTranslations(),
      locale: savedLocale,
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
