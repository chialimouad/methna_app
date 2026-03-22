import 'user_model.dart';

class ConversationModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? matchId;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;
  final int user1UnreadCount;
  final int user2UnreadCount;
  final bool isActive;
  final DateTime createdAt;
  final UserModel? otherUser;

  ConversationModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.matchId,
    this.lastMessageContent,
    this.lastMessageAt,
    this.user1UnreadCount = 0,
    this.user2UnreadCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.otherUser,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    UserModel? other;

    // Handle enriched backend response format (otherUser directly provided)
    if (json['otherUser'] != null) {
      other = UserModel.fromJson(json['otherUser']);
    }
    // Fallback: determine otherUser from user1/user2 raw objects
    else if (json['user1'] != null && json['user2'] != null && currentUserId != null) {
      final u1 = UserModel.fromJson(json['user1']);
      final u2 = UserModel.fromJson(json['user2']);
      other = u1.id == currentUserId ? u2 : u1;
    }

    // Handle both direct fields and enriched format for unread/lastMessage
    final int unread1 = json['user1UnreadCount'] ?? 0;
    final int unread2 = json['user2UnreadCount'] ?? 0;
    final int enrichedUnread = json['unreadCount'] ?? 0;

    return ConversationModel(
      id: json['id'] ?? '',
      user1Id: json['user1Id'] ?? json['otherUser']?['id'] ?? '',
      user2Id: json['user2Id'] ?? '',
      matchId: json['matchId'],
      lastMessageContent: json['lastMessageContent'] ?? json['lastMessage'],
      lastMessageAt: (json['lastMessageAt'] ?? json['lastMessageAt']) != null
          ? DateTime.parse((json['lastMessageAt'] ?? json['lastMessageAt']).toString())
          : null,
      user1UnreadCount: enrichedUnread > 0 && unread1 == 0 ? enrichedUnread : unread1,
      user2UnreadCount: unread2,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      otherUser: other,
    );
  }

  int unreadCount(String currentUserId) =>
      currentUserId == user1Id ? user1UnreadCount : user2UnreadCount;

  bool get hasUnread => user1UnreadCount > 0 || user2UnreadCount > 0;
}
