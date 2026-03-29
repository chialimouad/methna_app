import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/data/models/category_model.dart';
import 'package:methna_app/app/data/models/conversation_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';

import 'package:methna_app/app/data/models/success_story_model.dart';

class UsersController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // ─── Data lists ──────────────────────────────────────────
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> nearbyUsers = <UserModel>[].obs;
  final RxList<UserModel> liveTodayUsers = <UserModel>[].obs;
  final RxList<CategoryModel> backendCategories = <CategoryModel>[].obs;
  final RxList<ConversationModel> recentConversations = <ConversationModel>[].obs;
  final RxList<UserModel> matches = <UserModel>[].obs;
  final RxList<UserModel> likesReceived = <UserModel>[].obs;
  final RxList<SuccessStoryModel> successStories = <SuccessStoryModel>[].obs;

  // ─── UI state ──────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isLoadingStories = false.obs;
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
    if (isLoading.value) return; // Prevent duplicate calls
    isLoading.value = true;
    hasError.value = false;
    try {
      await Future.wait([
        fetchUsers(refresh: true),
        fetchNearbyUsers(),
        fetchBackendCategories(),
        fetchSuccessStories(),
        fetchMatches(),
        fetchWhoLikedMe(),
      ]);
    } catch (e) {
      hasError.value = true;
      debugPrint('[UsersController] _loadAll error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── All users (Primary Source: /search, Secondary: /matches/discover) ─────────────
  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      page.value = 1;
      hasMore.value = true;
    }
    if (!hasMore.value && !refresh) return;

    try {
      debugPrint('[UsersController] fetchUsers: calling ${ApiConstants.search} (page: ${page.value})');
      
      // 1. Fetch from search for a broad "Explore" experience
      final searchResponse = await _api.get(ApiConstants.search, queryParameters: {
        'page': page.value,
        'limit': 20,
      });
      
      final searchData = searchResponse.data;
      debugPrint('[UsersController] fetchUsers: raw search response: $searchData');
      
      List<dynamic> searchList = [];
      if (searchData is Map && searchData['users'] != null) {
        searchList = searchData['users'];
      } else if (searchData is Map && searchData['data'] != null && searchData['data'] is List) {
        // Fallback for different envelope
        searchList = searchData['data'];
      } else if (searchData is List) {
        searchList = searchData;
      }
      
      final users = searchList
          .whereType<Map<String, dynamic>>()
          .map((u) => UserModel.fromJson(u))
          .toList();

      if (refresh || page.value == 1) {
        allUsers.value = users;
      } else {
        allUsers.addAll(users);
      }

      // 2. Supplement with specialized discovery categories (only on refresh/first page)
      if (refresh || page.value == 1) {
        try {
          debugPrint('[UsersController] fetchUsers: supplementing with ${ApiConstants.discoverCategories}');
          final discoveryResponse = await _api.get(ApiConstants.discoverCategories);
          final discoveryData = discoveryResponse.data;
          
          if (discoveryData is Map) {
            // Parse nearby if available
            if (discoveryData['nearby'] != null) {
              final nearbyList = discoveryData['nearby']['users'] ?? [];
              nearbyUsers.value = (nearbyList as List).map((u) => UserModel.fromJson(u)).toList();
            }
            
            // If allUsers is still empty for some reason, take discovery users
            if (allUsers.isEmpty && discoveryData['users'] != null) {
              final discUsers = (discoveryData['users'] as List).map((u) => UserModel.fromJson(u)).toList();
              allUsers.value = discUsers;
            }
          }
        } catch (e) {
          debugPrint('[UsersController] Supplementing discovery failed: $e');
        }
      }

      // Derive live-today (online within last 24h)
      liveTodayUsers.value = allUsers.where((u) =>
          u.lastLoginAt != null &&
          DateTime.now().difference(u.lastLoginAt!).inHours < 24).toList();

      hasMore.value = users.length >= 20;
      page.value++;
    } catch (e, stackTrace) {
      if (refresh) hasError.value = true;
      debugPrint('[UsersController] fetchUsers CRITICAL ERROR: $e');
      debugPrint('[UsersController] stackTrace: $stackTrace');
      // Show snackbar for visible feedback during debug
      if (kDebugMode) {
        Get.snackbar('Load Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
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
      final data = response.data;
      final list = (data is Map && data.containsKey('data')) ? data['data'] : (data is List ? data : []);
      backendCategories.value = (list as List).map((c) => CategoryModel.fromJson(c)).toList();
    } catch (_) {}
  }

  // ─── Matches ───────────────────────────────────────────
  Future<void> fetchMatches() async {
    try {
      final response = await _api.get(ApiConstants.matches);
      final data = response.data;
      final list = data is List ? data : (data is Map ? (data['users'] ?? data) : []);
      if (list is List) {
        matches.assignAll(list.map((u) => UserModel.fromJson(u)).toList());
        debugPrint('[UsersController] Found ${matches.length} matches');
      }
    } catch (e) {
      debugPrint('[UsersController] fetchMatches error: $e');
    }
  }

  // ─── Who Liked Me ──────────────────────────────────────
  Future<void> fetchWhoLikedMe() async {
    try {
      final response = await _api.get(ApiConstants.whoLikedMe);
      final data = response.data;
      final list = data is List ? data : (data is Map ? (data['users'] ?? data) : []);
      if (list is List) {
        final users = list.map((item) {
          if (item is Map && item.containsKey('user')) {
             return UserModel.fromJson(item['user']);
          }
          return UserModel.fromJson(item);
        }).toList();
        likesReceived.assignAll(users);
        debugPrint('[UsersController] Found ${likesReceived.length} users who liked me');
      }
    } catch (e) {
      debugPrint('[UsersController] fetchWhoLikedMe error: $e');
    }
  }

  // ─── Success Stories ──────────────────────────────────
  Future<void> fetchSuccessStories() async {
    try {
      isLoadingStories.value = true;
      final response = await _api.get(ApiConstants.successStories);
      final list = response.data is List ? response.data : response.data['stories'] ?? [];
      successStories.value = (list as List).map((s) => SuccessStoryModel.fromJson(s)).toList();
    } catch (e) {
      debugPrint('[UsersController] fetchSuccessStories error: $e');
    } finally {
      isLoadingStories.value = false;
    }
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

  /// Opens user detail by fetching the profile from backend.
  Future<void> openUserDetailById(String userId) async {
    // Show loading
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      final response = await _api.get(ApiConstants.profileByUserId(userId));
      Get.back(); // Remove loading

      if (response.statusCode == 200) {
        final profileJson = response.data;
        final userJson = profileJson['user'];
        if (userJson != null) {
          userJson['profile'] = profileJson; // merge
          final user = UserModel.fromJson(userJson);
          openUserDetail(user);
        } else {
          Get.snackbar('error'.tr, 'user_not_found'.tr);
        }
      }
    } catch (e) {
      Get.back();
      debugPrint('[UsersController] openUserDetailById error: $e');
      Get.snackbar('error'.tr, 'user_not_found'.tr);
    }
  }

  void openCategory(CategoryModel cat) {
    Get.toNamed(AppRoutes.categoryUsers, arguments: {'category': cat});
  }

  Future<void> refreshUsers() async {
    await _loadAll();
  }

  void loadMore() => fetchUsers();
}
