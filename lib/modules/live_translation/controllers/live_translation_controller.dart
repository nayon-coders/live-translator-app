import 'package:get/get.dart';
import '../../../../models/language_model.dart';
import '../../home/controllers/home_controller.dart';

class LiveTranslationController extends GetxController with GetSingleTickerProviderStateMixin {
  final isListening = true.obs;
  
  // Get the selected languages from the Home Controller
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
