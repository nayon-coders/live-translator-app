import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/language_model.dart';
import '../../../services/remote_config_service.dart';
import '../../../services/translation_service.dart';
import '../../../services/api_client.dart';
import '../../home/controllers/home_controller.dart';

class FriendChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  FriendChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiFriendController extends GetxController {
  final RemoteConfigService _config = Get.find<RemoteConfigService>();
  final TranslationService _translationService = Get.find<TranslationService>();
  final ApiClient _api = Get.find<ApiClient>();

  late final Rx<LanguageModel> selectedLanguage;

  final RxList<FriendChatMessage> messages = <FriendChatMessage>[].obs;
  final RxBool isListening = false.obs;
  final RxBool isThinking = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxString currentRecognizedText = ''.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController textInputController = TextEditingController();

  final List<String> conversationStarters = [
    "How's your day going? 😊",
    "Tell me a fun fact! 💡",
    "Tell me a funny joke 😂",
    "What should I do today? 🌟",
    "Let's talk about travel ✈️",
  ];

  @override
  void onInit() {
    super.onInit();

    // Default to Home controller's source language or English
    if (Get.isRegistered<HomeController>()) {
      selectedLanguage = Get.find<HomeController>().sourceLanguage.obs;
    } else {
      final defaultLang = _config.languages.firstWhere(
        (l) => l.code == 'en',
        orElse: () => appLanguages.first,
      );
      selectedLanguage = defaultLang.obs;
    }

    _translationService.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    _translationService.onSpeechStatus = (status) {
      debugPrint('AiFriend speech status: $status');
      if (status == 'done' || status == 'notListening') {
        if (isListening.value) {
          isListening.value = false;
          if (currentRecognizedText.value.trim().isNotEmpty) {
            final text = currentRecognizedText.value.trim();
            currentRecognizedText.value = '';
            sendMessage(text);
          }
        }
      }
    };

    _translationService.onSpeechError = (error) {
      debugPrint('AiFriend speech error: $error');
      isListening.value = false;

      // If user had already spoken some words before timeout, send them
      if (currentRecognizedText.value.trim().isNotEmpty) {
        final text = currentRecognizedText.value.trim();
        currentRecognizedText.value = '';
        sendMessage(text);
        return;
      }

      currentRecognizedText.value = '';
    };

    // Auto-scroll listeners
    ever(messages, (_) => scrollToBottom());
    ever(isThinking, (val) {
      if (val == true) scrollToBottom();
    });
    ever(currentRecognizedText, (val) {
      if (val.toString().isNotEmpty) scrollToBottom();
    });

    // Send initial greeting in selected language
    _sendInitialGreeting();
  }

  void _sendInitialGreeting() {
    final lang = selectedLanguage.value;
    String greeting;

    switch (lang.code) {
      case 'bn':
        greeting = "নমস্কার বন্ধু! আমি তোমার এআই ফ্রেন্ড। তোমার সাথে কথা বলতে পেরে খুব আনন্দ হচ্ছে! আজ তোমার দিন কেমন কাটছে?";
        break;
      case 'hi':
        greeting = "नमस्ते दोस्त! मैं आपका एआई फ्रेंड हूँ। आपसे बात करके बहुत खुशी हुई! आज आपका दिन कैसा चल रहा है?";
        break;
      case 'es':
        greeting = "¡Hola amigo! Soy tu amigo de IA. ¡Qué alegría charlar contigo! ¿Cómo va tu día hoy?";
        break;
      case 'fr':
        greeting = "Bonjour mon ami ! Je suis ton ami IA. Ravi de discuter avec toi ! Comment se passe ta journée ?";
        break;
      case 'ar':
        greeting = "مرحباً يا صديقي! أنا صديقك الذكي. يسعدني جداً التحدث معك! كيف يسير يومك اليوم؟";
        break;
      case 'de':
        greeting = "Hallo mein Freund! Ich bin dein KI-Freund. Schön, mit dir zu sprechen! Wie geht es dir heute?";
        break;
      case 'ja':
        greeting = "こんにちは！AIフレンドです。お話しできて嬉しいです！今日の調子はどうですか？";
        break;
      case 'en':
      default:
        greeting = "Hey there! I'm your AI Friend. It's wonderful to chat with you! How is your day going so far?";
        break;
    }

    messages.add(FriendChatMessage(text: greeting, isUser: false));
    _speakText(greeting);
  }

