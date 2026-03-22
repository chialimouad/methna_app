import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/chat_controller.dart';
import 'package:methna_app/app/data/models/message_model.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatDetailScreen extends GetView<ChatController> {
  const ChatDetailScreen({super.key});

  static const _purple = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final currentUserId = Get.find<AuthService>().userId ?? '';

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller.leaveActiveChat();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar: back + name + call/video ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.leaveActiveChat();
                        Get.back();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(LucideIcons.chevronLeft,
                            size: 16, color: textColor),
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      final other = controller.activeConversation.value?.otherUser;
                      final name = other?.firstName ?? other?.displayName ?? 'chat'.tr;
                      return Column(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          if (controller.isTyping.value)
                            Text(
                              'typing'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: _purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      );
                    }),
                    const Spacer(),
                    // Call icon
                    GestureDetector(
                      onTap: () {
                        Helpers.showSnackbar(message: 'Voice/Video calling coming soon!');
                      },
                      child: Icon(LucideIcons.phone,
                          size: 22, color: textColor),
                    ),
                    const SizedBox(width: 16),
                    // Video icon
                    GestureDetector(
                      onTap: () {
                        Helpers.showSnackbar(message: 'Voice/Video calling coming soon!');
                      },
                      child: Icon(LucideIcons.video,
                          size: 24, color: textColor),
                    ),
                  ],
                ),
              ),

              Divider(
                  height: 1,
                  color:
                      isDark ? AppColors.dividerDark : Colors.grey.shade200),

              // ── Messages list ──
              Expanded(
                child: Obx(() {
                  if (controller.messagesLoading.value &&
                      controller.activeMessages.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (controller.activeMessages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.messageSquare,
                              size: 48, color: secondaryColor),
                          const SizedBox(height: 12),
                          Text(
                            'say_hello'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: controller.activeMessages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.activeMessages[index];
                      final isMine = msg.isMine(currentUserId);
                      final showDate = index ==
                              controller.activeMessages.length - 1 ||
                          !_sameDay(
                              msg.createdAt,
                              controller
                                  .activeMessages[index + 1].createdAt);

                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              child: Text(
                                Helpers.formatDate(msg.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          _MessageBubble(
                            message: msg,
                            isMine: isMine,
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),

              // ── Input bar ──
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 10, 12, MediaQuery.of(context).padding.bottom + 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.dividerDark
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // + icon for images
                    GestureDetector(
                      onTap: controller.sendImageMessage,
                      child: Icon(LucideIcons.imagePlus,
                          size: 24, color: secondaryColor),
                    ),
                    const SizedBox(width: 10),

                    // Text field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.messageTextController,
                                maxLines: 4,
                                minLines: 1,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (_) =>
                                    controller.sendTypingIndicator(),
                                decoration: InputDecoration(
                                  hintText: 'type_message'.tr,
                                  hintStyle: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                            // Mic icon
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Helpers.showSnackbar(message: 'Voice messages coming soon!');
                                },
                                child: Icon(LucideIcons.mic,
                                    size: 22, color: secondaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Send button
                    GestureDetector(
                      onTap: () {
                        final text =
                            controller.messageTextController.text.trim();
                        if (text.isNotEmpty) {
                          controller.sendMessage(text);
                          controller.messageTextController.clear();
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: _purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.send,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Message bubble ───────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool isDark;

  static const _purple = AppColors.primary;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // In RTL, "mine" bubbles go to the left visually, so flip alignment
    final alignment = isMine
        ? (isRTL ? Alignment.centerLeft : Alignment.centerRight)
        : (isRTL ? Alignment.centerRight : Alignment.centerLeft);

    return Align(
      alignment: alignment,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? _purple
              : (isDark ? AppColors.cardDark : Colors.grey.shade100),
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(20),
            topEnd: const Radius.circular(20),
            bottomStart: Radius.circular(isMine ? 20 : 4),
            bottomEnd: Radius.circular(isMine ? 4 : 20),
          ).resolve(Directionality.of(context)),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: isMine ? Colors.white : textColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Helpers.formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.6)
                        : secondaryColor,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? LucideIcons.checkCheck
                        : LucideIcons.check,
                    size: 14,
                    color: message.isRead
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
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
