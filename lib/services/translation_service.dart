import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator_plus/translator_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

/// Centralized service for Speech-to-Text, Translation, and Text-to-Speech.
/// Both LiveTranslation and Conversation modules reuse this service.
class TranslationService extends GetxService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  bool _isInitialized = false;

  /// Initialize the speech recognition engine.
  Future<bool> initSpeech() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    return _isInitialized;
  }

  /// Configure TTS for natural, human-like voice.
  Future<void> configureTts({String? languageCode}) async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45); // Slightly slower = more natural
    await _tts.setPitch(1.0);
    if (languageCode != null) {
      // Map our app language codes to TTS locale codes
      final ttsLang = _mapToTtsLocale(languageCode);
      await _tts.setLanguage(ttsLang);
    }
  }

  /// Start listening to the microphone.
  /// [localeId] should be the language code like 'en-US', 'bn-BD', 'hi-IN'
  /// [onResult] callback fires whenever speech is recognized.
  Future<void> startListening({
    required String localeId,
    required Function(String text, bool isFinal) onResult,
  }) async {
    if (!_isInitialized) {
      final ok = await initSpeech();
      if (!ok) return;
    }

    try {
      // Find best matching locale from device's supported locales
      final systemLocales = await _speech.locales();
      String? bestLocaleId;
      
      final prefix = localeId.split('_').first.split('-').first;
      
      for (var l in systemLocales) {
        if (l.localeId.replaceAll('-', '_') == localeId.replaceAll('-', '_')) {
          bestLocaleId = l.localeId;
          break;
        }
      }
      
      if (bestLocaleId == null) {
        for (var l in systemLocales) {
          if (l.localeId.startsWith(prefix)) {
            bestLocaleId = l.localeId;
            break;
          }
        }
      }
      
      bestLocaleId ??= localeId;
      debugPrint('STT using locale: $bestLocaleId');

      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          localeId: bestLocaleId,
        ),
      );
    } catch (e) {
      debugPrint("Speech listen error: $e");
      Get.snackbar('Microphone Error', 'Could not start listening for this language. It might not be supported on this device.', snackPosition: SnackPosition.BOTTOM);
      // Reset state if possible
      final convController = Get.isRegistered<dynamic>(tag: 'ConversationController') ? Get.find<dynamic>(tag: 'ConversationController') : null;
      if (convController != null) {
          try { convController.isListening.value = false; } catch (_) {}
      }
    }
  }

  /// Stop listening.
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Check if speech recognition is currently active.
  bool get isListening => _speech.isListening;

  /// Translate text from [sourceCode] to [targetCode].
  /// Returns the translated string.
  Future<String> translate({
    required String text,
    required String sourceCode,
    required String targetCode,
  }) async {
    if (text.trim().isEmpty) return '';
    try {
      final translation = await _translator.translate(
        text,
        from: _normalizeCode(sourceCode),
        to: _normalizeCode(targetCode),
      );
      return translation.text;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Fallback: return original text
    }
  }

  /// Speak the given text aloud using TTS.
  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;
    await configureTts(languageCode: languageCode);
    await _tts.speak(text);
  }

  /// Stop speaking.
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Set a completion handler for when TTS finishes speaking.
  void setCompletionHandler(Function() handler) {
    _tts.setCompletionHandler(handler);
  }

  /// Map our language codes to TTS-compatible locale strings.
  String _mapToTtsLocale(String code) {
    final map = {
      'en': 'en-US',
      'es': 'es-ES',
      'zh-CN': 'zh-CN',
      'zh-TW': 'zh-TW',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'pt': 'pt-BR',
      'ru': 'ru-RU',
      'ar': 'ar-SA',
      'it': 'it-IT',
      'nl': 'nl-NL',
      'tr': 'tr-TR',
      'vi': 'vi-VN',
      'th': 'th-TH',
      'id': 'id-ID',
      'ms': 'ms-MY',
      'bn': 'bn-BD',
      'hi': 'hi-IN',
      'ur': 'ur-PK',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'kn': 'kn-IN',
      'ml': 'ml-IN',
      'gu': 'gu-IN',
      'mr': 'mr-IN',
      'pa': 'pa-IN',
      'pl': 'pl-PL',
      'uk': 'uk-UA',
      'ro': 'ro-RO',
      'el': 'el-GR',
      'cs': 'cs-CZ',
      'hu': 'hu-HU',
      'sv': 'sv-SE',
      'da': 'da-DK',
      'fi': 'fi-FI',
      'no': 'nb-NO',
      'he': 'he-IL',
      'fa': 'fa-IR',
      'sw': 'sw-KE',
      'af': 'af-ZA',
      'bg': 'bg-BG',
      'hr': 'hr-HR',
      'sk': 'sk-SK',
      'sl': 'sl-SI',
      'ca': 'ca-ES',
      'cy': 'cy-GB',
    };
    return map[code] ?? code;
  }

  /// Normalize language codes for translator_plus.
  /// translator_plus uses 2-letter ISO codes.
  String _normalizeCode(String code) {
    // Handle special cases
    if (code == 'zh-CN') return 'zh-cn';
    if (code == 'zh-TW') return 'zh-tw';
    // For codes with hyphens, just take the base
    if (code.contains('-') && code != 'zh-cn' && code != 'zh-tw') {
      return code.split('-').first;
    }
    return code;
  }

  /// Get the STT locale ID from our app language code.
  /// STT needs locale format like 'en_US', 'bn_BD', etc.
  String getSttLocale(String code) {
    final map = {
      'en': 'en_US',
      'es': 'es_ES',
      'zh-CN': 'zh_CN',
      'zh-TW': 'zh_TW',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'pt': 'pt_BR',
      'ru': 'ru_RU',
      'ar': 'ar_SA',
      'it': 'it_IT',
      'nl': 'nl_NL',
      'tr': 'tr_TR',
      'vi': 'vi_VN',
      'th': 'th_TH',
      'id': 'id_ID',
      'ms': 'ms_MY',
      'bn': 'bn_BD',
      'hi': 'hi_IN',
      'ur': 'ur_PK',
      'ta': 'ta_IN',
      'te': 'te_IN',
      'kn': 'kn_IN',
      'ml': 'ml_IN',
      'gu': 'gu_IN',
      'mr': 'mr_IN',
      'pa': 'pa_IN',
      'pl': 'pl_PL',
      'uk': 'uk_UA',
      'ro': 'ro_RO',
      'el': 'el_GR',
      'cs': 'cs_CZ',
      'hu': 'hu_HU',
      'sv': 'sv_SE',
      'da': 'da_DK',
      'fi': 'fi_FI',
      'no': 'nb_NO',
      'he': 'he_IL',
      'fa': 'fa_IR',
      'sw': 'sw_KE',
      'af': 'af_ZA',
      'bg': 'bg_BG',
      'hr': 'hr_HR',
      'sk': 'sk_SK',
      'sl': 'sl_SI',
    };
    return map[code] ?? code;
  }
}
