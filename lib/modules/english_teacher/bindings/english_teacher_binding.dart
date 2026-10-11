import 'package:get/get.dart';
import '../controllers/english_teacher_controller.dart';
import '../../../services/gemini_live_service.dart';

class EnglishTeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GeminiLiveService>(() => GeminiLiveService());
    Get.lazyPut<EnglishTeacherController>(() => EnglishTeacherController());
  }
}
