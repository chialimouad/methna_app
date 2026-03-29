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

  static final List<Widget> _pages = [
    const HomeScreen(),
    const UsersScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isHome = controller.currentIndex.value == 0;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: isHome ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBody: true,
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          ),
          bottomNavigationBar: const AppBottomNavBar(),
        ),
      );
    });
  }
}
