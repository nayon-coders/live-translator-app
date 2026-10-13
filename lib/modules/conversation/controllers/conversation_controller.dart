import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/language_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../../services/translation_service.dart';

class ChatMessage {
  final String originalText;
  final String translatedText;
  final bool isPerson1; // true = You (Source language), false = Partner (Target language)
  final String speakerLanguageName;
  final String targetLanguageName;
  final String speakerCountryCode;
  final String targetCountryCode;
  final DateTime timestamp;

  ChatMessage({
    required this.originalText,
    required this.translatedText,
    required this.isPerson1,
    required this.speakerLanguageName,
    required this.targetLanguageName,
    required this.speakerCountryCode,
    required this.targetCountryCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ConversationController extends GetxController {
  final isListening = false.obs;
  final isTranslating = false.obs;
  final isSpeaking = false.obs;
  
  /// Which person is currently speaking?
  /// true = Person 1 ("You" / source language), false = Person 2 ("Partner" / target language)
  final isPerson1Turn = true.obs;
  
  /// Current partial recognized text while listening
  final currentRecognizedText = ''.obs;
  
  /// All chat messages
  final messages = <ChatMessage>[].obs;
  
  late final Rx<LanguageModel> sourceLanguage;
  late final Rx<LanguageModel> targetLanguage;

  final ScrollController scrollController = ScrollController();

  final TranslationService _translationService = Get.find<TranslationService>();
  late final HomeController _homeController;

  @override
  void onInit() {
    super.onInit();
    _homeController = Get.find<HomeController>();
    sourceLanguage = _homeController.sourceLanguage.obs;
    targetLanguage = _homeController.targetLanguage.obs;

    // Set up TTS completion handler
    _translationService.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    // Auto-scroll whenever messages list updates
    ever(messages, (_) {
      scrollToBottom();
    });
  }

  @override
  void onClose() {
    _translationService.stopListening();
    _translationService.stopSpeaking();
    scrollController.dispose();
    super.onClose();
  }

  /// Automatically scroll smoothly to the latest message
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  /// Get the language the current speaker uses.
  LanguageModel get currentSpeakerLanguage =>
      isPerson1Turn.value ? sourceLanguage.value : targetLanguage.value;

  /// Get the language to translate into.
  LanguageModel get currentTargetLanguage =>
      isPerson1Turn.value ? targetLanguage.value : sourceLanguage.value;

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
      currentRecognizedText.value = '';
    }
  }

  /// Explicitly set whose turn it is
  void setPersonTurn(bool isPerson1) {
    if (isPerson1Turn.value != isPerson1) {
      isPerson1Turn.value = isPerson1;
      currentRecognizedText.value = '';
      if (isListening.value) {
        _restartListening();
      }
    }
  }

  /// Toggle listening for a specific speaker
  void toggleListeningForPerson(bool isPerson1) {
    if (isListening.value && isPerson1Turn.value == isPerson1) {
      _stopListening();
    } else {
      if (isListening.value) {
        _translationService.stopListening();
      }
      isPerson1Turn.value = isPerson1;
      _startListening();
    }
  }

  /// Update source language ("You")
  void setSourceLanguage(LanguageModel lang) {
    sourceLanguage.value = lang;
    _homeController.selectLanguage(lang, true);
    if (isListening.value && isPerson1Turn.value) {
      _restartListening();
    }
  }

  /// Update target language ("Partner")
  void setTargetLanguage(LanguageModel lang) {
    targetLanguage.value = lang;
    _homeController.selectLanguage(lang, false);
    if (isListening.value && !isPerson1Turn.value) {
      _restartListening();
    }
  }

  /// Swap source and target languages
  void swapLanguages() {
    final temp = sourceLanguage.value;
    sourceLanguage.value = targetLanguage.value;
    targetLanguage.value = temp;
    _homeController.swapLanguages();
    if (isListening.value) {
      _restartListening();
    }
  }

  void _restartListening() {
    _translationService.stopListening();
    _startListening();
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
    final isP1 = isPerson1Turn.value;

    try {
      final translated = await _translationService.translate(
        text: text,
        sourceCode: speakerLang.code,
        targetCode: targetLang.code,
      );

      // Add message to chat with full metadata
      messages.add(ChatMessage(
        originalText: text,
        translatedText: translated,
        isPerson1: isP1,
        speakerLanguageName: speakerLang.name,
        targetLanguageName: targetLang.name,
        speakerCountryCode: speakerLang.countryCode,
        targetCountryCode: targetLang.countryCode,
      ));

      isTranslating.value = false;

      // Speak the translated text in the target language
      isSpeaking.value = true;
      await _translationService.speak(translated, languageCode: targetLang.code);

      // Auto-switch turn after speaking
      isPerson1Turn.value = !isP1;
    } catch (e) {
      isTranslating.value = false;
      Get.snackbar('Error', 'Translation failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Speak a specific message's translated text.
  void speakMessage(ChatMessage message) {
    final langCode = message.isPerson1 ? targetLanguage.value.code : sourceLanguage.value.code;
    isSpeaking.value = true;
    _translationService.speak(message.translatedText, languageCode: langCode);
  }
}
