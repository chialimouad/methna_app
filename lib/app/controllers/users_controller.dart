import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/data/models/category_model.dart';
import 'package:methna_app/app/data/models/conversation_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';

class UsersController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // ─── Data lists ──────────────────────────────────────────
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> nearbyUsers = <UserModel>[].obs;
  final RxList<UserModel> liveTodayUsers = <UserModel>[].obs;
  final RxList<CategoryModel> backendCategories = <CategoryModel>[].obs;
  final RxList<ConversationModel> recentConversations = <ConversationModel>[].obs;

  // ─── UI state ──────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString selectedCategory = 'all'.obs;
  final RxInt page = 1.obs;
  final RxBool hasMore = true.obs;

  // Built-in filter tabs (fixed + dynamic from backend)
  List<String> get categories {
    final base = ['all', 'nearby', 'new', 'online', 'verified'];
    return base;
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      await Future.wait([
        fetchUsers(refresh: true),
        fetchNearbyUsers(),
        fetchBackendCategories(),
        fetchRecentConversations(),
      ]);
    } catch (e) {
      hasError.value = true;
      debugPrint('[UsersController] _loadAll error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── All users (from discovery categories) ─────────────
  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      page.value = 1;
      hasMore.value = true;
    }
    if (!hasMore.value && !refresh) return;

    try {
      final response = await _api.get(ApiConstants.discoverCategories);
      final data = response.data;

      // Parse the flat 'users' array from the discovery response
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = data['users'] ?? [];
      } else {
        list = [];
      }
      final users = (list).map((u) => UserModel.fromJson(u)).toList();

      if (refresh || page.value == 1) {
        allUsers.value = users;
      } else {
        allUsers.addAll(users);
      }

      // Also parse nearby users from nested structure if available
      if (data is Map && data['nearby'] != null) {
        final nearbyList = data['nearby']['users'] ?? [];
        nearbyUsers.value = (nearbyList as List).map((u) => UserModel.fromJson(u)).toList();
      }

      // Derive live-today (online within last 24h)
      liveTodayUsers.value = allUsers.where((u) =>
          u.lastLoginAt != null &&
          DateTime.now().difference(u.lastLoginAt!).inHours < 24).toList();

      hasMore.value = users.length >= 20;
      page.value++;
    } catch (e) {
      hasError.value = true;
      debugPrint('[UsersController] fetchUsers error: $e');
    }
  }

  // ─── Nearby users ──────────────────────────────────────
  Future<void> fetchNearbyUsers() async {
    try {
      final response = await _api.get(ApiConstants.nearbyUsers);
      final data = response.data;
      final list = data is List ? data : (data is Map ? (data['users'] ?? data) : []);
      if (list is List) {
        nearbyUsers.value = list.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      debugPrint('[UsersController] fetchNearbyUsers error: $e');
    }
  }

  // ─── Backend categories ────────────────────────────────
  Future<void> fetchBackendCategories() async {
    try {
      final response = await _api.get(ApiConstants.categories);
      final list = response.data is List ? response.data : [];
      backendCategories.value = (list as List).map((c) => CategoryModel.fromJson(c)).toList();
    } catch (_) {}
  }

  // ─── Recent conversations (messages preview) ───────────
  Future<void> fetchRecentConversations() async {
    try {
      final response = await _api.get(ApiConstants.conversations, queryParameters: {'limit': 5});
      final list = response.data is List ? response.data : response.data['conversations'] ?? [];
      recentConversations.value = (list as List).map((c) => ConversationModel.fromJson(c)).toList();
    } catch (_) {}
  }

  // ─── Filtered users for grid tabs ──────────────────────
  List<UserModel> get filteredUsers {
    switch (selectedCategory.value) {
      case 'nearby':
        return nearbyUsers;
      case 'new':
        return allUsers.where((u) =>
            u.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();
      case 'online':
        return allUsers.where((u) => u.isOnline).toList();
      case 'verified':
        return allUsers.where((u) => u.selfieVerified).toList();
      default:
        return allUsers;
    }
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
    if (cat == 'nearby' && nearbyUsers.isEmpty) {
      fetchNearbyUsers();
    }
  }

  void openUserDetail(UserModel user) {
    Get.toNamed(AppRoutes.userDetail, arguments: {'user': user});
  }

  void openCategory(CategoryModel cat) {
    Get.toNamed(AppRoutes.categoryUsers, arguments: {'category': cat});
  }

  Future<void> refreshUsers() async {
    await _loadAll();
  }

  void loadMore() => fetchUsers();
}