  /// Change conversational language
  void changeLanguage(LanguageModel lang) {
    if (selectedLanguage.value.code == lang.code) return;
    selectedLanguage.value = lang;

    // Stop existing audio
    _translationService.stopSpeaking();
    _translationService.stopListening();
    isSpeaking.value = false;
    isListening.value = false;

    // Send switched greeting in new language
    String switchNotice;
    switch (lang.code) {
      case 'bn':
        switchNotice = "দারুণ! এখন থেকে আমরা বাংলায় কথা বলব। তুমি কী নিয়ে গল্প করতে চাও?";
        break;
      case 'hi':
        switchNotice = "बहुत बढ़िया! अब हम हिंदी में बात करेंगे। आप क्या चर्चा करना चाहते हैं?";
        break;
      case 'es':
        switchNotice = "¡Genial! A partir de ahora hablaremos en español. ¿De qué te gustaría hablar?";
        break;
      case 'fr':
        switchNotice = "Super ! À partir de maintenant, nous parlons en français. De quoi aimerais-tu parler ?";
        break;
      case 'ar':
        switchNotice = "رائع! من الآن فصاعداً سنتحدث باللغة العربية. ما الذي ترغب في مناقشته؟";
        break;
      case 'de':
        switchNotice = "Klasse! Ab jetzt sprechen wir auf Deutsch. Worüber möchtest du sprechen?";
        break;
      case 'ja':
        switchNotice = "いいね！これからは日本語でお話ししましょう。何について話したいですか？";
        break;
      case 'en':
      default:
        switchNotice = "Awesome! We will chat in English now. What's on your mind?";
        break;
    }

    messages.add(FriendChatMessage(text: switchNotice, isUser: false));
    _speakText(switchNotice);
  }

  /// Map 2-letter language code to speech-to-text locale ID
  String _getLocaleForLang(String code) {
    final map = {
      'en': 'en_US',
      'bn': 'bn_BD',
      'hi': 'hi_IN',
      'es': 'es_ES',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'ar': 'ar_SA',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'zh-CN': 'zh_CN',
      'zh-TW': 'zh_TW',
      'it': 'it_IT',
      'pt': 'pt_BR',
      'ru': 'ru_RU',
      'tr': 'tr_TR',
      'th': 'th_TH',
      'vi': 'vi_VN',
      'id': 'id_ID',
      'ur': 'ur_PK',
    };
    return map[code] ?? '${code}_${code.toUpperCase()}';
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    if (isSpeaking.value) {
      await _translationService.stopSpeaking();
      isSpeaking.value = false;
      await Future.delayed(const Duration(milliseconds: 350));
    }

    if (_translationService.isListening) {
      await _translationService.stopListening();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final ok = await _translationService.initSpeech();
    if (!ok) {
      Get.snackbar(
        'Speech Error',
        'Microphone is unavailable or speech recognition is not supported.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xCCEF4444),
        colorText: Colors.white,
      );
      return;
    }

    isListening.value = true;
    currentRecognizedText.value = '';

    final locale = _getLocaleForLang(selectedLanguage.value.code);
    await _translationService.startListening(
      localeId: locale,
      onResult: (text, isFinal) {
        currentRecognizedText.value = text;
        if (isFinal && text.trim().isNotEmpty) {
          stopListening();
          sendMessage(text);
        }
      },
    );
  }

  Future<void> stopListening() async {
    await _translationService.stopListening();
    isListening.value = false;
    if (currentRecognizedText.value.trim().isNotEmpty) {
      final textToSend = currentRecognizedText.value.trim();
      currentRecognizedText.value = '';
      sendMessage(textToSend);
    }
  }

  bool _isAdultContent(String text) {
    final regex = RegExp(
      r'\b(porn|porno|pornography|sex|sexy|sexual|erotic|nude|naked|nudity|nsfw|boobs|penis|vagina|blowjob|masturbat\w*|horny|orgasm|intercourse|fetish|xxx|choda|chuda|magi|bessha|randi|chudi|chudai)\b',
      caseSensitive: false,
    );
    return regex.hasMatch(text);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isThinking.value) return;

    if (_isAdultContent(trimmed)) {
      textInputController.clear();
      Get.snackbar(
        'Content Warning',
        'Adult, sexual, or inappropriate content is strictly prohibited.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xCCEF4444),
        colorText: Colors.white,
      );
      return;
    }

    textInputController.clear();
    messages.add(FriendChatMessage(text: trimmed, isUser: true));
    isThinking.value = true;

    // Build recent conversation history
    final history = messages
        .take(messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    try {
      final reply = await _api.sendLiveChatMessage(
        message: trimmed,
        feature: 'ai_friend',
        languageName: selectedLanguage.value.name,
        languageCode: selectedLanguage.value.code,
        history: history,
      );

      isThinking.value = false;

      if (reply != null && reply.trim().isNotEmpty) {
        messages.add(FriendChatMessage(text: reply.trim(), isUser: false));
        _speakText(reply.trim());
      } else {
        Get.snackbar(
          'Notice',
          'AI Friend could not respond. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isThinking.value = false;
      debugPrint('Error sending message to AI Friend: $e');
      Get.snackbar(
        'Error',
        'Failed to connect to AI Friend.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _speakText(String text) async {
    isSpeaking.value = true;
    await _translationService.stopSpeaking();
    final cleanText = text.replaceAll('**', '').replaceAll('*', '').replaceAll('#', '').trim();
    await _translationService.speak(cleanText, languageCode: selectedLanguage.value.code);
  }

  Future<void> replayMessage(String text) async {
    await _speakText(text);
  }

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
    Future.delayed(const Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void clearChat() {
    messages.clear();
    _sendInitialGreeting();
  }

  @override
  void onClose() {
    _translationService.stopSpeaking();
    _translationService.stopListening();
    scrollController.dispose();
    textInputController.dispose();
    super.onClose();
  }
}
