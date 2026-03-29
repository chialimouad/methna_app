import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/models/notification_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/app/controllers/chat_controller.dart';
import 'package:methna_app/app/controllers/users_controller.dart';

class NotificationService extends GetxService {
  final ApiService _api = Get.find<ApiService>();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool hasUnreadNotifications = false.obs;
  
  // Filtering logic
  final RxString selectedCategory = 'all'.obs;
  final List<String> categories = ['all', 'matches', 'likes', 'dislikes', 'messages', 'new match', 'system'];

  Future<NotificationService> init() async {
    await _initializeLocalNotifications();
    return this;
  }

  // Initialize local notifications only
  Future<void> _initializeLocalNotifications() async {
    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create notification channel for Android
      await _createNotificationChannel();
      
      // Fetch unread count on startup (with error handling)
      try {
        await fetchUnreadCount();
      } catch (e) {
        debugPrint('[Notification] Failed to fetch unread count: $e');
      }
    } catch (e) {
      debugPrint('[Notification] Error initializing local notifications: $e');
      // Don't rethrow - allow app to continue even if notifications fail
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    } catch (e) {
      debugPrint('[Notification] Failed to create notification channel: $e');
    }
  }

  // Handle notification tap (from system tray/local)
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[Notification] Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        final notification = NotificationModel.fromJson(data);
        handleNotificationClick(notification);
      } catch (e) {
        debugPrint('[Notification] Error parsing tap payload: $e');
        Get.toNamed(AppRoutes.notifications);
      }
    }
  }

  /// Handles clicking a notification (from UI or system tray).
  void handleNotificationClick(NotificationModel notification) {
    // 1. Mark as read on backend
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // 2. Extract data
    final type = notification.type.toLowerCase();
    final data = notification.data;
    debugPrint('[Notification] Handling click for type: $type, data: $data');

    // 3. Navigate
    try {
      switch (type) {
        case 'message':
          final convId = data?['conversationId'] as String?;
          if (convId != null) {
            Get.find<ChatController>().openConversationById(convId);
          } else {
            Get.toNamed(AppRoutes.chat);
          }
          break;

        case 'match':
          // The backend sends matchId and userId in data
          final matchId = data?['matchId'] as String?;
          if (matchId != null) {
            Get.find<ChatController>().openConversationById(matchId);
          } else {
            Get.toNamed(AppRoutes.matchFound);
          }
          break;

        case 'like':
        case 'super_like':
        case 'compliment':
          // Backend uses likerId or requesterId
          final targetUserId = (data?['likerId'] ?? 
                                data?['requesterId'] ?? 
                                data?['userId']) as String?;
          if (targetUserId != null) {
            Get.find<UsersController>().openUserDetailById(targetUserId);
          } else {
            Get.toNamed(AppRoutes.whoLikedMe * 1 == 1 ? AppRoutes.notifications : AppRoutes.notifications); // Fallback
          }
          break;

        case 'rematch':
          Get.toNamed(AppRoutes.notifications);
          break;

        default:
          // Stay on current or go to notifications
          if (Get.currentRoute != AppRoutes.notifications) {
            Get.toNamed(AppRoutes.notifications);
          }
          break;
      }
    } catch (e) {
      debugPrint('[Notification] Navigation error: $e');
      Get.toNamed(AppRoutes.notifications);
    }
  }

  // Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: data != null ? jsonEncode({'type': type, ...data}) : null,
      );
    } catch (e) {
      debugPrint('[Notification] Failed to show notification: $e');
    }
  }

  // Fetch notifications from API
  Future<void> fetchNotifications() async {
    try {
      final response = await _api.get(ApiConstants.notifications);
      if (response.data != null && response.data is List) {
        final List<NotificationModel> fetchedNotifications = (response.data as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        
        notifications.assignAll(fetchedNotifications);
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('[Notification] Failed to fetch notifications: $e');
    }
  }

  // Fetch unread count from API
  Future<void> fetchUnreadCount() async {
    final route = Get.currentRoute;
    if (route.contains('signup') || route == AppRoutes.splash || route == '') {
       return; // Skip during signup/splash
    }

    try {
      final response = await _api.get(ApiConstants.notificationsUnreadCount);
      if (response.data != null && response.data['count'] != null) {
        unreadCount.value = response.data['count'];
        hasUnreadNotifications.value = unreadCount.value > 0;
      }
    } catch (e) {
      debugPrint('[Notification] Failed to fetch unread count: $e');
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    // 1. Update local state immediately (Optimistic UI)
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
      _updateUnreadCount();
    }

    try {
      await _api.patch('${ApiConstants.notifications}/$notificationId/read');
    } catch (e) {
      debugPrint('[Notification] Failed to mark notification as read on server: $e');
      // Optional: Revert if failed
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _api.patch(ApiConstants.markAllNotificationsRead);
      
      // Update local state
      notifications.value = notifications.map((notification) => 
        notification.copyWith(isRead: true)
      ).toList();
      notifications.refresh();
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;
    } catch (e) {
      debugPrint('[Notification] Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _api.delete('${ApiConstants.notifications}/$notificationId');
      
      // Update local state
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      debugPrint('[Notification] Failed to delete notification: $e');
    }
  }

  // Update unread count based on local notifications
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
    hasUnreadNotifications.value = unreadCount.value > 0;
  }

  // Get filtered notifications
  List<NotificationModel> get filteredNotifications {
    if (selectedCategory.value == 'all') return notifications;
    
    return notifications.where((n) {
      final type = n.type.toLowerCase();
      switch (selectedCategory.value) {
        case 'matches': return type == 'match';
        case 'likes': return type == 'like' || type == 'super_like';
        case 'dislikes': return type == 'dislike';
        case 'messages': return type == 'message';
        case 'new match': return type == 'match';
        case 'system': return type == 'system' || type == 'subscription' || type == 'verification';
        default: return true;
      }
    }).toList();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // Open notifications screen
  void openNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  // Clear all notifications
  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
    hasUnreadNotifications.value = false;
  }
}
