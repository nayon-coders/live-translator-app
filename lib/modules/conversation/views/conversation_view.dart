import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:math' as math;
import '../controllers/conversation_controller.dart';
import '../../../../models/language_model.dart';

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
                    Color(0xFF0B1120), // Dark Navy
                    Color(0xFF0F172A), // Lighter Navy
                    Color(0xFF0B1120), // Dark Navy
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Language Pill
                _buildLanguagePill(),

                const SizedBox(height: 30),

                // Chat Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildChatBubble(
                        isSource: true,
                        originalText: 'Hello, nice to meet you.',
                        translatedText: 'नमस्ते, आपसे मिलकर खुशी हुई।',
                        colorGradient: const [Color(0xFF3B82F6), Color(0xFF6366F1)], // Blue gradient
                        avatarColor: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 24),
                      _buildChatBubble(
                        isSource: false,
                        originalText: 'Nice to meet you too.',
                        translatedText: 'आपसे मिलकर खुशी हुई।',
                        colorGradient: const [Color(0xFF10B981), Color(0xFF059669)], // Green gradient
                        avatarColor: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),

                // Animated Sine Waves Area
                const SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: AnimatedSineWaves(),
                ),

                // Bottom Mic Area
                const SizedBox(height: 20),
                _buildGlowingMic(),
                const SizedBox(height: 12),
                Text(
                  'Tap to speak',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFlagAndName(controller.sourceLanguage),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.swap_horiz, color: Colors.white70, size: 20),
          ),
          _buildFlagAndName(controller.targetLanguage),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  Widget _buildFlagAndName(LanguageModel lang) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10), // Circular flag look in design
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
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble({
    required bool isSource,
    required String originalText,
    required String translatedText,
    required List<Color> colorGradient,
    required Color avatarColor,
  }) {
    // Design has source on left, target on right
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
          colors: colorGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24).copyWith(
          topLeft: isSource ? const Radius.circular(4) : const Radius.circular(24),
          topRight: !isSource ? const Radius.circular(4) : const Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            originalText,
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
                  translatedText,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.volume_up, color: Colors.white.withAlpha(200), size: 18),
            ],
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isSource ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isSource) ...[
          avatar,
          const SizedBox(width: 12),
          bubble,
        ] else ...[
          bubble,
          const SizedBox(width: 12),
          avatar,
        ],
      ],
    );
  }

  Widget _buildGlowingMic() {
    return GestureDetector(
      onTap: controller.toggleListening,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer subtle glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3B82F6).withAlpha(50), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withAlpha(30),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ],
            ),
          ),
          // Inner glowing mic
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withAlpha(100),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 36),
          ),
        ],
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
    // 4 waves mimicking the colorful design
    _drawWave(
      canvas: canvas,
      size: size,
      color: const Color(0xFF3B82F6), // Blue
      frequency: 2.0,
      amplitude: 25.0,
      phaseOffset: animationValue * 2 * math.pi,
      strokeWidth: 3.0,
    );

    _drawWave(
      canvas: canvas,
      size: size,
      color: const Color(0xFF8B5CF6), // Purple
      frequency: 2.5,
      amplitude: 20.0,
      phaseOffset: (animationValue * 2 * math.pi) + 1.0,
      strokeWidth: 2.5,
    );
    
    _drawWave(
      canvas: canvas,
      size: size,
      color: const Color(0xFF10B981), // Green
      frequency: 1.5,
      amplitude: 15.0,
      phaseOffset: -(animationValue * 2 * math.pi) + 2.0,
      strokeWidth: 2.0,
    );
    
    _drawWave(
      canvas: canvas,
      size: size,
      color: const Color(0xFFF59E0B), // Orange
      frequency: 3.0,
      amplitude: 10.0,
      phaseOffset: -(animationValue * 2 * math.pi) + 3.0,
      strokeWidth: 1.5,
    );
  }

  void _drawWave({
    required Canvas canvas,
    required Size size,
    required Color color,
    required double frequency,
    required double amplitude,
    required double phaseOffset,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      // Adding a subtle blur glow
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    final path = Path();
    final centerY = size.height / 2;

    for (double x = 0; x <= size.width; x++) {
      // Create a pinching effect at the edges
      final normalizedX = x / size.width;
      final edgeDamping = math.sin(normalizedX * math.pi); // 0 at edges, 1 at center
      
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
