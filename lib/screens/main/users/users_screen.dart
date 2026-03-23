import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/users_controller.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/constants/string_constants.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/widgets/loading_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                StringConstants.explore,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),

            // Category chips
            SizedBox(
              height: 40,
              child: Obx(() => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = controller.categories[index];
                      final selected = controller.selectedCategory.value == cat;
                      return GestureDetector(
                        onTap: () => controller.selectCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: selected ? AppColors.primaryGradient : null,
                            color: selected
                                ? null
                                : (isDark ? AppColors.cardDark : AppColors.dividerLight),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat.capitalize!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),

            const SizedBox(height: 16),

            // User grid
            Expanded(
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
                        Text('Could not load users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                        const SizedBox(height: 8),
                        Text('Check your connection and try again', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchUsers(refresh: true),
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ],
                    ),
                  );
                }
                final users = controller.filteredUsers;
                if (users.isEmpty) {
                  return const AnimatedEmptyState(
                    lottieAsset: 'assets/animations/no_matches.json',
                    title: 'No users found',
                    subtitle: 'There is no one to show for this category yet.',
                    fallbackIcon: LucideIcons.users,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshUsers,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) =>
                        _UserCard(user: users[index], onTap: () => controller.openUserDetail(users[index])),
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

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              user.mainPhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.mainPhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: isDark ? AppColors.cardDark : AppColors.dividerLight,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, _, _) => _AvatarPlaceholder(user: user),
                    )
                  : _AvatarPlaceholder(user: user),

              // Gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Online indicator
              if (user.isOnline)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),

              // Verified badge
              if (user.selfieVerified)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.verified,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.check, color: Colors.white, size: 10),
                  ),
                ),

              // User info
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName ?? user.username ?? 'User'}, ${user.profile?.age ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.profile?.city != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.profile!.city!,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
