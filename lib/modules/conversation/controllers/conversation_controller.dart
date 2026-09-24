import 'package:get/get.dart';
import '../../../models/language_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../../services/translation_service.dart';

class ChatMessage {
  final String originalText;
  final String translatedText;
  final bool isPerson1; // true = source language speaker, false = target language speaker

  ChatMessage({
    required this.originalText,
    required this.translatedText,
    required this.isPerson1,
  });
}

class ConversationController extends GetxController {
  final isListening = false.obs;
  final isTranslating = false.obs;
  final isSpeaking = false.obs;
  
  /// Which person is currently speaking?
  /// true = Person 1 (source language), false = Person 2 (target language)
  final isPerson1Turn = true.obs;
  
  /// Current partial recognized text while listening
  final currentRecognizedText = ''.obs;
  
  /// All chat messages
  final messages = <ChatMessage>[].obs;
  
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
  }

  @override
  void onClose() {
    _translationService.stopListening();
    _translationService.stopSpeaking();
    super.onClose();
  }

  /// Get the language the current speaker uses.
  LanguageModel get currentSpeakerLanguage =>
      isPerson1Turn.value ? sourceLanguage : targetLanguage;

  /// Get the language to translate into.
  LanguageModel get currentTargetLanguage =>
      isPerson1Turn.value ? targetLanguage : sourceLanguage;

  /// Toggle mic: start/stop listening.
  void toggleListening() {
    if (isListening.value) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  /// Switch which person is speaking next.
  void switchPerson() {
    if (!isListening.value) {
      isPerson1Turn.value = !isPerson1Turn.value;
    }
  }

  /// Start listening for speech in the current person's language.
  Future<void> _startListening() async {
    final ok = await _translationService.initSpeech();
    if (!ok) {
      Get.snackbar('Error', 'Speech recognition is not available.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isListening.value = true;
    currentRecognizedText.value = '';

    final speakerLang = currentSpeakerLanguage;
    final sttLocale = _translationService.getSttLocale(speakerLang.code);

    await _translationService.startListening(
      localeId: sttLocale,
      onResult: (text, isFinal) {
        currentRecognizedText.value = text;

        if (isFinal && text.trim().isNotEmpty) {
          _processMessage(text);
        }
      },
    );
  }

  /// Stop listening.
  Future<void> _stopListening() async {
    await _translationService.stopListening();
    isListening.value = false;
  }

  /// Process recognized speech: translate and add to chat.
  Future<void> _processMessage(String text) async {
    isListening.value = false;
    isTranslating.value = true;

    final speakerLang = currentSpeakerLanguage;
    final targetLang = currentTargetLanguage;

    try {
      final translated = await _translationService.translate(
        text: text,
        sourceCode: speakerLang.code,
        targetCode: targetLang.code,
      );

      // Add message to chat
      messages.add(ChatMessage(
        originalText: text,
        translatedText: translated,
        isPerson1: isPerson1Turn.value,
      ));

      isTranslating.value = false;

      // Speak the translated text in the target language
      isSpeaking.value = true;
      await _translationService.speak(translated, languageCode: targetLang.code);

      // Auto-switch turn after speaking
      isPerson1Turn.value = !isPerson1Turn.value;
    } catch (e) {
      isTranslating.value = false;
      Get.snackbar('Error', 'Translation failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Speak a specific message's translated text.
  void speakMessage(ChatMessage message) {
    final lang = message.isPerson1 ? targetLanguage : sourceLanguage;
    isSpeaking.value = true;
    _translationService.speak(message.translatedText, languageCode: lang.code);
  }
}
