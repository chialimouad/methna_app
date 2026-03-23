import 'package:flutter/material.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/chat_controller.dart';
import 'package:methna_app/app/data/models/conversation_model.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/widgets/loading_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatListScreen extends GetView<ChatController> {
  const ChatListScreen({super.key});

  static const _purple = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: logo + Chats + search + menu ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.heart,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'chats'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(LucideIcons.search,
                        size: 22, color: textColor),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('Search Chats'.tr),
                          content: TextField(
                            onChanged: (v) => controller.searchConversations(v),
                            decoration: InputDecoration(
                              hintText: 'Enter name...'.tr,
                              prefixIcon: const Icon(LucideIcons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () { controller.searchConversations(''); Get.back(); }, child: Text('done'.tr)),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.moreVertical,
                        size: 22, color: textColor),
                    onPressed: () {
                      Get.bottomSheet(
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(LucideIcons.checkCheck, color: AppColors.primary),
                                title: Text('Mark all as read'.tr, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                                onTap: () {
                                  // Call backend logic here or simply dismiss for now since it's mock UI
                                  Helpers.showSnackbar(message: 'All chats marked as read');
                                  Get.back();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Now Active section ──
            Obx(() {
              if (controller.onlineTodayUsers.isEmpty) {
                return const SizedBox();
              }
              return Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'now_active'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'see_all'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.onlineTodayUsers.length,
                      separatorBuilder: (_, i) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final user =
                            controller.onlineTodayUsers[index];
                        return _ActiveAvatar(
                            user: user, index: index);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // ── Conversations list ──
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.conversations.isEmpty) {
                  return const LoadingWidget();
                }
                if (controller.hasError.value && controller.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.wifiOff, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Could not load chats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                        const SizedBox(height: 8),
                        Text('Check your connection and try again', style: TextStyle(fontSize: 13, color: secondaryColor)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: controller.fetchConversations,
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ],
                    ),
                  );
                }
                if (controller.conversations.isEmpty) {
                  return AnimatedEmptyState(
                    lottieAsset: 'assets/animations/no_chat.json',
                    title: 'no_conversations'.tr,
                    subtitle: 'start_chatting'.tr,
                    fallbackIcon: LucideIcons.messageSquare,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchConversations,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: controller.filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conv = controller.filteredConversations[index];
                      return _ChatTile(
                        conversation: conv,
                        isDark: isDark,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: () =>
                            controller.openConversation(conv),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Active user avatar with gradient ring ────────────────────────────────
class _ActiveAvatar extends StatelessWidget {
  final UserModel user;
  final int index;
  const _ActiveAvatar({required this.user, required this.index});

  static const _ringColors = [
    [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
    [AppColors.primary, AppColors.primaryLight],
    [Color(0xFF00C9FF), Color(0xFF92FE9D)],
    [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _ringColors[index % _ringColors.length];
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: user.mainPhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.mainPhotoUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.primarySurface,
                      child: Center(
                        child: Text(
                          Helpers.getInitials(
                              user.firstName, user.lastName),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────
class _ChatTile extends StatelessWidget {
  final ConversationModel conversation;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _ChatTile({
    required this.conversation,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final other = conversation.otherUser;
    final userId = Get.find<AuthService>().userId ?? '';
    final unread = conversation.unreadCount(userId);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primarySurface,
              backgroundImage: other?.mainPhotoUrl != null
                  ? CachedNetworkImageProvider(other!.mainPhotoUrl!)
                  : null,
              child: other?.mainPhotoUrl == null
                  ? Text(
                      Helpers.getInitials(
                          other?.firstName, other?.lastName),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Name + message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    other?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          unread > 0 ? FontWeight.w700 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conversation.lastMessageContent ??
                        'start_conversation'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.lastMessageAt != null
                      ? Helpers.timeAgo(conversation.lastMessageAt!)
                      : '',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryColor,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
