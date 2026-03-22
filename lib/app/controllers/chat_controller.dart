import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/data/services/socket_service.dart';
import 'package:methna_app/app/data/services/notification_service.dart';
import 'package:methna_app/app/data/models/conversation_model.dart';
import 'package:methna_app/app/data/models/message_model.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/bad_words_filter.dart';
import 'package:methna_app/core/utils/input_sanitizer.dart';

class ChatController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();
  final SocketService _socket = Get.find<SocketService>();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<UserModel> onlineTodayUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Active chat state
  final RxList<MessageModel> activeMessages = <MessageModel>[].obs;
  final Rx<ConversationModel?> activeConversation = Rx<ConversationModel?>(null);
  final RxBool isTyping = false.obs;
  final RxBool messagesLoading = false.obs;

  // Read receipts: maps messageId → read status
  final RxMap<String, bool> readReceipts = <String, bool>{}.obs;

  // Online presence: maps userId → online status
  final RxMap<String, bool> onlinePresence = <String, bool>{}.obs;

  // Typing debounce to avoid spamming the server
  Timer? _typingDebounce;

  // Debounce for conversation list refresh
  Timer? _fetchConversationsDebounce;

  // Message input controller (managed here to avoid leak in build())
  final TextEditingController messageTextController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    _typingDebounce?.cancel();
    _fetchConversationsDebounce?.cancel();
    messageTextController.dispose();
    super.onClose();
  }

  // ─── Socket listeners ──────────────────────────────────────────
  void _setupSocketListeners() {
    _socket.onNewMessage((data) {
      final msg = MessageModel.fromJson(data);
      // If in active conversation, add message and mark read
      if (activeConversation.value?.id == msg.conversationId) {
        activeMessages.insert(0, msg);
        _socket.markAsRead(msg.conversationId);
      }
      // Debounced refresh to avoid hammering API on rapid messages
      _debouncedFetchConversations();
    });

    _socket.onTyping((data) {
      final convId = data['conversationId'];
      if (activeConversation.value?.id == convId) {
        isTyping.value = true;
        Future.delayed(const Duration(seconds: 3), () => isTyping.value = false);
      }
    });

    // Read receipts from remote user (backend emits 'messagesRead')
    _socket.on('messagesRead', (data) {
      final convId = data['conversationId'] as String?;
      if (convId != null && activeConversation.value?.id == convId) {
        // Mark all sent messages in this conversation as read
        for (int i = 0; i < activeMessages.length; i++) {
          if (!activeMessages[i].isRead) {
            // Trigger reactive update
            activeMessages.refresh();
            break;
          }
        }
      }
    });

    // Presence tracking
    _socket.onUserOnline((data) {
      final userId = data['userId'] as String?;
      if (userId != null) onlinePresence[userId] = true;
    });

    _socket.onUserOffline((data) {
      final userId = data['userId'] as String?;
      if (userId != null) onlinePresence[userId] = false;
    });

    // New match — refresh conversations so the new match appears
    _socket.onNewMatch((data) {
      fetchConversations();
      // Navigate to match screen if data contains matched user info
      if (data != null && data['matchedUser'] != null) {
        try {
          final matchedUser = UserModel.fromJson(data['matchedUser']);
          Get.toNamed(AppRoutes.matchFound, arguments: {'user': matchedUser});
        } catch (_) {}
      }
    });

    // New notification — trigger notification service refresh
    _socket.onNewNotification((data) {
      try {
        Get.find<NotificationService>().fetchNotifications();
      } catch (_) {}
    });
  }

  // ─── Conversations ─────────────────────────────────────────────
  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final response = await _api.get(ApiConstants.conversations);
      final list = response.data is List ? response.data : response.data['conversations'] ?? [];
      final userId = _auth.userId;
      conversations.value = (list as List)
          .map((c) => ConversationModel.fromJson(c, currentUserId: userId))
          .toList();

      // Extract online users from conversations
      onlineTodayUsers.value = conversations
          .where((c) => c.otherUser?.isOnline == true)
          .map((c) => c.otherUser!)
          .toList();
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> openConversation(ConversationModel conversation) async {
    activeConversation.value = conversation;
    activeMessages.clear();
    _socket.joinConversation(conversation.id);
    Get.toNamed(AppRoutes.chatDetail, arguments: {'conversation': conversation});
    await fetchMessages(conversation.id);
  }

  Future<void> fetchMessages(String conversationId, {int page = 1}) async {
    messagesLoading.value = true;
    try {
      final response = await _api.get(
        ApiConstants.conversationMessages(conversationId),
        queryParameters: {'page': page, 'limit': 50},
      );
      final list = response.data is List ? response.data : response.data['messages'] ?? [];
      final msgs = (list as List).map((m) => MessageModel.fromJson(m)).toList();
      if (page == 1) {
        activeMessages.value = msgs;
      } else {
        activeMessages.addAll(msgs);
      }
      _socket.markAsRead(conversationId);
    } catch (_) {}
    finally {
      messagesLoading.value = false;
    }
  }

  // ─── Send text message with sanitization & bad-words filter ────
  void sendMessage(String content) {
    if (content.trim().isEmpty || activeConversation.value == null) return;

    // Sanitize and censor the message before sending
    String sanitized = InputSanitizer.sanitize(content);
    sanitized = BadWordsFilter.censor(sanitized);

    _socket.sendMessage(activeConversation.value!.id, sanitized);
  }

  // ─── Send image message ────────────────────────────────────────
  Future<void> sendImageMessage() async {
    if (activeConversation.value == null) return;
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image == null) return;

      final formData = dio.FormData.fromMap({
        'conversationId': activeConversation.value!.id,
        'image': await dio.MultipartFile.fromFile(image.path, filename: image.name),
      });

      await _api.upload(ApiConstants.sendImageMessage, formData);
    } catch (_) {
      Get.snackbar('Error', 'Failed to send image');
    }
  }

  // ─── Typing indicator with debounce ────────────────────────────
  void sendTypingIndicator() {
    if (activeConversation.value == null) return;

    // Only emit once per 2 seconds to avoid spamming
    if (_typingDebounce?.isActive ?? false) return;
    _socket.sendTyping(activeConversation.value!.id);
    _typingDebounce = Timer(const Duration(seconds: 2), () {});
  }

  // ─── Leave active chat ─────────────────────────────────────────
  void leaveActiveChat() {
    if (activeConversation.value != null) {
      _socket.leaveConversation(activeConversation.value!.id);
      activeConversation.value = null;
      activeMessages.clear();
    }
  }

  // ─── Debounced conversation refresh ─────────────────────────────
  void _debouncedFetchConversations() {
    _fetchConversationsDebounce?.cancel();
    _fetchConversationsDebounce = Timer(const Duration(seconds: 2), () {
      fetchConversations();
    });
  }

  // ─── Helpers ───────────────────────────────────────────────────
  int get totalUnread => conversations.fold(0, (sum, c) =>
      sum + c.unreadCount(_auth.userId ?? ''));

  /// Check if a user is currently online via presence map.
  bool isUserOnline(String userId) => onlinePresence[userId] ?? false;

  /// Check if a message has been read by the recipient.
  bool isMessageRead(String messageId) => readReceipts[messageId] ?? false;

  void searchConversations(String query) {
    searchQuery.value = query;
  }

  List<ConversationModel> get filteredConversations {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return conversations;
    return conversations.where((c) {
      final name = c.otherUser?.firstName?.toLowerCase() ?? '';
      return name.contains(q);
    }).toList();
  }
}
