import 'package:get/get.dart';
import '../controllers/text_translation_controller.dart';

class TextTranslationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TextTranslationController>(() => TextTranslationController());
  }
}
