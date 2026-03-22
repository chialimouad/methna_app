import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:methna_app/app/data/models/user_model.dart';
import 'package:methna_app/app/data/services/auth_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MatchFoundScreen extends StatefulWidget {
  const MatchFoundScreen({super.key});

  @override
  State<MatchFoundScreen> createState() => _MatchFoundScreenState();
}

class _MatchFoundScreenState extends State<MatchFoundScreen>
    with TickerProviderStateMixin {
  static const _pink = Color(0xFFFF2D55);
  static const _purple = AppColors.primary;

  late AnimationController _entranceCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _confettiCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    // Main entrance animation
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut));
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.3, 0.7, curve: Curves.easeIn));
    _slideAnim = CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut));

    // Pulse for heart icon
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Confetti
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _entranceCtrl.forward();
    _confettiCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final UserModel? matchedUser = args?['user'];
    final currentUser = Get.find<AuthService>().currentUser.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Confetti particles
          ..._buildConfetti(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated heart icon ──
                ScaleTransition(
                  scale: _scaleAnim,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (ctx, _) {
                      final s = 1.0 + _pulseCtrl.value * 0.08;
                      return Transform.scale(
                        scale: s,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_pink, _purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: _pink.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 4),
                            ],
                          ),
                          child: const Icon(LucideIcons.heart, color: Colors.white, size: 32),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Two overlapping avatars with slide-in ──
                ScaleTransition(
                  scale: _scaleAnim,
                  child: SizedBox(
                    width: 240,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left avatar (current user) — slides from left
                        AnimatedBuilder(
                          animation: _entranceCtrl,
                          builder: (ctx, _) {
                            final dx = -60 * (1 - _slideAnim.value);
                            return Transform.translate(
                              offset: Offset(dx, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _MatchAvatar(
                                  imageUrl: currentUser?.mainPhotoUrl,
                                  name: currentUser?.firstName,
                                  lastName: currentUser?.lastName,
                                  borderColor: _pink,
                                ),
                              ),
                            );
                          },
                        ),
                        // Center heart overlap
                        Positioned(
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                              ),
                              child: const Icon(LucideIcons.heart, color: _pink, size: 20),
                            ),
                          ),
                        ),
                        // Right avatar (matched user) — slides from right
                        AnimatedBuilder(
                          animation: _entranceCtrl,
                          builder: (ctx, _) {
                            final dx = 60 * (1 - _slideAnim.value);
                            return Transform.translate(
                              offset: Offset(dx, 0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _MatchAvatar(
                                  imageUrl: matchedUser?.mainPhotoUrl,
                                  name: matchedUser?.firstName,
                                  lastName: matchedUser?.lastName,
                                  borderColor: _purple,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Title ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_pink, _purple],
                    ).createShader(bounds),
                    child: const Text(
                      "It's a Match!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'You and ${matchedUser?.firstName ?? 'someone'} liked each other.\nStart a conversation now!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── "Send a Message" button ──
                SlideTransition(
                  position: Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(_slideAnim),
                  child: FadeTransition(
                    opacity: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            if (matchedUser != null) {
                              // We navigate back to the main layout for now
                              // Users can select the chat tab from there.
                              Get.until((route) => Get.currentRoute == '/main');
                              Get.snackbar('Match', 'Go to your Chats tab to message ${matchedUser.firstName}');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            shadowColor: _pink.withValues(alpha: 0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.messageCircle, size: 20),
                              SizedBox(width: 8),
                              Text("Send a Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── "Keep Swiping" link ──
                SlideTransition(
                  position: Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(_slideAnim),
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Keep Swiping',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final rng = Random(42);
    return List.generate(20, (i) {
      final left = rng.nextDouble() * MediaQuery.of(context).size.width;
      final delay = rng.nextDouble();
      final size = 6.0 + rng.nextDouble() * 8;
      final color = [_pink, _purple, const Color(0xFFFFD700), const Color(0xFF00BFFF)][i % 4];
      return AnimatedBuilder(
        animation: _confettiCtrl,
        builder: (ctx, _) {
          final t = (_confettiCtrl.value - delay * 0.4).clamp(0.0, 1.0);
          final y = -20.0 + t * (MediaQuery.of(context).size.height + 40);
          final opacity = t < 0.8 ? 1.0 : (1.0 - (t - 0.8) / 0.2);
          return Positioned(
            left: left + sin(t * pi * 3) * 30,
            top: y,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: t * pi * 2 * (i.isEven ? 1 : -1),
                child: Container(
                  width: size,
                  height: size * 0.7,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}


// ═══════════════════════════════════════════════════════════════════════════
class _MatchAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? lastName;
  final Color borderColor;

  const _MatchAvatar({this.imageUrl, this.name, this.lastName, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3.5),
        boxShadow: [
          BoxShadow(color: borderColor.withValues(alpha: 0.25), blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primarySurface,
                child: Center(
                  child: Text(
                    Helpers.getInitials(name, lastName),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ),
      ),
    );
  }
}
