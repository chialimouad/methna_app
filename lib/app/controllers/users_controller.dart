import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';

class UsersController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> newUsers = <UserModel>[].obs;
  final RxList<UserModel> nearbyUsers = <UserModel>[].obs;
  final RxList<UserModel> onlineUsers = <UserModel>[].obs;
  final RxList<UserModel> verifiedUsers = <UserModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString selectedCategory = 'all'.obs;
  final RxInt page = 1.obs;
  final RxBool hasMore = true.obs;

  final List<String> categories = ['all', 'new', 'nearby', 'online', 'verified', 'popular'];

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      page.value = 1;
      hasMore.value = true;
    }
    if (!hasMore.value && !refresh) return;

    isLoading.value = true;
    hasError.value = false;
    try {
      final response = await _api.get(ApiConstants.discoverCategories, queryParameters: {
        'page': page.value,
        'limit': 20,
      });
      final list = response.data is List ? response.data : response.data['users'] ?? [];
      final users = (list as List).map((u) => UserModel.fromJson(u)).toList();

      if (refresh || page.value == 1) {
        allUsers.value = users;
      } else {
        allUsers.addAll(users);
      }

      // Categorize
      newUsers.value = allUsers.where((u) =>
          u.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();
      onlineUsers.value = allUsers.where((u) => u.isOnline).toList();
      verifiedUsers.value = allUsers.where((u) => u.selfieVerified).toList();

      hasMore.value = users.length >= 20;
      page.value++;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNearbyUsers() async {
    try {
      final response = await _api.get(ApiConstants.nearbyUsers);
      final list = response.data is List ? response.data : response.data['users'] ?? [];
      nearbyUsers.value = (list as List).map((u) => UserModel.fromJson(u)).toList();
    } catch (_) {}
  }

  List<UserModel> get filteredUsers {
    switch (selectedCategory.value) {
      case 'new':
        return newUsers;
      case 'nearby':
        return nearbyUsers;
      case 'online':
        return onlineUsers;
      case 'verified':
        return verifiedUsers;
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

  Future<void> refreshUsers() => fetchUsers(refresh: true);
  void loadMore() => fetchUsers();
}
