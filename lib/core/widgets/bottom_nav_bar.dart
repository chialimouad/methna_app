import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/navigation_controller.dart';
import 'package:methna_app/app/controllers/chat_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// iOS 26 liquid-glass bottom nav bar.
/// Ultra-thin translucent bar with strong backdrop blur, clean icons + labels.
class AppBottomNavBar extends GetView<NavigationController> {
  const AppBottomNavBar({super.key});

  static const _accent = AppColors.primary;

  static const _tabs = [
    _TabDef(LucideIcons.heart, 'Home'), // Or another appropriate icon
    _TabDef(LucideIcons.users, 'Discover'),
    _TabDef(LucideIcons.messageCircle, 'Chat'),
    _TabDef(LucideIcons.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selected = controller.currentIndex.value;

      return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad > 0 ? bottomPad + 4 : 20),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // 1. Glossy Pill Background
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // 2. Icons overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 90, // taller than the pill to allow the active button to float
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_tabs.length, (i) {
                    final isActive = selected == i;
                    final tab = _tabs[i];
                    final hasBadge = i == 2 && chatCtrl.totalUnread > 0;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.changePage(i),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: 90,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Inactive Grey Icon
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: isActive ? 0.0 : 1.0,
                                curve: Curves.easeInOut,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        tab.icon,
                                        size: 26,
                                        color: isDark ? Colors.white54 : Colors.black.withValues(alpha: 0.6),
                                      ),
                                      if (hasBadge && !isActive)
                                        Positioned(
                                          right: -2,
                                          top: -2,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: _accent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Active Pink Floating Circle
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutBack,
                                bottom: isActive ? 22 : 0,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isActive ? 1.0 : 0.0,
                                  child: IgnorePointer(
                                    ignoring: !isActive,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: _accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isDark ? const Color(0xFF1A1425) : Colors.white, width: 4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _accent.withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          )
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        clipBehavior: Clip.none,
                                        children: [
                                          TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            duration: const Duration(milliseconds: 400),
                                            curve: Curves.elasticOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: 0.5 + 0.5 * value,
                                                child: Transform.rotate(
                                                  angle: (1.0 - value) * 0.3,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: Icon(tab.icon, color: Colors.white, size: 28),
                                          ),
                                          if (hasBadge)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: AppColors.error,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: _accent, width: 2),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TabDef {
  final IconData icon;
  final String label;
  const _TabDef(this.icon, this.label);
}
