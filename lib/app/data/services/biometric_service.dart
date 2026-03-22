import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:methna_app/app/data/services/storage_service.dart';

/// Service for biometric (fingerprint / face) authentication.
class BiometricService extends GetxService {
  final LocalAuthentication _auth = LocalAuthentication();
  final StorageService _storage = Get.find<StorageService>();

  final RxBool isAvailable = false.obs;
  final RxBool isEnabled = false.obs;
  final RxList<BiometricType> availableTypes = <BiometricType>[].obs;

  Future<BiometricService> init() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      isAvailable.value = canCheck && isSupported;

      if (isAvailable.value) {
        availableTypes.value = await _auth.getAvailableBiometrics();
      }

      // Restore user preference
      isEnabled.value = _storage.getBool('biometric_enabled') ?? false;
    } catch (_) {
      isAvailable.value = false;
    }
    return this;
  }

  /// Enable or disable biometric login.
  Future<void> setEnabled(bool value) async {
    if (value && !isAvailable.value) return;
    isEnabled.value = value;
    await _storage.saveBool('biometric_enabled', value);
  }

  /// Prompt the user for biometric authentication.
  /// Returns `true` if authentication succeeded.
  Future<bool> authenticate({String reason = 'Verify your identity'}) async {
    if (!isAvailable.value || !isEnabled.value) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Returns a human-readable label for the primary biometric type.
  String get biometricLabel {
    if (availableTypes.contains(BiometricType.face)) return 'Face ID';
    if (availableTypes.contains(BiometricType.fingerprint)) return 'Fingerprint';
    if (availableTypes.contains(BiometricType.iris)) return 'Iris';
    return 'Biometric';
  }
}
