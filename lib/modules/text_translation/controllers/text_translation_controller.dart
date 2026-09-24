import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/language_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../../services/translation_service.dart';

class TextTranslationController extends GetxController {
  final isExpanded = true.obs;
  
  final textController = TextEditingController();
  final translatedText = ''.obs;
  final isTranslating = false.obs;
  final isSpeaking = false.obs;

  late final LanguageModel sourceLanguage;
  late final LanguageModel targetLanguage;

  final TranslationService _translationService = Get.find<TranslationService>();

  @override
  void onInit() {
    super.onInit();
    final homeController = Get.find<HomeController>();
    sourceLanguage = homeController.sourceLanguage;
    targetLanguage = homeController.targetLanguage;
    
    _translationService.setCompletionHandler(() {
      isSpeaking.value = false;
    });
  }
  
  @override
  void onClose() {
    textController.dispose();
    _translationService.stopSpeaking();
    super.onClose();
  }

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  Future<void> translateText() async {
    final text = textController.text.trim();
    if (text.isEmpty) {
      translatedText.value = '';
      return;
    }

    isTranslating.value = true;
    try {
      final result = await _translationService.translate(
        text: text,
        sourceCode: sourceLanguage.code,
        targetCode: targetLanguage.code,
      );
      translatedText.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to translate text.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isTranslating.value = false;
    }
  }

  void speakSource() {
    if (textController.text.isNotEmpty) {
      isSpeaking.value = true;
      _translationService.speak(textController.text, languageCode: sourceLanguage.code);
    }
  }

  void speakTarget() {
    if (translatedText.value.isNotEmpty) {
      isSpeaking.value = true;
      _translationService.speak(translatedText.value, languageCode: targetLanguage.code);
    }
  }

  void copyToClipboard() {
    if (translatedText.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: translatedText.value));
      Get.snackbar('Copied', 'Translation copied to clipboard!', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    }
  }
  
  void clearText() {
    textController.clear();
    translatedText.value = '';
  }
}
