import 'package:get/get.dart';
import '../../../models/language_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../../services/translation_service.dart';

enum SpeakerSide { you, partner }

class LiveTranslationController extends GetxController with GetSingleTickerProviderStateMixin {
  final isListening = false.obs;
  final isTranslating = false.obs;
  final isSpeaking = false.obs;
  
  final recognizedText = ''.obs;
  final translatedText = ''.obs;
  
  /// Active speaker: you (source) or partner (target)
  final Rx<SpeakerSide> activeSpeaker = SpeakerSide.you.obs;

  late final Rx<LanguageModel> sourceLanguage;
  late final Rx<LanguageModel> targetLanguage;

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
    
    // Auto-start listening when the page opens
    _startListening();
  }

  @override
  void onClose() {
    _translationService.stopListening();
    _translationService.stopSpeaking();
    super.onClose();
  }

  /// Get currently speaking language
  LanguageModel get currentSpeakingLanguage =>
      activeSpeaker.value == SpeakerSide.you ? sourceLanguage.value : targetLanguage.value;

  /// Get target language to translate into
  LanguageModel get currentTranslationLanguage =>
      activeSpeaker.value == SpeakerSide.you ? targetLanguage.value : sourceLanguage.value;

  /// Start listening for speech in the current active speaker's language.
  Future<void> _startListening({SpeakerSide? side}) async {
    if (side != null) {
      activeSpeaker.value = side;
    }

    final ok = await _translationService.initSpeech();
    if (!ok) {
      Get.snackbar('Error', 'Speech recognition is not available on this device.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isListening.value = true;
    recognizedText.value = '';
    translatedText.value = '';

    final speakingLang = currentSpeakingLanguage;
    final sttLocale = _translationService.getSttLocale(speakingLang.code);

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

    final sourceLang = currentSpeakingLanguage;
    final destLang = currentTranslationLanguage;

    try {
      final result = await _translationService.translate(
        text: text,
        sourceCode: sourceLang.code,
        targetCode: destLang.code,
      );

      translatedText.value = result;
      isTranslating.value = false;

      // Speak the translated text in recipient's language
      isSpeaking.value = true;
      await _translationService.speak(result, languageCode: destLang.code);
    } catch (e) {
      isTranslating.value = false;
      translatedText.value = 'Translation failed. Please try again.';
    }
  }

  /// Toggle listening for a specific speaker
  void toggleListeningForSpeaker(SpeakerSide side) {
    if (isListening.value && activeSpeaker.value == side) {
      _translationService.stopListening();
      isListening.value = false;
    } else {
      if (isListening.value) {
        _translationService.stopListening();
      }
      activeSpeaker.value = side;
      _startListening();
    }
  }

  /// Toggle listening on/off for current active speaker
  void toggleListening() {
    if (isListening.value) {
      _translationService.stopListening();
      isListening.value = false;
    } else {
      _startListening();
    }
  }

  /// Set the active speaker tab
  void setActiveSpeaker(SpeakerSide side) {
    if (activeSpeaker.value != side) {
      activeSpeaker.value = side;
      recognizedText.value = '';
      translatedText.value = '';
      if (isListening.value) {
        _restartListening();
      }
    }
  }

  /// Update source language ("You")
  void setSourceLanguage(LanguageModel lang) {
    sourceLanguage.value = lang;
    _homeController.selectLanguage(lang, true);
    if (isListening.value && activeSpeaker.value == SpeakerSide.you) {
      _restartListening();
    }
  }

  /// Update target language ("Partner")
  void setTargetLanguage(LanguageModel lang) {
    targetLanguage.value = lang;
    _homeController.selectLanguage(lang, false);
    if (isListening.value && activeSpeaker.value == SpeakerSide.partner) {
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

  /// Speak the translated text again (replay).
  void speakTranslation() {
    if (translatedText.value.isNotEmpty) {
      isSpeaking.value = true;
      _translationService.speak(
        translatedText.value,
        languageCode: currentTranslationLanguage.code,
      );
    }
  }

  /// Speak the original recognized text.
  void speakOriginal() {
    if (recognizedText.value.isNotEmpty) {
      isSpeaking.value = true;
      _translationService.speak(
        recognizedText.value,
        languageCode: currentSpeakingLanguage.code,
      );
    }
  }
}
