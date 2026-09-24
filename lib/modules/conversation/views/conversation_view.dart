import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:math' as math;
import '../controllers/conversation_controller.dart';
import '../../../models/language_model.dart';

class ConversationView extends GetView<ConversationController> {
  const ConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Conversation Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B1120),
                    Color(0xFF0F172A),
                    Color(0xFF0B1120),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Language Pill with person indicator
                _buildLanguagePill(),

                const SizedBox(height: 20),

                // Chat Area - REAL DATA
                Expanded(
                  child: Obx(() {
                    if (controller.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                color: Colors.white.withAlpha(50), size: 60),
                            const SizedBox(height: 16),
                            Text(
                              'Tap the mic to start a conversation',
                              style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Text(
                              '${controller.isPerson1Turn.value ? controller.sourceLanguage.name : controller.targetLanguage.name}\'s turn to speak',
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildChatBubble(
                            message: msg,
                          ),
                        );
                      },
                    );
                  }),
                ),

                // Current listening status
                Obx(() {
                  if (controller.isListening.value &&
                      controller.currentRecognizedText.value.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(20)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.currentRecognizedText.value,
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Animated Sine Waves Area
                Obx(() => SizedBox(
                  height: controller.isListening.value ? 100 : 60,
                  width: double.infinity,
                  child: const AnimatedSineWaves(),
                )),

                // Bottom Mic Area with person switch
                const SizedBox(height: 10),
                
                // Person indicator + Mic
                Obx(() => Column(
                  children: [
                    // Person turn indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: controller.isPerson1Turn.value
                            ? const Color(0xFF3B82F6).withAlpha(40)
                            : const Color(0xFF10B981).withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.isPerson1Turn.value ? controller.sourceLanguage.name : controller.targetLanguage.name}\'s turn',
                        style: TextStyle(
                          color: controller.isPerson1Turn.value
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGlowingMic(),
                    const SizedBox(height: 8),
                    Text(
                      controller.isListening.value 
                          ? 'Listening...' 
                          : (controller.isTranslating.value 
                              ? 'Translating...' 
                              : 'Tap to speak'),
                      style: TextStyle(
                        color: Colors.white.withAlpha(150),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePill() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Person 1 (source)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: controller.isPerson1Turn.value 
                  ? const Color(0xFF3B82F6).withAlpha(40) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildFlagAndName(controller.sourceLanguage),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
          GestureDetector(
            onTap: controller.switchPerson,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(Icons.swap_horiz, color: Colors.white70, size: 20),
            ),
          ),
          // Person 2 (target)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: !controller.isPerson1Turn.value 
                  ? const Color(0xFF10B981).withAlpha(40) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildFlagAndName(controller.targetLanguage),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
        ],
      ),
    ));
  }

  Widget _buildFlagAndName(LanguageModel lang) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CountryFlag.fromCountryCode(lang.countryCode),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          lang.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble({required ChatMessage message}) {
    final isPerson1 = message.isPerson1;
    final avatarColor = isPerson1 ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
    final gradientColors = isPerson1
        ? [const Color(0xFF3B82F6), const Color(0xFF6366F1)]
        : [const Color(0xFF10B981), const Color(0xFF059669)];

    final avatar = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: avatarColor.withAlpha(50),
        shape: BoxShape.circle,
        border: Border.all(color: avatarColor, width: 2),
      ),
      child: Icon(Icons.person, color: avatarColor, size: 24),
    );

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24).copyWith(
          topLeft: isPerson1 ? const Radius.circular(4) : const Radius.circular(24),
          topRight: !isPerson1 ? const Radius.circular(4) : const Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.originalText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  message.translatedText,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => controller.speakMessage(message),
                child: Icon(Icons.volume_up, color: Colors.white.withAlpha(200), size: 18),
              ),
            ],
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isPerson1 ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isPerson1) ...[
          avatar,
          const SizedBox(width: 12),
          Flexible(child: bubble),
        ] else ...[
          Flexible(child: bubble),
          const SizedBox(width: 12),
          avatar,
        ],
      ],
    );
  }

  Widget _buildGlowingMic() {
    return GestureDetector(
      onTap: controller.toggleListening,
      child: Obx(() {
        final listening = controller.isListening.value;
        final color = controller.isPerson1Turn.value
            ? const Color(0xFF3B82F6)
            : const Color(0xFF10B981);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: listening ? 130 : 100,
              height: listening ? 130 : 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withAlpha(50), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(listening ? 60 : 30),
                    blurRadius: listening ? 50 : 40,
                    spreadRadius: listening ? 15 : 10,
                  )
                ],
              ),
            ),
            // Inner mic
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: controller.isPerson1Turn.value
                      ? [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF10B981), const Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(100),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Icon(
                listening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// --- Sine Wave Animation ---

class AnimatedSineWaves extends StatefulWidget {
  const AnimatedSineWaves({super.key});

  @override
  State<AnimatedSineWaves> createState() => _AnimatedSineWavesState();
}

class _AnimatedSineWavesState extends State<AnimatedSineWaves> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SineWavePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class SineWavePainter extends CustomPainter {
  final double animationValue;

  SineWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas: canvas, size: size,
      color: const Color(0xFF3B82F6),
      frequency: 2.0, amplitude: 25.0,
      phaseOffset: animationValue * 2 * math.pi,
      strokeWidth: 3.0,
    );
    _drawWave(
      canvas: canvas, size: size,
      color: const Color(0xFF8B5CF6),
      frequency: 2.5, amplitude: 20.0,
      phaseOffset: (animationValue * 2 * math.pi) + 1.0,
      strokeWidth: 2.5,
    );
    _drawWave(
      canvas: canvas, size: size,
      color: const Color(0xFF10B981),
      frequency: 1.5, amplitude: 15.0,
      phaseOffset: -(animationValue * 2 * math.pi) + 2.0,
      strokeWidth: 2.0,
    );
    _drawWave(
      canvas: canvas, size: size,
      color: const Color(0xFFF59E0B),
      frequency: 3.0, amplitude: 10.0,
      phaseOffset: -(animationValue * 2 * math.pi) + 3.0,
      strokeWidth: 1.5,
    );
  }

  void _drawWave({
    required Canvas canvas, required Size size,
    required Color color, required double frequency,
    required double amplitude, required double phaseOffset,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    final path = Path();
    final centerY = size.height / 2;

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final edgeDamping = math.sin(normalizedX * math.pi);
      final y = centerY + math.sin((normalizedX * math.pi * 2 * frequency) + phaseOffset) * (amplitude * edgeDamping);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SineWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
