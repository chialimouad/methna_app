import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void goToHome() => currentIndex.value = 0;
  void goToUsers() => currentIndex.value = 1;
  void goToChat() => currentIndex.value = 2;
  void goToProfile() => currentIndex.value = 3;
}
