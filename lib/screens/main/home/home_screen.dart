import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/controllers/home_controller.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';

import 'package:methna_app/screens/search/search_radar_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/routes/app_routes.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.locationGranted.value) {
        return Scaffold(body: _EnableLocationWidget(onRefresh: controller.fetchDiscoverUsers));
      }
      if (controller.isLoading.value && controller.discoverUsers.isEmpty) {
        return const SearchRadarScreen();
      }
      if (controller.discoverUsers.isEmpty) {
        return Scaffold(
          body: const AnimatedEmptyState(
            lottieAsset: 'assets/animations/location.json',
            title: 'No new souls found',
            subtitle: 'Try expanding your filters or check back later.',
            fallbackIcon: LucideIcons.search,
          ),
        );
      }
      return _CardStackScreen(controller: controller);
    });
  }
}

class _EnableLocationWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EnableLocationWidget({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.mapPinOff, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Location Required', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please enable location services so we can find people near you.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              child: const Text('Enable Location'),
            )
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CARD STACK SCREEN — Tinder-style swipeable cards
// ═══════════════════════════════════════════════════════════════════════════
class _CardStackScreen extends StatefulWidget {
  final HomeController controller;
  const _CardStackScreen({required this.controller});

  @override
  State<_CardStackScreen> createState() => _CardStackScreenState();
}

class _CardStackScreenState extends State<_CardStackScreen>
    with TickerProviderStateMixin {
  // Drag state
  Offset _dragPos = Offset.zero;
  bool _isDragging = false;

  // Fly-away animation
  late AnimationController _flyAwayCtrl;
  late Animation<Offset> _flyAwayAnim;

  // Overlay stamp animation (LIKE / NOPE / SUPER LIKE)
  String _overlayStamp = '';

  // Like burst animation
  late AnimationController _burstCtrl;

  // Details sheet variables removed


  @override
  void initState() {
    super.initState();
    _flyAwayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flyAwayAnim = Tween(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _flyAwayCtrl, curve: Curves.easeIn),
    );
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _flyAwayCtrl.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  UserModel? get _currentUser {
    final users = widget.controller.discoverUsers;
    if (users.isEmpty) return null;
    final idx = widget.controller.currentCardIndex.value.clamp(0, users.length - 1);
    return users[idx];
  }

  // ── Thresholds ──
  static const _swipeThreshold = 100.0;

  void _onPanStart(DragStartDetails d) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _dragPos += d.delta;
      // Determine overlay stamp
      if (_dragPos.dx > _swipeThreshold * 0.5) {
        _overlayStamp = 'LIKE';
      } else {
        _overlayStamp = '';
      }
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final user = _currentUser;
    if (user == null) return;

    if (_dragPos.dx > _swipeThreshold) {
      _animateOff(Offset(1500, _dragPos.dy), () {
        _burstCtrl.forward(from: 0);
        widget.controller.likeUser(user.id);
      });
    } else if (_dragPos.dx < -_swipeThreshold) {
      _animateOff(Offset(-1500, _dragPos.dy), () => widget.controller.passUser(user.id));
    } else {
      // Spring back
      setState(() {
        _dragPos = Offset.zero;
        _isDragging = false;
        _overlayStamp = '';
      });
    }
  }

  void _animateOff(Offset target, VoidCallback onComplete) {
    _flyAwayAnim = Tween(begin: _dragPos, end: target).animate(
      CurvedAnimation(parent: _flyAwayCtrl, curve: Curves.easeIn),
    );
    _flyAwayCtrl.forward(from: 0).then((_) {
      onComplete();
      setState(() {
        _dragPos = Offset.zero;
        _isDragging = false;
        _overlayStamp = '';
      });
      _flyAwayCtrl.reset();
    });
  }

  // ── Programmatic actions from buttons ──
  void _triggerLike() {
    final user = _currentUser;
    if (user == null) return;
    _burstCtrl.forward(from: 0);
    _animateOff(const Offset(1500, 0), () => widget.controller.likeUser(user.id));
  }

  void _triggerPass() {
    final user = _currentUser;
    if (user == null) return;
    _animateOff(const Offset(-1500, 0), () => widget.controller.passUser(user.id));
  }

  void _showComplimentDialog() {
    final user = _currentUser;
    if (user == null) return;
    final tc = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Send Compliment', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: tc,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Write something nice...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (tc.text.trim().isNotEmpty) {
                widget.controller.complimentUser(user.id, tc.text.trim());
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final users = widget.controller.discoverUsers;
        if (users.isEmpty) {
          return const AnimatedEmptyState(
            lottieAsset: 'assets/animations/no_users.json',
            title: 'No Matches Nearby',
            subtitle: 'You have seen everyone in your area.\nTry expanding your distance preferences!',
            fallbackIcon: LucideIcons.search,
          );
        }
        
        final idx = widget.controller.currentCardIndex.value.clamp(0, users.length - 1);
        final user = users[idx];

        // Card offset: either from drag or fly-away
        final offset = _flyAwayCtrl.isAnimating ? _flyAwayAnim.value : _dragPos;
        final angle = _isDragging || _flyAwayCtrl.isAnimating
            ? (offset.dx / 600) * 0.5
            : 0.0;

        return AnimatedBuilder(
          animation: _flyAwayCtrl,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // ── Background card (next user peek) ──
                if (users.length > 1)
                  Positioned.fill(
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * (offset.distance / 300).clamp(0, 1),
                      child: _buildCardContent(
                        users[(idx + 1) % users.length],
                        context,
                      ),
                    ),
                  ),

                // ── Top (draggable) card ──
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onDoubleTap: _triggerLike,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(offset.dx, offset.dy)
                        ..rotateZ(angle),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildCardContent(user, context),

                          // ── Swipe overlay stamps ──
                          if (_overlayStamp == 'LIKE')
                            _StampOverlay(
                              text: 'LIKE',
                              color: const Color(0xFF00E676),
                              rotation: -0.3,
                              alignment: Alignment.topLeft,
                            ),
                          if (_overlayStamp == 'NOPE')
                            _StampOverlay(
                              text: 'NOPE',
                              color: const Color(0xFFFF4458),
                              rotation: 0.3,
                              alignment: Alignment.topRight,
                            ),

                        ],
                      ),
                    ),
                  ),
                ),

                // ── Like heart burst animation ──
                if (_burstCtrl.isAnimating)
                  Center(child: _HeartBurst(animation: _burstCtrl)),

                // ── Top bar (Logged-in user avatar + icons) ──
                Positioned(
                  top: topPad + 12,
                  left: 16,
                  child: _MiniAvatarHeader(
                    user: widget.controller.currentUser,
                    onTap: () => Get.toNamed(AppRoutes.settings),
                  ),
                ),
                Positioned(
                  top: topPad + 12,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassCircleBtn(
                        icon: LucideIcons.bell,
                        onTap: widget.controller.openNotifications,
                      ),
                      const SizedBox(height: 12),
                      _GlassCircleBtn(
                        icon: LucideIcons.search,
                        onTap: () => Get.toNamed(AppRoutes.search),
                      ),
                      const SizedBox(height: 12),
                      _GlassCircleBtn(
                        icon: LucideIcons.sliders,
                        onTap: widget.controller.openFilter,
                      ),
                    ],
                  ),
                ),

                // ── Bottom user info + action bar ──
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomSection(
                    user: user,
                    bottomPad: bottomPad,
                    onLike: _triggerLike,
                    onPass: _triggerPass,
                    onRewind: widget.controller.rewindLastSwipe,
                    onCompliment: _showComplimentDialog,
                    onBoost: () => widget.controller.requestRematch(user.id),
                    onDetails: () => _openDetails(user),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildCardContent(UserModel user, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          user.mainPhotoUrl != null
              ? CachedNetworkImage(
                  imageUrl: user.mainPhotoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: AppColors.dividerLight),
                  errorWidget: (c, u, e) => _PlaceholderPhoto(user: user),
                )
              : _PlaceholderPhoto(user: user),
          // Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.4, 0.65, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailsSheet(user: user),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// STAMP OVERLAY (LIKE / NOPE / SUPER LIKE)
// ═══════════════════════════════════════════════════════════════════════════
class _StampOverlay extends StatelessWidget {
  final String text;
  final Color color;
  final double rotation;
  final Alignment alignment;

  const _StampOverlay({
    required this.text,
    required this.color,
    required this.rotation,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HEART BURST (like animation)
// ═══════════════════════════════════════════════════════════════════════════
class _HeartBurst extends StatelessWidget {
  final AnimationController animation;
  const _HeartBurst({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, _) {
        final t = animation.value;
        final scale = t < 0.5 ? 1.0 + t * 2.0 : 2.0 - (t - 0.5) * 3.0;
        final opacity = t < 0.7 ? 1.0 : 1.0 - (t - 0.7) / 0.3;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale.clamp(0.0, 3.0),
            child: const Icon(
              LucideIcons.heart,
              color: Color(0xFFFF2D55),
              size: 100,
              shadows: [Shadow(blurRadius: 30, color: Colors.black38)],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MINI AVATAR HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _MiniAvatarHeader extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onTap;
  
  const _MiniAvatarHeader({required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final completion = user?.profile?.profileCompletionPercentage ?? 0;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipOval(
            child: user?.mainPhotoUrl != null
                ? CachedNetworkImage(
                    imageUrl: user!.mainPhotoUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        Helpers.getInitials(user?.firstName, user?.lastName),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completion%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
          ),
        ),
      ],
    ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GLASS CIRCLE BUTTON
// ═══════════════════════════════════════════════════════════════════════════
class _GlassCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassCircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM SECTION — User info + action bar
// ═══════════════════════════════════════════════════════════════════════════
class _BottomSection extends StatelessWidget {
  final UserModel user;
  final double bottomPad;
  final VoidCallback onLike, onPass, onRewind, onCompliment, onBoost, onDetails;

  const _BottomSection({
    required this.user,
    required this.bottomPad,
    required this.onLike,
    required this.onPass,
    required this.onRewind,
    required this.onCompliment,
    required this.onBoost,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: bottomPad + 30, left: 24, right: 24, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── User info ──
          GestureDetector(
            onTap: onDetails,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '${user.firstName ?? user.username ?? 'User'}, ${user.profile?.age ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.selfieVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B4226), // Dark brown/burgundy shield
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.check, color: Colors.white, size: 14),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Based in ${user.profile?.city ?? 'Unknown location'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('🇩🇿', style: TextStyle(fontSize: 16)), // Placeholder flag
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Action buttons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rewind (Green)
              _ActionBtn(
                icon: LucideIcons.rotateCcw,
                bgColor: const Color(0xFF4CAF50),
                iconColor: Colors.white,
                size: 50,
                iconSize: 26,
                onTap: onRewind,
              ),
              // Pass (Dark Semi-transparent)
              _ActionBtn(
                icon: LucideIcons.x,
                bgColor: Colors.black.withValues(alpha: 0.5),
                iconColor: Colors.white,
                size: 60,
                iconSize: 32,
                onTap: onPass,
              ),
              // Like (Pink) - center biggest
              _ActionBtn(
                icon: LucideIcons.heart,
                bgColor: const Color(0xFFE91E63),
                iconColor: Colors.white,
                size: 72,
                iconSize: 36,
                onTap: onLike,
              ),
              // Compliment / Sparkles (White)
              _ActionBtn(
                icon: LucideIcons.sparkles,
                bgColor: Colors.white,
                iconColor: const Color(0xFFE91E63),
                size: 60,
                iconSize: 32,
                onTap: onCompliment,
              ),
              // Boost (Blue)
              _ActionBtn(
                icon: LucideIcons.arrowUp,
                bgColor: const Color(0xFF2196F3),
                iconColor: Colors.white,
                size: 50,
                iconSize: 26,
                onTap: onBoost,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACTION BUTTON — Glass morphism circle
// ═══════════════════════════════════════════════════════════════════════════
class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.size,
    required this.iconSize,
    this.outlined = false,
    required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.white.withValues(alpha: 0.1)
                : widget.bgColor,
            shape: BoxShape.circle,
            border: widget.outlined
                ? Border.all(color: widget.iconColor.withValues(alpha: 0.5), width: 2)
                : null,
            boxShadow: [
              if (!widget.outlined)
                BoxShadow(
                  color: widget.bgColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// USER DETAILS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _UserDetailsSheet extends StatelessWidget {
  final UserModel user;
  const _UserDetailsSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(24),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Photo gallery row
              if (user.photos != null && user.photos!.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: user.photos!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: user.photos![i].url,
                          width: 150,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Name + age
              Text(
                '${user.firstName ?? user.username ?? 'User'}, ${user.profile?.age ?? ''}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),

              // Location
              if (user.profile?.city != null)
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(user.profile!.city!, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),

              const SizedBox(height: 16),

              // Bio
              if (user.profile?.bio != null && user.profile!.bio!.isNotEmpty) ...[
                Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  user.profile!.bio!,
                  style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
              ],

              // Details grid
              _DetailChips(user: user),

              const SizedBox(height: 16),

              // Interests
              if (user.profile?.interests != null && user.profile!.interests!.isNotEmpty) ...[
                Text('Interests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.profile!.interests!.map((h) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(h, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DETAIL CHIPS (education, religion, etc.)
// ═══════════════════════════════════════════════════════════════════════════
class _DetailChips extends StatelessWidget {
  final UserModel user;
  const _DetailChips({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<IconData, String>>[];
    if (user.profile?.education != null) {
      items.add(MapEntry(LucideIcons.graduationCap, user.profile!.education!));
    }
    if (user.profile?.jobTitle != null) {
      items.add(MapEntry(LucideIcons.briefcase, user.profile!.jobTitle!));
    }
    if (user.profile?.religiousLevel != null) {
      items.add(MapEntry(LucideIcons.sparkles, user.profile!.religiousLevel!));
    }
    if (user.profile?.height != null) {
      items.add(MapEntry(LucideIcons.ruler, '${user.profile!.height} cm'));
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(e.key, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(e.value, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PLACEHOLDER PHOTO
// ═══════════════════════════════════════════════════════════════════════════
class _PlaceholderPhoto extends StatelessWidget {
  final UserModel user;
  const _PlaceholderPhoto({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySurface,
      child: Center(
        child: Text(
          Helpers.getInitials(user.firstName, user.lastName),
          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
      ),
    );
  }
}

