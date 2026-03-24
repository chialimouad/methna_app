import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/users_controller.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/data/models/category_model.dart';
import 'package:methna_app/app/data/models/conversation_model.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/widgets/loading_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/widgets/respectful_blur_photo.dart';
import 'package:methna_app/core/widgets/intent_badge.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.allUsers.isEmpty) {
            return const LoadingWidget();
          }
          if (controller.hasError.value && controller.allUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.wifiOff, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Could not load users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: controller.refreshUsers,
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshUsers,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text('Explore', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textColor)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.search),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: cardBg, shape: BoxShape.circle, border: Border.all(color: borderColor)),
                          child: Icon(LucideIcons.search, size: 20, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ═══════ SECTION 1: Nearby Users ═══════
                if (controller.nearbyUsers.isNotEmpty) ...[
                  _SectionHeader(title: 'Nearby', icon: LucideIcons.mapPin, textColor: textColor, onSeeAll: () => controller.selectCategory('nearby')),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.nearbyUsers.length.clamp(0, 10),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => _UserCard(
                        user: controller.nearbyUsers[i],
                        width: 150,
                        onTap: () => controller.openUserDetail(controller.nearbyUsers[i]),
                      ),
                    ),
                  ),
                  _SectionDivider(isDark: isDark),
                ],

                // ═══════ SECTION 2: Categories (from admin backend) ═══════
                if (controller.backendCategories.isNotEmpty) ...[
                  _SectionHeader(title: 'Categories', icon: LucideIcons.layoutGrid, textColor: textColor),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.backendCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final cat = controller.backendCategories[i];
                        return _CategoryCard(category: cat, isDark: isDark, onTap: () => controller.openCategory(cat));
                      },
                    ),
                  ),
                  _SectionDivider(isDark: isDark),
                ],

                // ═══════ SECTION 3: Live Today ═══════
                if (controller.liveTodayUsers.isNotEmpty) ...[
                  _SectionHeader(title: 'Live Today', icon: LucideIcons.zap, textColor: textColor, accentColor: AppColors.online),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.liveTodayUsers.length.clamp(0, 15),
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, i) {
                        final u = controller.liveTodayUsers[i];
                        return _LiveAvatar(user: u, onTap: () => controller.openUserDetail(u));
                      },
                    ),
                  ),
                  _SectionDivider(isDark: isDark),
                ],

                // ═══════ SECTION 4: Search ═══════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 20, color: secondaryColor),
                          const SizedBox(width: 12),
                          Text('Search by name, city, interests...', style: TextStyle(fontSize: 14, color: secondaryColor)),
                        ],
                      ),
                    ),
                  ),
                ),
                _SectionDivider(isDark: isDark),

                // ═══════ SECTION 5: Messages Preview ═══════
                if (controller.recentConversations.isNotEmpty) ...[
                  _SectionHeader(title: 'Messages', icon: LucideIcons.messageCircle, textColor: textColor),
                  const SizedBox(height: 8),
                  ...controller.recentConversations.take(3).map((conv) =>
                    _MessagePreviewTile(conversation: conv, isDark: isDark, textColor: textColor, secondaryColor: secondaryColor),
                  ),
                  const SizedBox(height: 8),
                ],

                // ═══════ SECTION 6: All Users Grid ═══════
                _SectionHeader(title: 'All Users', icon: LucideIcons.users, textColor: textColor),
                const SizedBox(height: 8),

                // Category chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = controller.categories[index];
                      final selected = controller.selectedCategory.value == cat;
                      return GestureDetector(
                        onTap: () => controller.selectCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: selected ? AppColors.primaryGradient : null,
                            color: selected ? null : (isDark ? AppColors.cardDark : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: selected ? null : Border.all(color: borderColor),
                          ),
                          child: Text(
                            cat.capitalize!,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : secondaryColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Grid of users
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: controller.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final u = controller.filteredUsers[index];
                      return _UserCard(user: u, onTap: () => controller.openUserDetail(u));
                    },
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color textColor;
  final Color? accentColor;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, required this.icon, required this.textColor, this.accentColor, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentColor ?? AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textColor)),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

// ─── Section divider ─────────────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  final bool isDark;
  const _SectionDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
    );
  }
}

// ─── User card (used in grid and horizontal list) ────────────────────────
class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final double? width;

  const _UserCard({required this.user, required this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RespectfulBlurPhoto(
                imageUrl: user.mainPhotoUrl,
                interactionLevel: 2, // In users grid, photos are visible (matched/discovered)
                fit: BoxFit.cover,
                errorWidget: _AvatarPlaceholder(user: user),
              ),
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)], stops: const [0.5, 1.0])))),
              if (user.isOnline) Positioned(top: 8, right: 8, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.online, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              if (user.selfieVerified) Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: AppColors.verified, shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: Colors.white, size: 10))),
              if (user.profile?.intentMode != null) Positioned(bottom: 42, right: 8, child: IntentBadge(intentMode: user.profile!.intentMode!, compact: true)),
              Positioned(
                bottom: 10, left: 10, right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user.firstName ?? user.username ?? "User"}, ${user.profile?.age ?? ""}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (user.profile?.city != null) ...[
                      const SizedBox(height: 2),
                      Row(children: [const Icon(LucideIcons.mapPin, color: Colors.white70, size: 11), const SizedBox(width: 3), Expanded(child: Text(user.profile!.city!, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category card ───────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.isDark, required this.onTap});

  Color get _color {
    if (category.color != null && category.color!.startsWith('#')) {
      try {
        return Color(int.parse(category.color!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_color, _color.withValues(alpha: 0.7)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('${category.userCount} users', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

// ─── Live avatar (circular with green ring) ──────────────────────────────
class _LiveAvatar extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _LiveAvatar({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.online, Color(0xFF00E676)]),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: user.mainPhotoUrl != null ? CachedNetworkImageProvider(user.mainPhotoUrl!) : null,
              backgroundColor: AppColors.primarySurface,
              child: user.mainPhotoUrl == null ? Text(Helpers.getInitials(user.firstName, user.lastName), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)) : null,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(user.firstName ?? 'User', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─── Message preview tile ────────────────────────────────────────────────
class _MessagePreviewTile extends StatelessWidget {
  final ConversationModel conversation;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  const _MessagePreviewTile({required this.conversation, required this.isDark, required this.textColor, required this.secondaryColor});

  @override
  Widget build(BuildContext context) {
    final myId = Get.find<AuthService>().userId ?? '';
    final otherUser = conversation.otherUser;
    final unread = conversation.unreadCount(myId);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: otherUser?.mainPhotoUrl != null ? CachedNetworkImageProvider(otherUser!.mainPhotoUrl!) : null,
        backgroundColor: AppColors.primarySurface,
        child: otherUser?.mainPhotoUrl == null ? Text(Helpers.getInitials(otherUser?.firstName, otherUser?.lastName), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)) : null,
      ),
      title: Text(otherUser?.firstName ?? 'User', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(conversation.lastMessageContent ?? 'Start chatting', style: TextStyle(fontSize: 13, color: secondaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Text('$unread', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            )
          : null,
      onTap: () => Get.toNamed(AppRoutes.chatDetail, arguments: {'conversation': conversation}),
    );
  }
}

// ─── Avatar placeholder ──────────────────────────────────────────────────
class _AvatarPlaceholder extends StatelessWidget {
  final UserModel user;
  const _AvatarPlaceholder({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySurface,
      child: Center(
        child: Text(
          Helpers.getInitials(user.firstName, user.lastName),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
      ),
    );
  }
}
