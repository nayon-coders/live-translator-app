import 'package:get/get.dart';
import '../controllers/ai_friend_controller.dart';

class AiFriendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiFriendController>(() => AiFriendController());
  }
}
