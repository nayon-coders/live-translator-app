import 'package:get/get.dart';
import '../../../models/language_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../../services/translation_service.dart';

class LiveTranslationController extends GetxController with GetSingleTickerProviderStateMixin {
  final isListening = false.obs;
  final isTranslating = false.obs;
  final isSpeaking = false.obs;
  
  final recognizedText = ''.obs;
  final translatedText = ''.obs;
  
  // Get the selected languages from the Home Controller
  late final LanguageModel sourceLanguage;
  late final LanguageModel targetLanguage;

  final TranslationService _translationService = Get.find<TranslationService>();

  @override
  void onInit() {
    super.onInit();
    final homeController = Get.find<HomeController>();
    sourceLanguage = homeController.sourceLanguage;
    targetLanguage = homeController.targetLanguage;
    
    // Set up TTS completion handler
    _translationService.setCompletionHandler(() {
      isSpeaking.value = false;
    });
    
    // Auto-start listening when the page opens
    _startListening();
  }

  @override
  void onClose() {
    _translationService.stopListening();
    _translationService.stopSpeaking();
    super.onClose();
  }

  /// Start listening for speech in the source language.
  Future<void> _startListening() async {
    final ok = await _translationService.initSpeech();
    if (!ok) {
      Get.snackbar('Error', 'Speech recognition is not available on this device.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isListening.value = true;
    recognizedText.value = '';
    translatedText.value = '';

    final sttLocale = _translationService.getSttLocale(sourceLanguage.code);

    await _translationService.startListening(
      localeId: sttLocale,
      onResult: (text, isFinal) {
        recognizedText.value = text;
        
        if (isFinal && text.trim().isNotEmpty) {
          // When speech is finalized, translate and speak
          _translateAndSpeak(text);
        }
      },
    );
  }

  /// Translate the recognized text and speak it aloud.
  Future<void> _translateAndSpeak(String text) async {
    isListening.value = false;
    isTranslating.value = true;

    try {
      final result = await _translationService.translate(
        text: text,
        sourceCode: sourceLanguage.code,
        targetCode: targetLanguage.code,
      );

      translatedText.value = result;
      isTranslating.value = false;

      // Speak the translated text
      isSpeaking.value = true;
      await _translationService.speak(result, languageCode: targetLanguage.code);
    } catch (e) {
      isTranslating.value = false;
      translatedText.value = 'Translation failed. Please try again.';
    }
  }

  /// Toggle listening on/off.
  void toggleListening() {
    if (isListening.value) {
      _translationService.stopListening();
      isListening.value = false;
    } else {
      _startListening();
    }
  }

  /// Speak the translated text again (replay).
  void speakTranslation() {
    if (translatedText.value.isNotEmpty) {
      isSpeaking.value = true;
      _translationService.speak(translatedText.value, languageCode: targetLanguage.code);
    }
  }

  /// Speak the original recognized text.
  void speakOriginal() {
    if (recognizedText.value.isNotEmpty) {
      isSpeaking.value = true;
      _translationService.speak(recognizedText.value, languageCode: sourceLanguage.code);
    }
  }
}
