import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:methna_app/core/constants/app_constants.dart';

class StorageService extends GetxService {
  late final GetStorage _box;
  late final FlutterSecureStorage _secure;

  Future<StorageService> init() async {
    _box = GetStorage();
    _secure = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    return this;
  }

  // ─── Secure Storage (tokens) ───────────────────────────────
  Future<void> saveToken(String token) async =>
      await _secure.write(key: AppConstants.tokenKey, value: token);

  Future<String?> getToken() async =>
      await _secure.read(key: AppConstants.tokenKey);

  Future<void> saveRefreshToken(String token) async =>
      await _secure.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> getRefreshToken() async =>
      await _secure.read(key: AppConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _secure.delete(key: AppConstants.tokenKey);
    await _secure.delete(key: AppConstants.refreshTokenKey);
  }

  // ─── Regular Storage ───────────────────────────────────────
  Future<void> saveUser(Map<String, dynamic> user) async =>
      await _box.write(AppConstants.userKey, jsonEncode(user));

  Map<String, dynamic>? getUser() {
    final data = _box.read(AppConstants.userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  bool get isOnboardingDone => _box.read(AppConstants.onboardingKey) ?? false;
  Future<void> setOnboardingDone() async =>
      await _box.write(AppConstants.onboardingKey, true);

  String get themeMode => _box.read(AppConstants.themeKey) ?? 'system';
  Future<void> setThemeMode(String mode) async =>
      await _box.write(AppConstants.themeKey, mode);

  bool get isFirstLaunch => _box.read(AppConstants.firstLaunchKey) ?? true;
  Future<void> setFirstLaunch(bool value) async =>
      await _box.write(AppConstants.firstLaunchKey, value);

  // ─── Generic key-value helpers ─────────────────────────────
  bool? getBool(String key) => _box.read<bool>(key);
  Future<void> saveBool(String key, bool value) async =>
      await _box.write(key, value);

  String? getString(String key) => _box.read<String>(key);
  Future<void> saveString(String key, String value) async =>
      await _box.write(key, value);

  // ─── Clear Auth Data (preserves user preferences) ──────────
  Future<void> clearAll() async {
    await clearTokens();
    // Only remove auth-related data, preserve firstLaunch, theme, locale, onboarding
    await _box.remove(AppConstants.userKey);
  }
}
