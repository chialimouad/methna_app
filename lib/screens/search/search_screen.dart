import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = Get.find<ApiService>();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  final RxList<_SearchResult> results = <_SearchResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString query = ''.obs;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchCtrl.text.trim();
    query.value = text;
    _debounce?.cancel();
    if (text.isEmpty) {
      results.clear();
      hasSearched.value = false;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(text);
    });
  }

  int _calcAge(String dob) {
    try {
      final birth = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) age--;
      return age;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _performSearch(String q) async {
    isLoading.value = true;
    hasSearched.value = true;
    try {
      final response = await _api.get(ApiConstants.search, queryParameters: {
        'name': q,
        'q': q,
        'limit': 20,
      });
      final data = response.data;
      final list = data is Map ? (data['users'] ?? data['results'] ?? []) : (data is List ? data : []);
      results.value = (list as List).map((item) {
        if (item is Map<String, dynamic>) {
          // Extract photo: from photos array (enriched format) or flat 'photo' field
          String? photoUrl = item['photo'];
          if (photoUrl == null && item['photos'] is List && (item['photos'] as List).isNotEmpty) {
            final mainPhoto = (item['photos'] as List).firstWhere(
              (p) => p['isMain'] == true,
              orElse: () => (item['photos'] as List).first,
            );
            photoUrl = mainPhoto['url'];
          }
          // Extract profile fields (may be nested or flat)
          final profile = item['profile'] is Map ? item['profile'] as Map<String, dynamic> : null;
          return _SearchResult(
            userId: item['id'] ?? item['userId'] ?? '',
            firstName: item['firstName'] ?? '',
            lastName: item['lastName'] ?? '',
            age: item['age'] ?? (profile?['dateOfBirth'] != null ? _calcAge(profile!['dateOfBirth']) : 0),
            city: profile?['city'] ?? item['city'] ?? '',
            country: profile?['country'] ?? item['country'] ?? '',
            photo: photoUrl,
            bio: profile?['bio'] ?? item['bio'],
            interests: (profile?['interests'] ?? item['interests']) != null
                ? List<String>.from(profile?['interests'] ?? item['interests'])
                : [],
          );
        }
        return null;
      }).whereType<_SearchResult>().toList();
    } catch (_) {
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFFFF8F0);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.chevronLeft, size: 16, color: textColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: TextStyle(fontSize: 15, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Search by name, city, interests...',
                          hintStyle: TextStyle(fontSize: 14, color: secondaryColor.withValues(alpha: 0.6)),
                          prefixIcon: Icon(LucideIcons.search, size: 18, color: secondaryColor),
                          suffixIcon: Obx(() => query.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                  },
                                  child: Icon(LucideIcons.x, size: 16, color: secondaryColor),
                                )
                              : const SizedBox.shrink()),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Results ──
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return _buildSkeletonList(isDark);
                }

                if (!hasSearched.value) {
                  return _buildInitialState(isDark, secondaryColor);
                }

                if (results.isEmpty) {
                  return const AnimatedEmptyState(
                    lottieAsset: 'assets/animations/no_users.json',
                    title: 'No results found',
                    subtitle: 'Try different keywords or\nadjust your search terms.',
                    fallbackIcon: LucideIcons.searchX,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return _SearchResultTile(
                      result: r,
                      isDark: isDark,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      onTap: () {
                        Get.toNamed(AppRoutes.userDetail, arguments: {'userId': r.userId});
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(bool isDark, Color secondaryColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.search, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for people',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find users by name, city, or interests',
            style: TextStyle(fontSize: 14, color: secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              _shimmerBox(isDark, 52, 52, isCircle: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(isDark, double.infinity, 14),
                    const SizedBox(height: 8),
                    _shimmerBox(isDark, 120, 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(bool isDark, double width, double height, {bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade200,
        borderRadius: isCircle ? null : BorderRadius.circular(8),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

// ─── Search Result Model ──────────────────────────────────────────────────
class _SearchResult {
  final String userId;
  final String firstName;
  final String lastName;
  final int age;
  final String city;
  final String country;
  final String? photo;
  final String? bio;
  final List<String> interests;

  _SearchResult({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.city,
    required this.country,
    this.photo,
    this.bio,
    required this.interests,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get location => [city, country].where((s) => s.isNotEmpty).join(', ');
}

// ─── Search Result Tile ───────────────────────────────────────────────────
class _SearchResultTile extends StatelessWidget {
  final _SearchResult result;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight.withValues(alpha: 0.5),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
              ),
              child: result.photo != null && result.photo!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: result.photo!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: Text(
                            Helpers.getInitials(result.firstName, result.lastName),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Text(
                            Helpers.getInitials(result.firstName, result.lastName),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        Helpers.getInitials(result.firstName, result.lastName),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${result.fullName}${result.age > 0 ? ', ${result.age}' : ''}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (result.location.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 12, color: secondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          result.location,
                          style: TextStyle(fontSize: 12, color: secondaryColor),
                        ),
                      ],
                    ),
                  ],
                  if (result.interests.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: result.interests.take(3).map((i) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            i,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            Icon(LucideIcons.chevronRight, size: 16, color: secondaryColor),
          ],
        ),
      ),
    );
  }
}
