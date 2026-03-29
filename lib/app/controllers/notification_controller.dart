import 'package:get/get.dart';
import 'package:methna_app/app/data/services/notification_service.dart';
import 'package:methna_app/app/data/models/notification_model.dart';

class NotificationController extends GetxController {
  final NotificationService _service = Get.find<NotificationService>();

  RxList<NotificationModel> get _allNotifications => _service.notifications;
  RxBool isLoading = false.obs;
  final RxString selectedCategory = 'all'.obs;

  List<NotificationModel> get notifications {
    if (selectedCategory.value == 'all') return _allNotifications;
    return _allNotifications.where((n) => n.type == selectedCategory.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    refreshNotifications();
  }

  Future<void> refreshNotifications() async {
    isLoading.value = true;
    try {
      // Logic to trigger refresh in service if needed
      // For now we assume the service is already fetching/listening
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(String id) {
    // Delegation to service
  }

  /// Count of unread notifications
  RxInt get unreadCount => RxInt(
    _allNotifications.where((n) => !n.isRead).length,
  );

  /// Mark all notifications as read
  void markAllAsRead() {
    final updated = _allNotifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    _allNotifications.assignAll(updated);
  }
}
