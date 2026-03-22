import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/app/data/services/storage_service.dart';
import 'package:methna_app/app/data/services/notification_service.dart';
import 'package:methna_app/app/data/models/notification_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SocketService extends GetxService {
  io.Socket? _chatSocket;
  io.Socket? _notifSocket;
  final StorageService _storage = Get.find<StorageService>();
  final RxBool isConnected = false.obs;

  Future<SocketService> init() async {
    return this;
  }

  Future<void> connect() async {
    final token = await _storage.getToken();
    if (token == null) return;

    // ─── Chat Socket (default namespace) ─────────────────
    _chatSocket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _chatSocket!.onConnect((_) {
      isConnected.value = true;
    });

    _chatSocket!.onDisconnect((_) {
      isConnected.value = false;
    });

    _chatSocket!.onConnectError((_) {
      isConnected.value = false;
    });

    // ─── Notification Socket (/notifications namespace) ──
    _notifSocket = io.io(
      '${ApiConstants.socketUrl}/notifications',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _notifSocket!.on('notification', _handleRealtimeNotification);
    _notifSocket!.on('pendingNotifications', _handlePendingNotifications);
  }

  void disconnect() {
    _chatSocket?.disconnect();
    _chatSocket?.dispose();
    _chatSocket = null;
    _notifSocket?.disconnect();
    _notifSocket?.dispose();
    _notifSocket = null;
    isConnected.value = false;
  }

  // ─── Real-time Notification Handlers ───────────────────
  void _handleRealtimeNotification(dynamic data) {
    if (data == null) return;
    try {
      final notif = NotificationModel.fromJson(data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data));
      // Update service list
      if (Get.isRegistered<NotificationService>()) {
        final service = Get.find<NotificationService>();
        service.notifications.insert(0, notif);
        service.unreadCount.value++;
      }
      // Show in-app toast
      _showNotificationToast(notif);
    } catch (_) {}
  }

  void _handlePendingNotifications(dynamic data) {
    if (data == null || data is! List) return;
    try {
      if (Get.isRegistered<NotificationService>()) {
        final service = Get.find<NotificationService>();
        final pending = data.map((n) => NotificationModel.fromJson(
          n is Map<String, dynamic> ? n : Map<String, dynamic>.from(n),
        )).toList();
        // Merge: add any we don't already have
        for (final n in pending) {
          if (!service.notifications.any((e) => e.id == n.id)) {
            service.notifications.add(n);
          }
        }
        service.notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        service.unreadCount.value = service.notifications.where((n) => !n.isRead).length;
      }
    } catch (_) {}
  }

  void _showNotificationToast(NotificationModel notif) {
    final icon = _notifIcon(notif.type);
    Get.snackbar(
      notif.title,
      notif.body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.surfaceLight,
      colorText: AppColors.textPrimaryLight,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      borderRadius: 16,
      duration: const Duration(seconds: 4),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'match': return LucideIcons.heart;
      case 'like': return LucideIcons.heartHandshake;
      case 'message': return LucideIcons.messageSquare;
      case 'subscription': return LucideIcons.crown;
      case 'profile_view': return LucideIcons.eye;
      case 'verification': return LucideIcons.shieldCheck;
      default: return LucideIcons.bell;
    }
  }

  // ─── Chat Emit Events ─────────────────────────────────────
  void emit(String event, [dynamic data]) {
    _chatSocket?.emit(event, data);
  }

  void sendMessage(String conversationId, String content) {
    emit('sendMessage', {
      'conversationId': conversationId,
      'content': content,
    });
  }

  void joinConversation(String conversationId) {
    emit('joinConversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    emit('leaveConversation', {'conversationId': conversationId});
  }

  void sendTyping(String conversationId) {
    emit('typing', {'conversationId': conversationId});
  }

  void markAsRead(String conversationId) {
    emit('markRead', {'conversationId': conversationId});
  }

  // ─── Chat Listen Events ───────────────────────────────────
  void on(String event, Function(dynamic) callback) {
    _chatSocket?.on(event, callback);
  }

  void off(String event) {
    _chatSocket?.off(event);
  }

  void onNewMessage(Function(dynamic) callback) => on('newMessage', callback);
  void onTyping(Function(dynamic) callback) => on('typing', callback);
  void onUserOnline(Function(dynamic) callback) => on('userOnline', callback);
  void onUserOffline(Function(dynamic) callback) => on('userOffline', callback);
  void onNewMatch(Function(dynamic) callback) => on('newMatch', callback);
  void onNewNotification(Function(dynamic) callback) => on('notification', callback);
}
