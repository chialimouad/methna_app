// AGENTIC_STABILIZATION_V2
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/chat_controller.dart';
import 'package:methna_app/app/data/models/conversation_model.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/utils/cloudinary_url.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/widgets/islamic_pattern_painter.dart';
import 'dart:math';

class ChatListScreen extends GetView<ChatController> {
  const ChatListScreen({super.key});

  static final List<Color> avatarColors = [
    AppColors.emerald.withValues(alpha: 0.1),
    AppColors.gold.withValues(alpha: 0.1),
    const Color(0xFFE0D4FF).withValues(alpha: 0.1),
    const Color(0xFFFFD4C4).withValues(alpha: 0.1),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF9F6F2);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: IslamicPatternWidget(
              opacity: isDark ? 0.03 : 0.05,
              color: isDark ? Colors.white : AppColors.emerald,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldPremiumGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.messageCircle, color: AppColors.secondary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'conversations'.tr,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.search, color: AppColors.gold, size: 24),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.conversations.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchConversations(),
                      child: ListView(
                        children: [
                          _buildLiveSection(textColor, isDark),
                          const SizedBox(height: 16),
                          _buildChatListSection(context),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSection(Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live today', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
              const Text('See all', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: Obx(() {
            if (controller.onlineTodayUsers.isEmpty) return const SizedBox.shrink();
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: min(controller.onlineTodayUsers.length, 15),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final user = controller.onlineTodayUsers[index];
                return _ActiveUserItem(
                  user: user, 
                  bgColor: avatarColors[index % avatarColors.length]
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildChatListSection(BuildContext context) {
    return Obx(() {
      if (controller.conversations.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Text('No conversations yet', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.conversations.length,
        itemBuilder: (context, index) {
          return _ChatTile(
            conversation: controller.conversations[index],
            avatarBg: avatarColors[(index + 2) % avatarColors.length],
          );
        },
      );
    });
  }
}

class _ActiveUserItem extends StatelessWidget {
  final UserModel user;
  final Color bgColor;
  const _ActiveUserItem({required this.user, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(gradient: AppColors.goldPremiumGradient, shape: BoxShape.circle),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: ClipOval(
                    child: user.mainPhotoUrl != null
                        ? CachedNetworkImage(imageUrl: CloudinaryUrl.thumbnail(user.mainPhotoUrl!), fit: BoxFit.cover)
                        : const Icon(LucideIcons.user, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 2, bottom: 2,
              child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(user.firstName ?? 'User', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ConversationModel conversation;
  final Color avatarBg;
  const _ChatTile({required this.conversation, required this.avatarBg});

  @override
  Widget build(BuildContext context) {
    final other = conversation.otherUser;
    final userId = Get.find<AuthService>().userId ?? '';
    final unread = conversation.unreadCount(userId);
    final lastMsg = conversation.lastMessageContent;
    final time = conversation.lastMessageAt != null
        ? Helpers.timeAgo(conversation.lastMessageAt!)
        : '';
    
    return InkWell(
      onTap: () => Get.find<ChatController>().openConversation(conversation),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                  child: ClipOval(
                    child: other?.mainPhotoUrl != null
                        ? CachedNetworkImage(imageUrl: CloudinaryUrl.thumbnail(other!.mainPhotoUrl!), fit: BoxFit.cover)
                        : const Icon(LucideIcons.user, color: Colors.white),
                  ),
                ),
                if (other?.isOnline ?? false)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(other?.fullName ?? 'User', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: unread > 0 ? Colors.black : Colors.grey, fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                if (unread > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
                    child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
