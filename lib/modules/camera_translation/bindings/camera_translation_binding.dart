import 'package:get/get.dart';
import '../controllers/camera_translation_controller.dart';

class CameraTranslationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraTranslationController>(
      () => CameraTranslationController(),
    );
  }
}
