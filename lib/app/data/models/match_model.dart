import 'user_model.dart';

class MatchModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String status; // active, unmatched, expired
  final DateTime matchedAt;
  final UserModel? otherUser;

  MatchModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.status = 'active',
    required this.matchedAt,
    this.otherUser,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    UserModel? other;
    if (json['user1'] != null && json['user2'] != null && currentUserId != null) {
      final u1 = UserModel.fromJson(json['user1']);
      final u2 = UserModel.fromJson(json['user2']);
      other = u1.id == currentUserId ? u2 : u1;
    }

    return MatchModel(
      id: json['id'] ?? '',
      user1Id: json['user1Id'] ?? '',
      user2Id: json['user2Id'] ?? '',
      status: json['status'] ?? 'active',
      matchedAt: DateTime.parse(json['matchedAt'] ?? DateTime.now().toIso8601String()),
      otherUser: other,
    );
  }

  bool get isActive => status == 'active';
}
