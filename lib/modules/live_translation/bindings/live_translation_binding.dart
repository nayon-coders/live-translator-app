import 'package:get/get.dart';
import '../controllers/live_translation_controller.dart';

class LiveTranslationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveTranslationController>(() => LiveTranslationController());
  }
}
