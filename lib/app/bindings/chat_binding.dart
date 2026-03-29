import 'package:get/get.dart';
import 'package:methna_app/app/controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController(), permanent: true);
    }
  }
}
