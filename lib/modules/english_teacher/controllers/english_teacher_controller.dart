import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/remote_config_service.dart';
import '../../../services/translation_service.dart';
import '../../../services/api_client.dart';

class TeacherChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  TeacherChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class EnglishTeacherController extends GetxController {
  final RemoteConfigService _config = Get.find<RemoteConfigService>();
  final TranslationService _translationService = Get.find<TranslationService>();
  final ApiClient _api = Get.find<ApiClient>();

  final RxList<dynamic> modes = <dynamic>[].obs;
  final RxString selectedModeKey = ''.obs;
  
  final RxBool isSessionActive = false.obs;
  final RxBool isListening = false.obs;
  final RxBool isThinking = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxString currentRecognizedText = ''.obs;
  final RxList<TeacherChatMessage> messages = <TeacherChatMessage>[].obs;

  String? _currentSessionId;
  DateTime? _sessionStartTime;
  
  final TextEditingController textInputController = TextEditingController();

  static const List<Map<String, dynamic>> defaultPracticeModes = [
    {
      'key': 'teacher',
      'title': 'General Teacher',
      'description': 'Have a casual conversation to practice English',
    },
    {
      'key': 'interviewer',
      'title': 'Job Interview',
      'description': 'Practice a formal job interview',
    },
    {
      'key': 'waiter',
      'title': 'Restaurant',
      'description': 'Order food in a restaurant',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    if (_config.practiceModes.isNotEmpty) {
      modes.assignAll(_config.practiceModes);
    } else {
      modes.assignAll(defaultPracticeModes);
    }

    // Keep synced if remote config loads
    ever(_config.practiceModes, (List<dynamic> updated) {
      if (updated.isNotEmpty) {
        modes.assignAll(updated);
        if (!modes.any((m) => m['key'] == selectedModeKey.value)) {
          selectedModeKey.value = modes.first['key'];
        }
      }
    });

    if (modes.isNotEmpty && selectedModeKey.value.isEmpty) {
      selectedModeKey.value = modes.first['key'];
    }

    _translationService.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    _translationService.onSpeechStatus = (status) {
      debugPrint('EnglishTeacher speech status: $status');
      if (status == 'done' || status == 'notListening') {
        if (isListening.value) {
          isListening.value = false;
          if (currentRecognizedText.value.trim().isNotEmpty) {
            final textToSend = currentRecognizedText.value.trim();
            currentRecognizedText.value = '';
            sendMessage(textToSend);
          }
        }
      }
    };

    _translationService.onSpeechError = (error) {
      debugPrint('EnglishTeacher speech error: $error');
      // error_no_match is a normal silence timeout; reset listening state cleanly
      isListening.value = false;
    };
  }

  void selectMode(String key) {
    selectedModeKey.value = key;
    debugPrint('Scenario selected: $key');
  }

  void startSession() async {
    isSessionActive.value = true;
    messages.clear();
    currentRecognizedText.value = '';
    _sessionStartTime = DateTime.now();

    // Call backend to create session
    final sessionData = await _api.startLiveSession(modeKey: selectedModeKey.value);
    if (sessionData != null) {
      _currentSessionId = sessionData['sessionId'];
    }

    // Determine greeting based on scenario
    String greeting;
    switch (selectedModeKey.value) {
      case 'waiter':
        greeting = 'Hello! Welcome to our restaurant. Can I get you started with something to drink or eat?';
        break;
      case 'interviewer':
        greeting = 'Hello, thank you for coming to this interview today. Could you briefly introduce yourself?';
        break;
      case 'teacher':
      default:
        greeting = 'Hello! I am your AI English teacher. What would you like to talk about today?';
        break;
    }

    // Add initial greeting to chat
    messages.add(TeacherChatMessage(text: greeting, isUser: false));

    // Speak greeting aloud
    isSpeaking.value = true;
    await _translationService.speak(greeting, languageCode: 'en-US');
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    // Stop any existing TTS speech and wait a brief moment for iOS audio session to release speaker
    if (isSpeaking.value) {
      await _translationService.stopSpeaking();
      isSpeaking.value = false;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final ok = await _translationService.initSpeech();
    if (!ok) {
      Get.snackbar('Error', 'Microphone or speech recognition is not available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xCCEF4444),
          colorText: Colors.white);
      return;
    }

    isListening.value = true;
    currentRecognizedText.value = '';

    await _translationService.startListening(
      localeId: 'en_US',
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

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isThinking.value) return;

    textInputController.clear();
    messages.add(TeacherChatMessage(text: trimmed, isUser: true));
    isThinking.value = true;

    // Build history for context
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
        modeKey: selectedModeKey.value,
        sessionId: _currentSessionId,
        history: history,
      );

      isThinking.value = false;

      if (reply != null && reply.trim().isNotEmpty) {
        messages.add(TeacherChatMessage(text: reply, isUser: false));
        isSpeaking.value = true;
        await _translationService.speak(reply, languageCode: 'en-US');
      } else {
        Get.snackbar('Notice', 'Teacher could not respond. Please try again.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      isThinking.value = false;
      debugPrint('Error sending message: $e');
      Get.snackbar('Error', 'Failed to communicate with teacher.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> replayMessage(String text) async {
    isSpeaking.value = true;
    await _translationService.stopSpeaking();
    await _translationService.speak(text, languageCode: 'en-US');
  }

  void endSession() {
    _translationService.stopSpeaking();
    _translationService.stopListening();
    isSpeaking.value = false;
    isListening.value = false;
    isSessionActive.value = false;

    if (_currentSessionId != null && _sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      _api.endLiveSession(_currentSessionId!, duration, 'user_ended');
      _currentSessionId = null;
    }
  }

  @override
  void onClose() {
    endSession();
    textInputController.dispose();
    super.onClose();
  }
}

