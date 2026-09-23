import 'package:get/get.dart';
import '../../../../models/language_model.dart';
import '../../home/controllers/home_controller.dart';

class ConversationController extends GetxController {
  final isListening = false.obs;
  
  late final LanguageModel sourceLanguage;
  late final LanguageModel targetLanguage;

  @override
  void onInit() {
    super.onInit();
    final homeController = Get.find<HomeController>();
    sourceLanguage = homeController.sourceLanguage;
    targetLanguage = homeController.targetLanguage;
  }

  void toggleListening() {
    isListening.value = !isListening.value;
  }
}
