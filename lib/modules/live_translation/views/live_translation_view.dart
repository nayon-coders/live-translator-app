import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:math' as math;
import '../controllers/live_translation_controller.dart';
import '../../../../models/language_model.dart';

class LiveTranslationView extends GetView<LiveTranslationController> {
  const LiveTranslationView({super.key});

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
          'Live Translation',
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
          // Dark Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A), // Dark Navy
                    Color(0xFF0B1120), // Darker Navy
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Language Pill
                _buildLanguagePill(),
                
                const Spacer(flex: 2),
                
                // Animated Microphone and Sound Waves
                _buildAnimatedMicSection(),
                
                const SizedBox(height: 30),
                
                // Status Text
                Obx(() => Text(
                      controller.isListening.value ? 'Listening...' : 'Tap to restart',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 8),
                Text(
                  'Speak now in ${controller.sourceLanguage.name}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 16,
                  ),
                ),
                    
                const Spacer(flex: 2),
                
                // Translation Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildTranslationCard(
                        language: controller.sourceLanguage,
                        title: 'You said (${controller.sourceLanguage.name})',
                        text: 'How much does this cost?',
                        isSource: true,
                      ),
                      // Slight overlap trick
                      Transform.translate(
                        offset: const Offset(0, -15),
                        child: _buildTranslationCard(
                          language: controller.targetLanguage,
                          title: 'Translation (${controller.targetLanguage.name})',
                          text: 'इसकी कीमत कितनी है?', // Dummy text matching design
                          isSource: false,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Stop Button
                _buildStopButton(),
                
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFlagAndName(controller.sourceLanguage),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
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
            child: CountryFlag.fromCountryCode(
              lang.countryCode,
            ),
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

  Widget _buildAnimatedMicSection() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sound waves
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SoundWave(isLeft: true),
              const SizedBox(width: 160), // Space for the mic in middle
              const SoundWave(isLeft: false),
            ],
          ),
          // Pulsing Mic
          const PulsingMic(),
        ],
      ),
    );
  }
  
  Widget _buildTranslationCard({
    required LanguageModel language,
    required String title,
    required String text,
    required bool isSource,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSource 
              ? [const Color(0xFF1E3A8A).withAlpha(200), const Color(0xFF1E40AF).withAlpha(150)] // Blueish
              : [const Color(0xFF0F766E).withAlpha(200), const Color(0xFF0D9488).withAlpha(150)], // Tealish
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 24,
                  height: 18,
                  child: CountryFlag.fromCountryCode(language.countryCode),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopButton() {
    return InkWell(
      onTap: controller.toggleListening,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withAlpha(30), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stop_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Tap to stop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Custom Animations ---

class PulsingMic extends StatefulWidget {
  const PulsingMic({super.key});

  @override
  State<PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<PulsingMic> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ripple 2
            Container(
              width: 100 + (_controller.value * 120),
              height: 100 + (_controller.value * 120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3B82F6).withAlpha((255 * (1 - _controller.value)).toInt() ~/ 5),
                  width: 1,
                ),
              ),
            ),
            // Outer ripple 1
            Container(
              width: 100 + (_controller.value * 60),
              height: 100 + (_controller.value * 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3B82F6).withAlpha((255 * (1 - _controller.value)).toInt() ~/ 3),
                  width: 2,
                ),
              ),
            ),
            // Inner solid glow
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF3B82F6), // Blue center
                    Color(0xFF6366F1), // Indigo edge
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withAlpha(150),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 50),
            ),
          ],
        );
      },
    );
  }
}

class SoundWave extends StatefulWidget {
  final bool isLeft;
  const SoundWave({super.key, required this.isLeft});

  @override
  State<SoundWave> createState() => _SoundWaveState();
}

class _SoundWaveState extends State<SoundWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int barCount = 7;
  final math.Random random = math.Random();
  late List<double> targetHeights;
  late List<double> currentHeights;

  @override
  void initState() {
    super.initState();
    currentHeights = List.generate(barCount, (index) => 10.0);
    targetHeights = List.generate(barCount, (index) => 10.0);
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          for (int i = 0; i < barCount; i++) {
            currentHeights[i] += (targetHeights[i] - currentHeights[i]) * 0.2;
          }
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _generateNewTargets();
          _controller.forward(from: 0.0);
        }
      });
      
    _generateNewTargets();
    _controller.forward();
  }

  void _generateNewTargets() {
    // Generate heights that look like sound waves (taller near center)
    for (int i = 0; i < barCount; i++) {
      double maxH = (i == 3) ? 70.0 : (i == 2 || i == 4) ? 50.0 : 30.0;
      targetHeights[i] = 10.0 + random.nextDouble() * maxH;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(barCount, (index) {
        // Reverse order for left side so it looks symmetrical
        int actualIndex = widget.isLeft ? (barCount - 1 - index) : index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6,
          height: currentHeights[actualIndex],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)], // Blue to purple
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );
      }),
    );
  }
}
