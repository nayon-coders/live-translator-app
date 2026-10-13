import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/english_teacher_controller.dart';

class EnglishTeacherView extends GetView<EnglishTeacherController> {
  const EnglishTeacherView({super.key});

  IconData _getIconForMode(String? key) {
    switch (key) {
      case 'teacher':
        return Icons.school_outlined;
      case 'waiter':
        return Icons.restaurant_outlined;
      case 'interviewer':
      default:
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'AI English Teacher',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withAlpha(180),
                    const Color(0xFF0B1120).withAlpha(240),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isSessionActive.value) {
                return _buildLiveSession();
              } else {
                return _buildSetupScreen();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Practice English naturally',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a scenario and start speaking.',
            style: TextStyle(
              color: Colors.white.withAlpha(170),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          
          const Text(
            'Select Scenario',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Obx(() {
              if (controller.modes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              return ListView.builder(
                itemCount: controller.modes.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final mode = controller.modes[index];
                  final modeKey = mode['key'] as String;

                  return Obx(() {
                    final isSelected = controller.selectedModeKey.value == modeKey;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => controller.selectMode(modeKey),
                          borderRadius: BorderRadius.circular(16),
                          splashColor: const Color(0xFF3B82F6).withAlpha(60),
                          highlightColor: const Color(0xFF3B82F6).withAlpha(30),
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3B82F6).withAlpha(45)
                                  : Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : Colors.white.withAlpha(30),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF3B82F6).withAlpha(60)
                                        : Colors.white.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconForMode(modeKey),
                                    color: isSelected ? const Color(0xFF60A5FA) : Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mode['title'] ?? 'Scenario',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mode['description'] ?? '',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(160),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? const Color(0xFF3B82F6)
                                      : Colors.white.withAlpha(70),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ElevatedButton(
              onPressed: () => controller.startSession(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: const Text(
                'Start Practice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSession() {
    final mode = controller.modes.firstWhereOrNull(
      (m) => m['key'] == controller.selectedModeKey.value,
    );
    final modeTitle = mode?['title'] ?? 'English Practice';

    return Column(
      children: [
        // Top session header bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      modeTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => controller.endSession(),
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent, size: 20),
                label: const Text(
                  'End',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent.withAlpha(25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),

        // Conversation history list
        Expanded(
          child: Obx(() {
            return ListView.builder(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              reverse: false,
              itemCount: controller.messages.length +
                  (controller.isThinking.value ? 1 : 0) +
                  (controller.isListening.value && controller.currentRecognizedText.value.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                // If live listening text preview
                if (controller.isListening.value &&
                    controller.currentRecognizedText.value.isNotEmpty &&
                    index == controller.messages.length) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withAlpha(120),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF60A5FA)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              controller.currentRecognizedText.value,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // If thinking bubble
                if (controller.isThinking.value && index >= controller.messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF60A5FA),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Teacher is thinking...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final msg = controller.messages[index];
                final isUser = msg.isUser;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            )
                          : LinearGradient(
                              colors: [
                                const Color(0xFF1E293B).withAlpha(230),
                                const Color(0xFF334155).withAlpha(230),
                              ],
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: Border.all(
                        color: isUser
                            ? const Color(0xFF3B82F6).withAlpha(100)
                            : Colors.white.withAlpha(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Container(
                                margin: const EdgeInsets.only(top: 2, right: 6),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  size: 14,
                                  color: Color(0xFF60A5FA),
                                ),
                              ),
                            ],
                            Flexible(
                              child: _buildMessageText(msg.text, isUser),
                            ),
                          ],
                        ),
                        if (!isUser) ...[
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => controller.replayMessage(msg.text),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.volume_up,
                                  size: 16,
                                  color: Colors.white.withAlpha(180),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Listen again',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // Live status indicator bar
        Obx(() {
          String statusText = 'Tap microphone to speak';
          Color statusColor = Colors.white54;
          IconData statusIcon = Icons.mic_none;

          if (controller.isListening.value) {
            statusText = 'Listening... Speak in English';
            statusColor = const Color(0xFF34D399);
            statusIcon = Icons.graphic_eq;
          } else if (controller.isSpeaking.value) {
            statusText = 'Teacher is speaking...';
            statusColor = const Color(0xFF60A5FA);
            statusIcon = Icons.volume_up;
          } else if (controller.isThinking.value) {
            statusText = 'Teacher is preparing answer...';
            statusColor = const Color(0xFFFBBF24);
            statusIcon = Icons.hourglass_top;
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),

        // Interactive controls: Text input + Big Mic
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withAlpha(160),
            border: Border(top: BorderSide(color: Colors.white.withAlpha(15))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text input row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withAlpha(25)),
                      ),
                      child: TextField(
                        controller: controller.textInputController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Type in English or tap mic...',
                          hintStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (value) => controller.sendMessage(value),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            controller.scrollToBottom();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (controller.textInputController.text.trim().isNotEmpty) {
                        controller.sendMessage(controller.textInputController.text);
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF3B82F6)),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(15),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Big Center Mic button
              Obx(() {
                final isListening = controller.isListening.value;
                return GestureDetector(
                  onTap: () => controller.toggleListening(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isListening
                          ? const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (isListening ? const Color(0xFFEF4444) : const Color(0xFF3B82F6))
                              .withAlpha(120),
                          blurRadius: isListening ? 25 : 12,
                          spreadRadius: isListening ? 4 : 1,
                        )
                      ],
                    ),
                    child: Icon(
                      isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Formats message text, highlighting words/phrases taught by the teacher (marked with **...**)
  /// with bold weight and a distinct background badge color.
  Widget _buildMessageText(String text, bool isUser) {
    final RegExp boldRegex = RegExp(r'\*\*(.+?)\*\*');
    final matches = boldRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
        ),
      );
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ));
      }

      final highlighted = match.group(1) ?? '';
      if (highlighted.isNotEmpty) {
        if (highlighted.length <= 32) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(60), // Amber highlight background
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withAlpha(180),
                  width: 1,
                ),
              ),
              child: Text(
                highlighted,
                style: const TextStyle(
                  color: Color(0xFFFDE047), // Vibrant gold bold text
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ));
        } else {
          spans.add(TextSpan(
            text: highlighted,
            style: TextStyle(
              color: const Color(0xFFFDE047),
              fontWeight: FontWeight.bold,
              fontSize: 15,
              height: 1.4,
              backgroundColor: const Color(0xFFD97706).withAlpha(140),
            ),
          ));
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
        ),
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}

