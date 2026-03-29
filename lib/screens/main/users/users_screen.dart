import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/users_controller.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/data/models/category_model.dart';
import 'package:methna_app/app/data/models/success_story_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/utils/cloudinary_url.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/utils/icon_helper.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';
import 'package:methna_app/core/widgets/intent_badge.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.secondary;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFFBFBFB),
      body: Stack(
        children: [
          // Subtler Background
          if (!isDark)
            Positioned(
              top: -100, right: -100,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.03),
                ),
              ),
            ),
          
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: controller.refreshUsers,
              edgeOffset: 80,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Sleek Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'discovery_title'.tr,
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w800, 
                                  color: AppColors.gold, 
                                  letterSpacing: 2.0,
                                ),
                              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                              const SizedBox(height: 4),
                              Text(
                                'find_match'.tr,
                                style: TextStyle(
                                  fontSize: 32, 
                                  fontWeight: FontWeight.w900, 
                                  color: textColor, 
                                  letterSpacing: -1.2,
                                ),
                              ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.05, end: 0),
                            ],
                          ),
                          const Spacer(),
                          _ModernSearchCircle(isDark: isDark),
                        ],
                      ),
                    ),
                  ),

                  // 2. Featured Success Stories (High Impact)
                  Obx(() {
                    if (controller.successStories.isEmpty && !controller.isLoadingStories.value) return const SliverToBoxAdapter(child: SizedBox.shrink());
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: _buildPremiumStoriesRow(isDark),
                      ),
                    );
                  }),

                  // 3. Category Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: _buildCleanCategories(isDark),
                    ),
                  ),

                  // 4. Discovery Filters & Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'explore_community'.tr, 
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                              ),
                              const Spacer(),
                              Icon(LucideIcons.slidersHorizontal, size: 20, color: isDark ? Colors.white38 : Colors.black38),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Obx(() => _ModernCategoryChips(
                            categories: controller.categories,
                            selected: controller.selectedCategory.value,
                            onSelect: controller.selectCategory,
                            isDark: isDark,
                          )),
                        ],
                      ),
                    ),
                  ),

                  // 5. Minimalist User Grid
                  Obx(() {
                    if (controller.isLoading.value && controller.allUsers.isEmpty) {
                      return _buildPremiumGridShimmer();
                    }
                    if (controller.filteredUsers.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: AnimatedEmptyState(
                            lottieAsset: 'assets/animations/no_users.json',
                            title: 'no_users_found'.tr,
                            subtitle: 'expand_filters_desc'.tr,
                            fallbackIcon: LucideIcons.users,
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final user = controller.filteredUsers[index];
                            return _ModernUserCard(
                              user: user, 
                              isDark: isDark, 
                              onTap: () => controller.openUserDetail(user),
                            ).animate()
                              .fadeIn(duration: 500.ms, delay: (index * 40).ms)
                              .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack);
                          },
                          childCount: controller.filteredUsers.length,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStoriesRow(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Text(
                'community_joy'.tr.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.gold),
              ),
              const Spacer(),
              Text('see_all'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: controller.isLoadingStories.value 
              ? _buildShimmerStories()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.successStories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) => _PremiumStoryCard(story: controller.successStories[i], isDark: isDark),
                ),
        ),
      ],
    );
  }

  Widget _buildCleanCategories(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'browse_by_lifestyle'.tr.toUpperCase(),
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 1.5, 
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: Obx(() => ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.backendCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final cat = controller.backendCategories[i];
              return _MinimalCategoryItem(category: cat, isDark: isDark, onTap: () => controller.openCategory(cat));
            },
          )),
        ),
      ],
    );
  }

  Widget _buildPremiumGridShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.withValues(alpha: 0.1),
            highlightColor: Colors.grey.withValues(alpha: 0.05),
            child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildShimmerStories() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      scrollDirection: Axis.horizontal,
      itemCount: 2,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.withValues(alpha: 0.1),
        highlightColor: Colors.grey.withValues(alpha: 0.05),
        child: Container(width: 300, margin: const EdgeInsets.only(right: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
      ),
    );
  }
}

// ─── INTERNAL WIDGETS ───

class _ModernSearchCircle extends StatelessWidget {
  final bool isDark;
  const _ModernSearchCircle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.search),
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: const Icon(LucideIcons.search, size: 22, color: AppColors.primary),
      ),
    );
  }
}

class _ModernCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final Function(String) onSelect;
  final bool isDark;

  const _ModernCategoryChips({required this.categories, required this.selected, required this.onSelect, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSel = selected == cat;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: 250.ms,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : (isDark ? Colors.white10 : Colors.white),
                borderRadius: BorderRadius.circular(22),
                border: isSel ? null : Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                cat.tr.capitalizeFirst!,
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, 
                  color: isSel ? Colors.white : (isDark ? Colors.white60 : Colors.black54)
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MinimalCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isDark;
  final VoidCallback onTap;

  const _MinimalCategoryItem({required this.category, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = category.color != null ? Helpers.parseColor(category.color!) : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: 0.15)),
            ),
            child: Icon(IconHelper.getIcon(category.icon), size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(category.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
        ],
      ),
    ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}

class _PremiumStoryCard extends StatelessWidget {
  final SuccessStoryModel story;
  final bool isDark;
  const _PremiumStoryCard({required this.story, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: story.photoUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (_,__,___) => Container(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
                    child: Text('SUCCESS'.tr, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 12),
                  if (story.title != null) 
                    Text(story.title!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5), maxLines: 1),
                  const SizedBox(height: 4),
                  Text(story.story, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernUserCard extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final VoidCallback onTap;

  const _ModernUserCard({required this.user, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: CloudinaryUrl.medium(user.mainPhotoUrl), 
                fit: BoxFit.cover,
                errorWidget: (_,__,___) => Container(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: const Icon(LucideIcons.user, color: AppColors.primary, size: 40),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),
              if (user.isOnline) 
                Positioned(top: 14, right: 14, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.online, blurRadius: 4)]))),
              
              Positioned(
                bottom: 16, left: 16, right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user.firstName ?? user.username}, ${user.profile?.age ?? ""}', 
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.selfieVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.shieldCheck, color: AppColors.emerald, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (user.profile?.city != null) 
                      Text(
                        user.profile!.city!, 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              if (user.profile?.intentMode != null) 
                Positioned(top: 14, left: 14, child: IntentBadge(intentMode: user.profile!.intentMode!, compact: true)),
            ],
          ),
        ),
      ),
    );
  }
}
