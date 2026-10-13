import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:math' as math;
import '../controllers/conversation_controller.dart';
import '../../home/views/language_picker_sheet.dart';

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
                // 1. Language Pill with change dropdowns & swap button
                _buildLanguagePill(),

                const SizedBox(height: 12),

                // 2. Speaker Turn Indicator & Switcher Tab
                _buildTurnIndicator(),

                const SizedBox(height: 12),

                // 3. Chat Area - Messages list with speaker tags
                Expanded(
                  child: Obx(() {
                    if (controller.messages.isEmpty) {
                      final isP1 = controller.isPerson1Turn.value;
                      final src = controller.sourceLanguage.value;
                      final tgt = controller.targetLanguage.value;

                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: Colors.white.withAlpha(50), size: 55),
                              const SizedBox(height: 16),
                              Text(
                                'Tap a mic button below to talk',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(140),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isP1
                                    ? 'Your turn to speak in ${src.name}'
                                    : 'Partner\'s turn to speak in ${tgt.name}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isP1 ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: controller.scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildChatBubble(
                            message: msg,
                          ),
                        );
                      },
                    );
                  }),
                ),

                // Current live listening preview
                Obx(() {
                  if (controller.isListening.value &&
                      controller.currentRecognizedText.value.isNotEmpty) {
                    final isP1 = controller.isPerson1Turn.value;
                    final speaker = isP1 ? 'You' : 'Partner';

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isP1 ? const Color(0xFF60A5FA).withAlpha(80) : const Color(0xFF34D399).withAlpha(80),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$speaker: "${controller.currentRecognizedText.value}"',
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 13,
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
                  height: controller.isListening.value ? 70 : 40,
                  width: double.infinity,
                  child: const AnimatedSineWaves(),
                )),

                const SizedBox(height: 8),

                // 4. Dual Bottom Mic Buttons (You vs Partner)
                _buildBottomControls(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top Language Selector Pill: [You • Hindi v] [⇄] [Partner • English v]
  Widget _buildLanguagePill() {
    return Obx(() {
      final src = controller.sourceLanguage.value;
      final tgt = controller.targetLanguage.value;
      final isPerson1 = controller.isPerson1Turn.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withAlpha(30), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left language: You (Source)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.bottomSheet(
                  LanguagePickerSheet(
                    isSource: true,
                    onLanguageSelected: controller.setSourceLanguage,
                  ),
                  isScrollControlled: true,
                  ignoreSafeArea: false,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPerson1 ? const Color(0xFF3B82F6).withAlpha(45) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isPerson1 ? Border.all(color: const Color(0xFF60A5FA), width: 1) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFlag(src.countryCode),
                    const SizedBox(width: 8),
                    Text(
                      src.name,
                      style: TextStyle(
                        color: isPerson1 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),

            // Middle Swap Button (⇄)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: controller.swapLanguages,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),

            // Right language: Partner (Target)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.bottomSheet(
                  LanguagePickerSheet(
                    isSource: false,
                    onLanguageSelected: controller.setTargetLanguage,
                  ),
                  isScrollControlled: true,
                  ignoreSafeArea: false,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: !isPerson1 ? const Color(0xFF10B981).withAlpha(45) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: !isPerson1 ? Border.all(color: const Color(0xFF34D399), width: 1) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFlag(tgt.countryCode),
                    const SizedBox(width: 8),
                    Text(
                      tgt.name,
                      style: TextStyle(
                        color: !isPerson1 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Segmented Turn Switcher Tab: [You (Hindi)] vs [Partner (English)]
  Widget _buildTurnIndicator() {
    return Obx(() {
      final isPerson1 = controller.isPerson1Turn.value;
      final srcLang = controller.sourceLanguage.value;
      final tgtLang = controller.targetLanguage.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          children: [
            // Tab 1: You
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setPersonTurn(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: isPerson1
                        ? const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isPerson1
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withAlpha(100),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 15,
                        color: isPerson1 ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'You (${srcLang.name})',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isPerson1 ? Colors.white : Colors.white60,
                            fontWeight: isPerson1 ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (isPerson1 && controller.isListening.value) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Tab 2: Partner
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setPersonTurn(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: !isPerson1
                        ? const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF0D9488)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: !isPerson1
                        ? [
                            BoxShadow(
                              color: const Color(0xFF059669).withAlpha(100),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group,
                        size: 15,
                        color: !isPerson1 ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Partner (${tgtLang.name})',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: !isPerson1 ? Colors.white : Colors.white60,
                            fontWeight: !isPerson1 ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (!isPerson1 && controller.isListening.value) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Chat message bubble with clear badges: Who spoke & what was translated
  Widget _buildChatBubble({required ChatMessage message}) {
    final isPerson1 = message.isPerson1;
    final gradientColors = isPerson1
        ? [const Color(0xFF1E3A8A).withAlpha(220), const Color(0xFF1E40AF).withAlpha(160)]
        : [const Color(0xFF065F46).withAlpha(220), const Color(0xFF047857).withAlpha(160)];
    final borderColor = isPerson1
        ? const Color(0xFF60A5FA).withAlpha(60)
        : const Color(0xFF34D399).withAlpha(60);

    final avatar = Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPerson1
                      ? [const Color(0xFF2563EB), const Color(0xFF4F46E5)]
                      : [const Color(0xFF059669), const Color(0xFF0D9488)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isPerson1 ? Icons.person : Icons.group,
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: _buildFlag(message.speakerCountryCode),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isPerson1 ? 'You' : 'Partner',
          style: TextStyle(
            color: Colors.white.withAlpha(170),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 270),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22).copyWith(
          topLeft: isPerson1 ? const Radius.circular(4) : const Radius.circular(22),
          topRight: !isPerson1 ? const Radius.circular(4) : const Radius.circular(22),
        ),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker tag & original language
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPerson1
                    ? 'You (${message.speakerLanguageName})'
                    : 'Partner (${message.speakerLanguageName})',
                style: TextStyle(
                  color: isPerson1 ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Original text
          Text(
            message.originalText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Translation divider & recipient tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Translated to ${message.targetLanguageName}',
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Translated text with speaker icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  message.translatedText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => controller.speakMessage(message),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up, color: Colors.white, size: 16),
                ),
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
          const SizedBox(width: 10),
          Flexible(child: bubble),
        ] else ...[
          Flexible(child: bubble),
          const SizedBox(width: 10),
          avatar,
        ],
      ],
    );
  }

  /// Bottom Dual Mic Buttons (You vs Partner) + Center Mic
  Widget _buildBottomControls() {
    return Obx(() {
      final listening = controller.isListening.value;
      final isPerson1 = controller.isPerson1Turn.value;
      final srcLang = controller.sourceLanguage.value;
      final tgtLang = controller.targetLanguage.value;

      final isYouListening = listening && isPerson1;
      final isPartnerListening = listening && !isPerson1;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            // Left Button: Speak as You
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleListeningForPerson(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isYouListening
                          ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                          : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (isYouListening ? Colors.red : const Color(0xFF2563EB)).withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isYouListening ? Icons.stop_rounded : Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isYouListening ? 'Stop' : 'You (${srcLang.name})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Right Button: Speak as Partner
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleListeningForPerson(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPartnerListening
                          ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                          : [const Color(0xFF059669), const Color(0xFF047857)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (isPartnerListening ? Colors.red : const Color(0xFF059669)).withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPartnerListening ? Icons.stop_rounded : Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isPartnerListening ? 'Stop' : 'Partner (${tgtLang.name})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFlag(String countryCode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 22,
        height: 16,
        child: CountryFlag.fromCountryCode(countryCode),
      ),
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
      frequency: 2.0, amplitude: 22.0,
      phaseOffset: animationValue * 2 * math.pi,
      strokeWidth: 2.5,
    );
    _drawWave(
      canvas: canvas, size: size,
      color: const Color(0xFF8B5CF6),
      frequency: 2.5, amplitude: 18.0,
      phaseOffset: (animationValue * 2 * math.pi) + 1.0,
      strokeWidth: 2.0,
    );
    _drawWave(
      canvas: canvas, size: size,
      color: const Color(0xFF10B981),
      frequency: 1.5, amplitude: 14.0,
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
