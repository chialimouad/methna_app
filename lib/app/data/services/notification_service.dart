import 'package:get/get.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/models/notification_model.dart';

class NotificationService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  Future<NotificationService> init() async {
    return this;
  }

  Future<void> fetchNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get(ApiConstants.notifications, queryParameters: {
        'page': page,
        'limit': limit,
      });
      final list = (response.data is List ? response.data : response.data['notifications'] ?? []) as List;
      notifications.value = list.map((n) => NotificationModel.fromJson(n)).toList();
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (_) {}
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _api.get(ApiConstants.notificationsUnreadCount);
      unreadCount.value = response.data['unreadCount'] ?? 0;
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.patch(ApiConstants.markNotificationRead(notificationId));
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !notifications[index].isRead) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.patch(ApiConstants.markAllNotificationsRead);
      unreadCount.value = 0;
    } catch (_) {}
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _api.delete(ApiConstants.deleteNotification(notificationId));
      notifications.removeWhere((n) => n.id == notificationId);
    } catch (_) {}
  }
}
