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
    _TabDef(LucideIcons.infinity, 'Home'),
    _TabDef(LucideIcons.users, 'Matches'),
    _TabDef(LucideIcons.messageSquare, 'Chats'),
    _TabDef(LucideIcons.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Obx(() {
      final selected = controller.currentIndex.value;
      final chatCtrl = Get.isRegistered<ChatController>() ? Get.find<ChatController>() : null;
      
      // Consistent brand color
      Color activeColor = _accent;

      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad > 0 ? bottomPad + 8 : 12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 1. Glossy Pill Background (Smaller & More Transparent)
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 2. Icons overlay
            SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_tabs.length, (i) {
                  final isActive = selected == i;
                  final tab = _tabs[i];
                  final hasBadge = i == 2 && (chatCtrl?.totalUnread ?? 0) > 0;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changePage(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            width: isActive ? 40 : 32,
                            height: isActive ? 40 : 32,
                            decoration: BoxDecoration(
                              color: isActive ? activeColor : Colors.transparent,
                              shape: BoxShape.circle,
                              boxShadow: isActive ? [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ] : [],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  tab.icon,
                                  color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                  size: isActive ? 20 : 22,
                                ),
                                if (hasBadge && !isActive)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: activeColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: isActive ? activeColor : Colors.white.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                            ),
                            child: Text(tab.label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
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
