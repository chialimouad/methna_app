import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/data/services/monetization_service.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/helpers.dart';

import 'package:methna_app/app/data/services/location_service.dart';
import 'package:methna_app/app/data/services/storage_service.dart';

class HomeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();
  final MonetizationService _monetization = Get.find<MonetizationService>();
  final LocationService _location = Get.find<LocationService>();
  final StorageService _storage = Get.find<StorageService>();

  final RxList<UserModel> discoverUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEmpty = false.obs;
  final RxInt currentCardIndex = 0.obs;
  final RxBool locationGranted = true.obs;

  // Filter state
  final RxInt minAge = 18.obs;
  final RxInt maxAge = 45.obs;
  final RxDouble maxDistance = 50.0.obs;
  final RxString genderFilter = 'all'.obs;
  final RxString educationFilter = ''.obs;
  final RxString religiousLevelFilter = ''.obs;
  final RxList<String> interestsFilter = <String>[].obs;
  final RxBool verifiedOnlyFilter = false.obs;
  final RxBool goGlobalFilter = false.obs;
  final RxBool useKm = true.obs;

  // Rewind tracking
  final Rx<UserModel?> lastSwipedUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadFilters();
    fetchDiscoverUsers();
    _monetization.fetchStatus();
  }

  void _loadFilters() {
    minAge.value = _storage.getString('filter_minAge') != null ? int.parse(_storage.getString('filter_minAge')!) : 18;
    maxAge.value = _storage.getString('filter_maxAge') != null ? int.parse(_storage.getString('filter_maxAge')!) : 45;
    maxDistance.value = _storage.getString('filter_maxDistance') != null ? double.parse(_storage.getString('filter_maxDistance')!) : 50.0;
    genderFilter.value = _storage.getString('filter_gender') ?? 'all';
  }

  Future<void> saveFilters() async {
    await _storage.saveString('filter_minAge', minAge.value.toString());
    await _storage.saveString('filter_maxAge', maxAge.value.toString());
    await _storage.saveString('filter_maxDistance', maxDistance.value.toString());
    await _storage.saveString('filter_gender', genderFilter.value);
  }

  Future<void> fetchDiscoverUsers() async {
    isLoading.value = true;
    final hasPerm = await _location.checkPermission();
    locationGranted.value = hasPerm;
    
    if (!hasPerm) {
      isLoading.value = false;
      isEmpty.value = true;
      return;
    }
    
    try {
      final response = await _api.get(ApiConstants.search, queryParameters: {
        'limit': 20,
        if (genderFilter.value != 'all') 'gender': genderFilter.value,
        'minAge': minAge.value,
        'maxAge': maxAge.value,
        'maxDistance': maxDistance.value.round(),
        if (educationFilter.value.isNotEmpty) 'education': educationFilter.value,
        if (religiousLevelFilter.value.isNotEmpty) 'religiousLevel': religiousLevelFilter.value,
        if (interestsFilter.isNotEmpty) 'interests': interestsFilter.toList(),
        if (verifiedOnlyFilter.value) 'verifiedOnly': true,
      });
      final list = response.data is List ? response.data : response.data['users'] ?? [];
      discoverUsers.value = (list as List).map((u) => UserModel.fromJson(u)).toList();
      isEmpty.value = discoverUsers.isEmpty;
      currentCardIndex.value = 0;
    } catch (e) {
      isEmpty.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeUser(String userId) async {
    try {
      final response = await _api.post(ApiConstants.swipe, data: {
        'targetUserId': userId,
        'action': 'like',
      });
      final isMatch = response.data?['matched'] ?? false;
      if (isMatch) {
        Get.toNamed(AppRoutes.matchFound, arguments: {
          'user': discoverUsers.firstWhereOrNull((u) => u.id == userId),
        });
      }
      _removeCurrentCard();
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to like', isError: true);
    }
  }




  Future<void> passUser(String userId) async {
    try {
      await _api.post(ApiConstants.swipe, data: {
        'targetUserId': userId,
        'action': 'pass',
      });
      _removeCurrentCard();
    } catch (_) {}
  }

  Future<void> complimentUser(String userId, String message) async {
    try {
      final response = await _api.post(ApiConstants.swipe, data: {
        'targetUserId': userId,
        'action': 'compliment',
        'complimentMessage': message,
      });
      final isMatch = response.data?['matched'] ?? false;
      if (isMatch) {
        Get.toNamed(AppRoutes.matchFound, arguments: {
          'user': discoverUsers.firstWhereOrNull((u) => u.id == userId),
        });
      }
      _removeCurrentCard();
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to send compliment', isError: true);
    }
  }

  void _removeCurrentCard() {
    if (discoverUsers.isNotEmpty) {
      final idx = currentCardIndex.value.clamp(0, discoverUsers.length - 1);
      lastSwipedUser.value = discoverUsers[idx];
      discoverUsers.removeAt(idx);
      // Adjust index if we removed the last item in the list
      if (currentCardIndex.value >= discoverUsers.length && discoverUsers.isNotEmpty) {
        currentCardIndex.value = discoverUsers.length - 1;
      }
      if (discoverUsers.isEmpty) {
        isEmpty.value = true;
      }
    }
  }

  Future<void> rewindLastSwipe() async {
    if (lastSwipedUser.value == null) {
      Helpers.showSnackbar(message: 'No swipe to undo');
      return;
    }
    try {
      final result = await _monetization.useRewind();
      if (result != null) {
        // Re-insert the user at the top of the stack
        discoverUsers.insert(0, lastSwipedUser.value!);
        isEmpty.value = false;
        lastSwipedUser.value = null;
        Helpers.showSnackbar(message: 'Swipe undone!');
      }
    } catch (e) {
      Helpers.showSnackbar(message: 'Cannot rewind right now', isError: true);
    }
  }

  // ─── Rematch / Second Chance ────────────────────────────
  Future<void> requestRematch(String targetUserId) async {
    try {
      final success = await _monetization.requestRematch(targetUserId);
      if (success) {
        Helpers.showSnackbar(message: 'Rematch request sent!');
      } else {
        Helpers.showSnackbar(message: 'Cannot send rematch request', isError: true);
      }
    } catch (e) {
      Helpers.showSnackbar(message: 'Failed to send rematch', isError: true);
    }
  }

  // ─── Fetch Recommendations ────────────────────────────
  final RxList<UserModel> recommendedUsers = <UserModel>[].obs;

  Future<void> fetchRecommendations() async {
    try {
      final response = await _api.get(ApiConstants.recommendedForYou);
      final list = response.data is List ? response.data : response.data['users'] ?? [];
      recommendedUsers.value = (list as List).map((u) => UserModel.fromJson(u)).toList();
    } catch (_) {}
  }

  // ─── Profile View Recording ───────────────────────────
  Future<void> recordProfileView(String userId) async {
    try {
      await _api.post(ApiConstants.recordProfileView(userId));
    } catch (_) {}
  }

  void openFilter() => Get.toNamed(AppRoutes.filter);
  void openNotifications() => Get.toNamed(AppRoutes.notifications);
  void openProfile() => Get.toNamed(AppRoutes.profile);

  bool get canRewind => _monetization.canRewind.value && lastSwipedUser.value != null;
  int get remainingLikes => _monetization.remainingLikes.value;
  bool get isUnlimitedLikes => _monetization.isUnlimitedLikes.value;
  bool get isPremium => _monetization.isPremium;
  UserModel? get currentUser => _auth.currentUser.value;
}
