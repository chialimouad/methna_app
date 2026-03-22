import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/navigation_controller.dart';
import 'package:methna_app/core/widgets/bottom_nav_bar.dart';
import 'package:methna_app/screens/main/home/home_screen.dart';
import 'package:methna_app/screens/main/users/users_screen.dart';
import 'package:methna_app/screens/main/chat/chat_list_screen.dart';
import 'package:methna_app/screens/main/profile/profile_screen.dart';

class MainScreen extends GetView<NavigationController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const UsersScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Obx(() {
      // Use light status bar icons on home (full-screen image), dark on others
      final isHome = controller.currentIndex.value == 0;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: isHome
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: const AppBottomNavBar(),
        ),
      );
    });
  }
}
