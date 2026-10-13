import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import '../controllers/ai_friend_controller.dart';
import '../../home/views/language_picker_sheet.dart';

class AiFriendView extends GetView<AiFriendController> {
  const AiFriendView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(35)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withAlpha(120),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Friend',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Always here to talk',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'New Conversation',
            onPressed: () {
              controller.clearChat();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Deep Violet/Indigo Gradient Overlay for AI Companion theme
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withAlpha(200),
                    const Color(0xFF1E1B4B).withAlpha(230),
                    const Color(0xFF0F172A).withAlpha(250),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top language selector pill & prompt
                _buildLanguageBar(context),

                // Quick Conversation Starters
                _buildConversationStarters(),

                // Chat Messages List
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      controller: controller.scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.messages.length +
                          (controller.isThinking.value ? 1 : 0) +
                          (controller.isListening.value && controller.currentRecognizedText.value.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Live recognized text preview bubble
                        if (controller.isListening.value &&
                            controller.currentRecognizedText.value.isNotEmpty &&
                            index == controller.messages.length) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withAlpha(140),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFA5B4FC)),
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

                        // Thinking bubble
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
                                      color: Color(0xFFA78BFA),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'AI Friend is typing...',
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
                              maxWidth: MediaQuery.of(context).size.width * 0.80,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isUser
                                  ? const LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        const Color(0xFF1E1B4B).withAlpha(230),
                                        const Color(0xFF312E81).withAlpha(230),
                                      ],
                                    ),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(isUser ? 18 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 18),
                              ),
                              border: Border.all(
                                color: isUser
                                    ? const Color(0xFF818CF8).withAlpha(120)
                                    : const Color(0xFFC084FC).withAlpha(60),
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
                                          color: const Color(0xFF8B5CF6).withAlpha(40),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.smart_toy_rounded,
                                          size: 14,
                                          color: Color(0xFFA78BFA),
                                        ),
                                      ),
                                    ],
                                    Flexible(
                                      child: Text(
                                        msg.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          height: 1.4,
                                        ),
                                      ),
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

                // Status indicator
                Obx(() {
                  String statusText = 'Tap mic to speak or type a message';
                  Color statusColor = Colors.white54;
                  IconData statusIcon = Icons.chat_bubble_outline;

                  if (controller.isListening.value) {
                    statusText = 'Listening in ${controller.selectedLanguage.value.name}...';
                    statusColor = const Color(0xFF34D399);
                    statusIcon = Icons.graphic_eq;
                  } else if (controller.isSpeaking.value) {
                    statusText = 'AI Friend is speaking...';
                    statusColor = const Color(0xFFA78BFA);
                    statusIcon = Icons.volume_up;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),

                // Bottom Input Area (Text input + Big Glowing Mic)
                _buildBottomInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Language selector button
          Obx(() {
            final lang = controller.selectedLanguage.value;
            return GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  LanguagePickerSheet(
                    isSource: true,
                    onLanguageSelected: (selected) {
                      controller.changeLanguage(selected);
                      Get.back();
                    },
                  ),
                  isScrollControlled: true,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        width: 20,
                        height: 15,
                        child: CountryFlag.fromCountryCode(lang.countryCode),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Language: ${lang.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            );
          }),

          // Friendly Companion pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B5CF6).withAlpha(80)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFA78BFA), size: 13),
                SizedBox(width: 5),
                Text(
                  'Voice & Text',
                  style: TextStyle(
                    color: Color(0xFFA78BFA),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationStarters() {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.conversationStarters.length,
        itemBuilder: (context, index) {
          final starter = controller.conversationStarters[index];
          return GestureDetector(
            onTap: () => controller.sendMessage(starter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(25)),
              ),
              child: Center(
                child: Text(
                  starter,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(180),
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
                      hintText: 'Type a message to your friend...',
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
                icon: const Icon(Icons.send_rounded, color: Color(0xFF8B5CF6)),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(15),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Big Glowing Center Mic button
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
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (isListening ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6))
                          .withAlpha(140),
                      blurRadius: isListening ? 25 : 14,
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
    );
  }
}
