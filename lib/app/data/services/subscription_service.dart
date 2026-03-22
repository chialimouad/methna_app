import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/core/constants/api_constants.dart';

class SubscriptionService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  // Reactive state
  final RxString currentPlan = 'free'.obs;
  final RxString status = 'inactive'.obs;
  final Rx<DateTime?> expiresAt = Rx<DateTime?>(null);
  final RxBool isActive = false.obs;
  final RxList<Map<String, dynamic>> availablePlans = <Map<String, dynamic>>[].obs;

  // ─── Fetch current subscription ─────────────────────────
  Future<void> fetchMySubscription() async {
    try {
      final response = await _api.get(ApiConstants.subscriptionMe);
      final data = response.data;
      currentPlan.value = data['plan'] ?? 'free';
      status.value = data['status'] ?? 'inactive';
      isActive.value = data['status'] == 'active';
      if (data['expiresAt'] != null) {
        expiresAt.value = DateTime.tryParse(data['expiresAt']);
      }
    } catch (_) {
      currentPlan.value = 'free';
      isActive.value = false;
    }
  }

  // ─── Fetch available plans ──────────────────────────────
  Future<List<Map<String, dynamic>>> fetchPlans() async {
    try {
      final response = await _api.get(ApiConstants.subscriptionPlans);
      final list = response.data is List ? response.data : [];
      availablePlans.value = List<Map<String, dynamic>>.from(list);
      return availablePlans;
    } catch (_) {
      return [];
    }
  }

  // ─── Subscribe to a plan ────────────────────────────────
  Future<bool> subscribe(String plan, {int durationDays = 30, String? paymentReference}) async {
    try {
      await _api.post(ApiConstants.subscriptionCreate, data: {
        'plan': plan,
        'durationDays': durationDays,
        'paymentReference': ?paymentReference,
      });
      await fetchMySubscription();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Cancel subscription ────────────────────────────────
  Future<bool> cancelSubscription() async {
    try {
      await _api.delete(ApiConstants.subscriptionCancel);
      currentPlan.value = 'free';
      isActive.value = false;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Computed ───────────────────────────────────────────
  bool get isPremium => currentPlan.value != 'free' && isActive.value;
  bool get isExpired => expiresAt.value != null && expiresAt.value!.isBefore(DateTime.now());

  int get daysRemaining {
    if (expiresAt.value == null) return 0;
    final diff = expiresAt.value!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }
}
