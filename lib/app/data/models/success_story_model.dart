import 'package:methna_app/app/data/models/user_model.dart';

enum SuccessStoryStatus {
  pending,
  approved,
  rejected,
}

class SuccessStoryModel {
  final String id;
  final String userId;
  final UserModel? user;
  final String? partnerId;
  final UserModel? partner;
  final String story;
  final String? title;
  final String? photoUrl;
  final SuccessStoryStatus status;
  final bool isAnonymous;
  final bool showNames;
  final bool showPhoto;
  final int likes;
  final DateTime createdAt;

  SuccessStoryModel({
    required this.id,
    required this.userId,
    this.user,
    this.partnerId,
    this.partner,
    required this.story,
    this.title,
    this.photoUrl,
    this.status = SuccessStoryStatus.pending,
    this.isAnonymous = false,
    this.showNames = true,
    this.showPhoto = false,
    this.likes = 0,
    required this.createdAt,
  });

  factory SuccessStoryModel.fromJson(Map<String, dynamic> json) {
    return SuccessStoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      partnerId: json['partnerId'],
      partner: json['partner'] != null ? UserModel.fromJson(json['partner']) : null,
      story: json['story'] ?? '',
      title: json['title'],
      photoUrl: json['photoUrl'],
      status: _parseStatus(json['status']),
      isAnonymous: json['isAnonymous'] ?? false,
      showNames: json['showNames'] ?? true,
      showPhoto: json['showPhoto'] ?? false,
      likes: json['likes'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  static SuccessStoryStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved':
        return SuccessStoryStatus.approved;
      case 'rejected':
        return SuccessStoryStatus.rejected;
      default:
        return SuccessStoryStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'story': story,
        'title': title,
        'photoUrl': photoUrl,
        'status': status.name,
        'isAnonymous': isAnonymous,
        'showNames': showNames,
        'showPhoto': showPhoto,
        'likes': likes,
      };
}
