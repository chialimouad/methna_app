import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/core/constants/api_constants.dart';

class MonetizationService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  // Reactive state
  final RxString currentPlan = 'free'.obs;
  final RxList<String> features = <String>[].obs;
  final RxInt remainingLikes = 10.obs;
  final RxBool isUnlimitedLikes = false.obs;
  final RxBool isBoosted = false.obs;
  final RxBool isInvisible = false.obs;
  final RxBool canRewind = true.obs;
  final RxInt remainingCompliments = 0.obs;
  final RxList<Map<String, dynamic>> activePlans = <Map<String, dynamic>>[].obs;

  // ─── Fetch full status ──────────────────────────────────
  Future<void> fetchStatus() async {
    try {
      final response = await _api.get(ApiConstants.monetizationStatus);
      final data = response.data;
      currentPlan.value = data['plan'] ?? 'free';
      features.value = List<String>.from(data['features'] ?? []);

      final likes = data['remainingLikes'];
      if (likes != null) {
        isUnlimitedLikes.value = likes['isUnlimited'] ?? false;
        remainingLikes.value = likes['remaining'] ?? 0;
      }

      final boost = data['boost'];
      if (boost != null) {
        isBoosted.value = boost['isActive'] ?? false;
      }
    } catch (_) {}
  }

  // ─── Fetch all limits ───────────────────────────────────
  Future<Map<String, dynamic>> fetchAllLimits() async {
    try {
      final response = await _api.get(ApiConstants.allLimits);
      final data = response.data;
      canRewind.value = data['canRewind'] ?? false;

      final compliments = data['remainingCompliments'];
      if (compliments != null) {
        remainingCompliments.value = compliments['remaining'] ?? 0;
      }

      final likes = data['remainingLikes'];
      if (likes != null) {
        isUnlimitedLikes.value = likes['isUnlimited'] ?? false;
        remainingLikes.value = likes['remaining'] ?? 0;
      }
      return data;
    } catch (_) {
      return {};
    }
  }

  // ─── Features ───────────────────────────────────────────
  Future<List<String>> fetchFeatures() async {
    try {
      final response = await _api.get(ApiConstants.monetizationFeatures);
      final list = response.data is List ? response.data : [];
      features.value = List<String>.from(list);
      return features;
    } catch (_) {
      return [];
    }
  }

  bool hasFeature(String feature) => features.contains(feature);

  bool get isPremium => currentPlan.value != 'free';

  // ─── Remaining Likes ────────────────────────────────────
  Future<void> fetchRemainingLikes() async {
    try {
      final response = await _api.get(ApiConstants.remainingLikes);
      isUnlimitedLikes.value = response.data['isUnlimited'] ?? false;
      remainingLikes.value = response.data['remaining'] ?? 0;
    } catch (_) {}
  }

  // ─── Active Plans ───────────────────────────────────────
  Future<void> fetchActivePlans() async {
    try {
      final response = await _api.get(ApiConstants.activePlans);
      final list = response.data is List ? response.data : response.data['data'] ?? [];
      activePlans.value = List<Map<String, dynamic>>.from(list);
    } catch (_) {}
  }

  // ─── Purchase Subscription ──────────────────────────────
  Future<bool> purchaseSubscription(String plan, int durationDays, String paymentRef) async {
    try {
      // 1. Get Payment Intent from Backend
      final response = await _api.post(ApiConstants.paymentCreateIntent, data: {
        'plan': plan.toUpperCase(),
        'provider': 'stripe',
      });

      final data = response.data;
      // Backend returns { success, clientSecret, customerId, ephemeralKey } directly
      if (data == null || data['clientSecret'] == null) {
        debugPrint('[Monetization] Payment intent missing clientSecret');
        return false;
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['customerId'],
          merchantDisplayName: 'Methna',
          style: ThemeMode.system,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Verify & Refresh
      await fetchStatus();
      return true;
    } catch (e) {
      if (e is StripeException) {
        debugPrint('Stripe Error: ${e.error.localizedMessage}');
      } else {
        debugPrint('Purchase Error: $e');
      }
      return false;
    }
  }

  // ─── Boost ──────────────────────────────────────────────
  Future<bool> purchaseBoost({int durationMinutes = 30}) async {
    try {
      await _api.post(ApiConstants.purchaseBoost, data: {
        'durationMinutes': durationMinutes,
      });
      isBoosted.value = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchBoostStatus() async {
    try {
      final response = await _api.get(ApiConstants.boostStatus);
      isBoosted.value = response.data['isActive'] ?? false;
    } catch (_) {}
  }

  // ─── Rewind ─────────────────────────────────────────────
  Future<Map<String, dynamic>?> useRewind() async {
    try {
      final response = await _api.post(ApiConstants.swipeRewind);
      canRewind.value = true; // may still have rewinds
      return response.data;
    } catch (_) {
      canRewind.value = false;
      return null;
    }
  }

  Future<void> checkCanRewind() async {
    try {
      final response = await _api.get(ApiConstants.rewindCheck);
      canRewind.value = response.data['canRewind'] ?? false;
    } catch (_) {
      canRewind.value = false;
    }
  }

  // ─── Compliment Credits ─────────────────────────────────
  Future<void> fetchRemainingCompliments() async {
    try {
      final response = await _api.get(ApiConstants.complimentsRemaining);
      remainingCompliments.value = response.data['remaining'] ?? 0;
    } catch (_) {}
  }

  // ─── Invisible Mode ────────────────────────────────────
  Future<bool> toggleInvisibleMode(bool enabled) async {
    try {
      await _api.post(ApiConstants.invisibleToggle, data: {'enabled': enabled});
      isInvisible.value = enabled;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchInvisibleStatus() async {
    try {
      final response = await _api.get(ApiConstants.invisibleStatus);
      isInvisible.value = response.data['isInvisible'] ?? false;
    } catch (_) {}
  }

  // ─── Passport Mode ───────────────────────────────────
  final Rx<Map<String, dynamic>?> passportLocation = Rx<Map<String, dynamic>?>(null);

  Future<bool> setPassportLocation(double lat, double lng, String cityName) async {
    try {
      await _api.post(ApiConstants.setPassport, data: {
        'latitude': lat,
        'longitude': lng,
        'cityName': cityName,
      });
      passportLocation.value = {'latitude': lat, 'longitude': lng, 'cityName': cityName};
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearPassportLocation() async {
    try {
      await _api.post(ApiConstants.clearPassport);
      passportLocation.value = null;
    } catch (_) {}
  }

  Future<void> fetchPassportLocation() async {
    try {
      final response = await _api.get(ApiConstants.getPassport);
      if (response.data != null && response.data['latitude'] != null) {
        passportLocation.value = response.data;
      } else {
        passportLocation.value = null;
      }
    } catch (_) {
      passportLocation.value = null;
    }
  }

  // ─── Payment Intent ──────────────────────────────────
  Future<Map<String, dynamic>?> createPaymentIntent(String plan, int durationDays, String provider) async {
    try {
      final response = await _api.post(ApiConstants.paymentCreateIntent, data: {
        'plan': plan,
        'durationDays': durationDays,
        'provider': provider,
      });
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchPricing() async {
    try {
      final response = await _api.get(ApiConstants.paymentPricing);
      return response.data;
    } catch (_) {
      return null;
    }
  }

  // ─── Rematch / Second Chance ─────────────────────────
  Future<bool> requestRematch(String targetUserId) async {
    try {
      await _api.post(ApiConstants.requestRematch(targetUserId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> acceptRematch(String requestId) async {
    try {
      await _api.post(ApiConstants.acceptRematch(requestId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectRematch(String requestId) async {
    try {
      await _api.post(ApiConstants.rejectRematch(requestId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRematchRequests() async {
    try {
      final response = await _api.get(ApiConstants.myRematchRequests);
      final list = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [];
    }
  }

  // ─── Profile Views ──────────────────────────────────
  Future<void> recordProfileView(String viewedUserId) async {
    try {
      await _api.post(ApiConstants.recordProfileView(viewedUserId));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> fetchProfileViews() async {
    try {
      final response = await _api.get(ApiConstants.profileViews);
      final list = response.data is List ? response.data : response.data['views'] ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [];
    }
  }

  // ─── Success Stories ─────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchSuccessStories() async {
    try {
      final response = await _api.get(ApiConstants.successStories);
      final list = response.data is List ? response.data : response.data['stories'] ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [];
    }
  }

  Future<bool> submitSuccessStory(String title, String story, {bool isAnonymous = false}) async {
    try {
      await _api.post(ApiConstants.submitSuccessStory, data: {
        'title': title,
        'story': story,
        'isAnonymous': isAnonymous,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Background Check ────────────────────────────────
  Future<Map<String, dynamic>?> initiateBackgroundCheck({
    required String fullName,
    required String dateOfBirth,
    required bool consentGiven,
  }) async {
    try {
      final response = await _api.post(ApiConstants.backgroundCheck, data: {
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'consentGiven': consentGiven,
      });
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchBackgroundCheckStatus() async {
    try {
      final response = await _api.get(ApiConstants.backgroundCheckStatus);
      return response.data;
    } catch (_) {
      return null;
    }
  }
}
