import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/data/services/socket_service.dart';
import 'package:methna_app/app/data/services/notification_service.dart';
import 'package:methna_app/app/data/services/message_queue_service.dart';
import 'package:methna_app/app/data/models/conversation_model.dart';
import 'package:methna_app/app/data/models/message_model.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/bad_words_filter.dart';
import 'package:methna_app/core/utils/input_sanitizer.dart';

/// Message delivery status for optimistic UI
enum MessageStatus { pending, sent, delivered, read, failed }

class ChatController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();
  final SocketService _socket = Get.find<SocketService>();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<UserModel> onlineTodayUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString searchQuery = ''.obs;

  // Active chat state
  final RxList<MessageModel> activeMessages = <MessageModel>[].obs;
  final Rx<ConversationModel?> activeConversation = Rx<ConversationModel?>(null);
  final RxBool isTyping = false.obs;
  final RxBool messagesLoading = false.obs;

  // Ice breaker suggestions
  final RxList<String> iceBreakers = <String>[].obs;

  // Read receipts: maps messageId → read status
  final RxMap<String, bool> readReceipts = <String, bool>{}.obs;

  // Online presence: maps userId → online status
  final RxMap<String, bool> onlinePresence = <String, bool>{}.obs;

  // Message status tracking for optimistic UI: clientMsgId → status
  final RxMap<String, MessageStatus> messageStatuses = <String, MessageStatus>{}.obs;

  // Sent message IDs to prevent duplicates
  final Set<String> _sentMessageIds = {};

  // Client message ID to server message ID mapping
  final Map<String, String> _clientToServerIds = {};

  // Typing debounce to avoid spamming the server
  Timer? _typingDebounce;

  // Debounce for conversation list refresh
  Timer? _fetchConversationsDebounce;

  // Message input controller (managed here to avoid leak in build())
  final TextEditingController messageTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    fetchLiveTodayUsers();
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
      if (data == null || data is! Map) return;
      final convId = data['conversationId'] as String?;
      if (convId != null && activeConversation.value?.id == convId) {
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
    if (isLoading.value) return; // Prevent duplicate calls
    isLoading.value = true;
    hasError.value = false;
    try {
      debugPrint('[ChatController] fetchConversations: calling ${ApiConstants.conversations}');
      final response = await _api.get(ApiConstants.conversations);
      final data = response.data;
      debugPrint('[ChatController] fetchConversations: response type=${data.runtimeType} data: $data');

      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = data['conversations'] ?? [];
      } else {
        list = [];
      }

      final userId = _auth.userId;
      conversations.value = list
          .whereType<Map<String, dynamic>>()
          .map((c) => ConversationModel.fromJson(c, currentUserId: userId))
          .toList();
      debugPrint('[ChatController] fetchConversations: Parsed ${conversations.length} conversations');

      // Extract online users from conversations
      onlineTodayUsers.value = conversations
          .where((c) => c.otherUser?.isOnline == true)
          .map((c) => c.otherUser!)
          .toList();
    } catch (e, stackTrace) {
      hasError.value = true;
      debugPrint('[ChatController] fetchConversations CRITICAL ERROR: $e');
      debugPrint('[ChatController] stackTrace: $stackTrace');
      if (kDebugMode) {
        Get.snackbar('Chat Load Error', e.toString());
      }
    }
    finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLiveTodayUsers() async {
    try {
      final response = await _api.get(ApiConstants.discoverCategories);
      final data = response.data;
      
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = data['users'] ?? [];
      } else {
        list = [];
      }

      final users = list
          .whereType<Map<String, dynamic>>()
          .map((u) => UserModel.fromJson(u))
          .toList();

      // Show users online now or active within last 24h
      onlineTodayUsers.value = users.where((u) => 
        u.isOnline || (u.lastLoginAt != null && DateTime.now().difference(u.lastLoginAt!).inHours < 24)
      ).take(15).toList();
      
    } catch (e) {
      debugPrint('[ChatController] fetchLiveTodayUsers error: $e');
    }
  }

  Future<void> openConversation(ConversationModel conversation) async {
    activeConversation.value = conversation;
    activeMessages.clear();
    iceBreakers.clear();
    _socket.joinConversation(conversation.id);
    Get.toNamed(AppRoutes.chatDetail, arguments: {'conversation': conversation});
    await fetchMessages(conversation.id);
    // Fetch ice breakers if no messages yet
    if (activeMessages.isEmpty && conversation.otherUser != null) {
      _fetchIceBreakers(conversation.otherUser!.id);
    }
  }

  /// Opens a conversation by ID, fetching it if necessary.
  Future<void> openConversationById(String conversationId) async {
    var conv = conversations.firstWhereOrNull((c) => c.id == conversationId);
    if (conv == null) {
      // Show loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      try {
        await fetchConversations();
        Get.back(); // Remove loading
        conv = conversations.firstWhereOrNull((c) => c.id == conversationId);
      } catch (e) {
        Get.back();
      }
    }

    if (conv != null) {
      openConversation(conv);
    } else {
      Get.snackbar('error'.tr, 'conversation_not_found'.tr);
    }
  }

  /// Finds or creates a conversation with a specific user and navigates to it.
  Future<void> openConversationWithUser(UserModel user) async {
    // 1. Check if we already have a conversation with this user
    final existing = conversations.firstWhereOrNull((c) => c.otherUser?.id == user.id);
    if (existing != null) {
      return openConversation(existing);
    }

    // 2. If not, try to create one (or fetch it if backend creates on match)
    isLoading.value = true;
    try {
      final response = await _api.post(ApiConstants.conversations, data: {
        'targetUserId': user.id,
      });
      final conv = ConversationModel.fromJson(response.data, currentUserId: _auth.userId);
      
      // Update local list
      if (!conversations.any((c) => c.id == conv.id)) {
        conversations.insert(0, conv);
      }
      
      return openConversation(conv);
    } catch (e) {
      debugPrint('[ChatController] openConversationWithUser error: $e');
      // Fallback: If creation fails, we might not be allowed to chat yet (not a match)
      Get.snackbar('Cannot chat', 'You can only message people you have matched with.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchIceBreakers(String targetUserId) async {
    try {
      final response = await _api.get(ApiConstants.iceBreakers(targetUserId));
      if (response.data is List) {
        iceBreakers.value = List<String>.from(response.data);
      }
    } catch (_) {}
  }

  void sendIceBreaker(String text) {
    sendMessage(text);
    iceBreakers.clear();
  }

  Future<void> fetchMessages(String conversationId, {int page = 1}) async {
    messagesLoading.value = true;
    try {
      debugPrint('[ChatController] fetchMessages: calling ${ApiConstants.conversationMessages(conversationId)} page=$page');
      final response = await _api.get(
        ApiConstants.conversationMessages(conversationId),
        queryParameters: {'page': page, 'limit': 50},
      );
      final data = response.data;
      debugPrint('[ChatController] fetchMessages: response type=${data.runtimeType} data: $data');

      final list = data is List ? data : data['messages'] ?? [];
      final msgs = (list as List).map((m) => MessageModel.fromJson(m)).toList();
      debugPrint('[ChatController] fetchMessages: Parsed ${msgs.length} messages for conversation $conversationId');
      
      // Sort newest first for reversed ListView (index 0 is at the bottom)
      msgs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (page == 1) {
        activeMessages.assignAll(msgs);
      } else {
        activeMessages.addAll(msgs);
        activeMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      _socket.markAsRead(conversationId);
    } catch (e) {
      debugPrint('[ChatController] fetchMessages error: $e');
    }
    finally {
      messagesLoading.value = false;
    }
  }

  // ─── UUID Generator ─────────────────────────────────────────────
  String _generateUUID() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  // ─── Send text message with sanitization & bad-words filter ────
  void sendMessage(String content) {
    if (content.trim().isEmpty || activeConversation.value == null) return;

    // Sanitize and censor the message before sending
    String sanitized = InputSanitizer.sanitize(content);
    sanitized = BadWordsFilter.censor(sanitized);

    // Generate unique client message ID (UUID) to prevent duplicates
    final clientMsgId = _generateUUID();

    // Check for duplicate (same content sent within 5 seconds)
    if (_isDuplicateMessage(activeConversation.value!.id, sanitized)) {
      debugPrint('[Chat] Duplicate message blocked');
      return;
    }

    // Track this message
    _sentMessageIds.add(clientMsgId);
    messageStatuses[clientMsgId] = MessageStatus.pending;

    // Optimistic local insert so user sees their message immediately
    final optimisticMsg = MessageModel(
      id: clientMsgId,
      conversationId: activeConversation.value!.id,
      senderId: _auth.userId ?? '',
      content: sanitized,
      createdAt: DateTime.now(),
      isRead: false,
    );
    activeMessages.insert(0, optimisticMsg);

    // Check if socket is connected
    final socket = Get.find<SocketService>();
    final queue = Get.find<MessageQueueService>();
    
    if (socket.isConnected.value) {
      // Online: send directly with client ID for tracking
      _socket.sendMessageWithId(activeConversation.value!.id, sanitized, clientMsgId);
      messageStatuses[clientMsgId] = MessageStatus.sent;
    } else {
      // Offline: enqueue for later sending
      queue.enqueue(activeConversation.value!.id, sanitized);
      messageStatuses[clientMsgId] = MessageStatus.pending;
      debugPrint('[Chat] Socket offline - message queued for later');
    }
    
    _debouncedFetchConversations();
  }

  // ─── Duplicate Detection ───────────────────────────────────────
  bool _isDuplicateMessage(String conversationId, String content) {
    // Check if same message was sent in last 5 seconds
    final recentMessages = activeMessages.where((m) =>
        m.conversationId == conversationId &&
        m.content == content &&
        m.senderId == _auth.userId &&
        DateTime.now().difference(m.createdAt).inSeconds < 5);
    return recentMessages.isNotEmpty;
  }

  // ─── Update Message Status (called when server confirms) ───────
  void updateMessageStatus(String clientMsgId, MessageStatus status, {String? serverId}) {
    messageStatuses[clientMsgId] = status;
    
    if (serverId != null) {
      _clientToServerIds[clientMsgId] = serverId;
      // Replace optimistic message with server-confirmed one
      final index = activeMessages.indexWhere((m) => m.id == clientMsgId);
      if (index != -1) {
        final msg = activeMessages[index];
        activeMessages[index] = MessageModel(
          id: serverId,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          content: msg.content,
          createdAt: msg.createdAt,
          isRead: msg.isRead,
        );
      }
    }
    activeMessages.refresh();
  }

  // ─── Retry Failed Message ──────────────────────────────────────
  void retryMessage(String clientMsgId) {
    final msg = activeMessages.firstWhereOrNull((m) => m.id == clientMsgId);
    if (msg == null) return;

    messageStatuses[clientMsgId] = MessageStatus.pending;
    
    final socket = Get.find<SocketService>();
    if (socket.isConnected.value) {
      _socket.sendMessageWithId(msg.conversationId, msg.content, clientMsgId);
      messageStatuses[clientMsgId] = MessageStatus.sent;
    } else {
      final queue = Get.find<MessageQueueService>();
      queue.enqueue(msg.conversationId, msg.content);
    }
    activeMessages.refresh();
  }

  // ─── Get Message Status ────────────────────────────────────────
  MessageStatus getMessageStatus(String messageId) {
    return messageStatuses[messageId] ?? MessageStatus.delivered;
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
