import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:math' as math;
import '../controllers/live_translation_controller.dart';
import '../../../models/language_model.dart';
import '../../home/views/language_picker_sheet.dart';

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
          // Dark Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF0B1120),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    
                    // 1. Language Pill with change dropdowns & swap button
                    _buildLanguagePill(),

                    const SizedBox(height: 14),

                    // 2. Visual Speaker Selector (Ami vs Onno side)
                    _buildSpeakerSelector(),

                    const SizedBox(height: 16),

                    // 3. Animated Microphone and Dynamic Sound Waves
                    _buildAnimatedMicSection(),

                    const SizedBox(height: 14),

                    // 4. Status Title & Subtitle
                    _buildStatusSection(),

                    const SizedBox(height: 20),

                    // 5. Dual Translation Cards (Input & Output)
                    _buildCardsSection(),

                    const SizedBox(height: 20),

                    // 6. Dual Mic Action Buttons (You vs Partner)
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top Language Selector Pill: [Flag Name v] [Swap] [Flag Name v]
  Widget _buildLanguagePill() {
    return Obx(() {
      final src = controller.sourceLanguage.value;
      final tgt = controller.targetLanguage.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withAlpha(30), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left language ("You" - Source)
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFlag(src.countryCode),
                    const SizedBox(width: 8),
                    Text(
                      src.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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

            // Right language ("Partner" - Target)
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFlag(tgt.countryCode),
                    const SizedBox(width: 8),
                    Text(
                      tgt.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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

  /// Segmented visual indicator of who is currently speaking
  Widget _buildSpeakerSelector() {
    return Obx(() {
      final isYou = controller.activeSpeaker.value == SpeakerSide.you;
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
            // Speaker 1: You
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setActiveSpeaker(SpeakerSide.you),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: isYou
                        ? const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isYou
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withAlpha(100),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: isYou ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'You • ${srcLang.name}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isYou ? Colors.white : Colors.white60,
                            fontWeight: isYou ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isYou && controller.isListening.value) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
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

            // Speaker 2: Partner / Other Side
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setActiveSpeaker(SpeakerSide.partner),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: !isYou
                        ? const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF0D9488)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: !isYou
                        ? [
                            BoxShadow(
                              color: const Color(0xFF059669).withAlpha(100),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group,
                        size: 16,
                        color: !isYou ? Colors.white : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Partner • ${tgtLang.name}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: !isYou ? Colors.white : Colors.white60,
                            fontWeight: !isYou ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!isYou && controller.isListening.value) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
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

  /// Animated sound waves & center mic adapting to speaker color
  Widget _buildAnimatedMicSection() {
    return Obx(() {
      final isYou = controller.activeSpeaker.value == SpeakerSide.you;
      final primaryColor = isYou ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
      final secondaryColor = isYou ? const Color(0xFF8B5CF6) : const Color(0xFF0D9488);

      return SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SoundWave(
                  isLeft: true,
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
                const SizedBox(width: 150),
                SoundWave(
                  isLeft: false,
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
              ],
            ),
            PulsingMic(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              onTap: controller.toggleListening,
            ),
          ],
        ),
      );
    });
  }

  /// Status info above translation cards
  Widget _buildStatusSection() {
    return Obx(() {
      final isYou = controller.activeSpeaker.value == SpeakerSide.you;
      final speakingLang = controller.currentSpeakingLanguage;
      final destLang = controller.currentTranslationLanguage;
      
      String statusTitle;
      if (controller.isListening.value) {
        statusTitle = isYou ? 'Listening to You...' : 'Listening to Partner...';
      } else if (controller.isTranslating.value) {
        statusTitle = 'Translating to ${destLang.name}...';
      } else if (controller.isSpeaking.value) {
        statusTitle = 'Speaking in ${destLang.name}...';
      } else if (controller.translatedText.value.isNotEmpty) {
        statusTitle = 'Tap mic to speak again';
      } else {
        statusTitle = 'Tap to speak';
      }

      final subtitle = isYou
          ? 'Speak now in ${speakingLang.name} (You)'
          : 'Speak now in ${speakingLang.name} (Partner)';

      return Column(
        children: [
          Text(
            statusTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isYou ? const Color(0xFF93C5FD) : const Color(0xFF6EE7B7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Cards for Input speech and Output translation
  Widget _buildCardsSection() {
    return Obx(() {
      final isYou = controller.activeSpeaker.value == SpeakerSide.you;
      final srcLang = controller.sourceLanguage.value;
      final tgtLang = controller.targetLanguage.value;

      final inputLang = isYou ? srcLang : tgtLang;
      final outputLang = isYou ? tgtLang : srcLang;

      final inputTitle = isYou
          ? 'You said (${srcLang.name})'
          : 'Partner said (${tgtLang.name})';

      final outputTitle = isYou
          ? 'Translation for Partner (${tgtLang.name})'
          : 'Translation for You (${srcLang.name})';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Card 1: What was said
            _buildTranslationCard(
              language: inputLang,
              title: inputTitle,
              icon: isYou ? Icons.person : Icons.group,
              text: controller.recognizedText.value.isEmpty
                  ? 'Waiting for speech in ${inputLang.name}...'
                  : controller.recognizedText.value,
              isInput: true,
              isYou: isYou,
              onSpeakerTap: controller.speakOriginal,
            ),
            
            Transform.translate(
              offset: const Offset(0, -12),
              child: _buildTranslationCard(
                language: outputLang,
                title: outputTitle,
                icon: isYou ? Icons.group : Icons.person,
                text: controller.translatedText.value.isEmpty
                    ? (controller.isTranslating.value
                        ? 'Translating to ${outputLang.name}...'
                        : 'Translation will appear here')
                    : controller.translatedText.value,
                isInput: false,
                isYou: !isYou,
                onSpeakerTap: controller.speakTranslation,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTranslationCard({
    required LanguageModel language,
    required String title,
    required IconData icon,
    required String text,
    required bool isInput,
    required bool isYou,
    VoidCallback? onSpeakerTap,
  }) {
    final gradientColors = isYou
        ? [const Color(0xFF1E3A8A).withAlpha(220), const Color(0xFF1E40AF).withAlpha(160)]
        : [const Color(0xFF065F46).withAlpha(220), const Color(0xFF047857).withAlpha(160)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isYou ? const Color(0xFF60A5FA).withAlpha(60) : const Color(0xFF34D399).withAlpha(60),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
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
              _buildFlag(language.countryCode),
              const SizedBox(width: 8),
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSpeakerTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Dual mic action buttons at the bottom
  Widget _buildBottomActions() {
    return Obx(() {
      final listening = controller.isListening.value;
      final isYou = controller.activeSpeaker.value == SpeakerSide.you;
      final srcLang = controller.sourceLanguage.value;
      final tgtLang = controller.targetLanguage.value;

      final isYouListening = listening && isYou;
      final isPartnerListening = listening && !isYou;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            // Speak as You (Source)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleListeningForSpeaker(SpeakerSide.you),
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
                        blurRadius: 12,
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
                      const SizedBox(width: 8),
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

            // Speak as Partner (Target)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleListeningForSpeaker(SpeakerSide.partner),
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
                        blurRadius: 12,
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
                      const SizedBox(width: 8),
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

// --- Dynamic Animations ---

class PulsingMic extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const PulsingMic({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripple 2
              Container(
                width: 90 + (_controller.value * 110),
                height: 90 + (_controller.value * 110),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.primaryColor.withAlpha((255 * (1 - _controller.value)).toInt() ~/ 5),
                    width: 1,
                  ),
                ),
              ),
              // Outer ripple 1
              Container(
                width: 90 + (_controller.value * 55),
                height: 90 + (_controller.value * 55),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.primaryColor.withAlpha((255 * (1 - _controller.value)).toInt() ~/ 3),
                    width: 2,
                  ),
                ),
              ),
              // Inner solid glow button
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryColor,
                      widget.secondaryColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withAlpha(150),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 46),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SoundWave extends StatefulWidget {
  final bool isLeft;
  final Color primaryColor;
  final Color secondaryColor;

  const SoundWave({
    super.key,
    required this.isLeft,
    required this.primaryColor,
    required this.secondaryColor,
  });

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
        if (mounted) {
          setState(() {
            for (int i = 0; i < barCount; i++) {
              currentHeights[i] += (targetHeights[i] - currentHeights[i]) * 0.2;
            }
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          _generateNewTargets();
          _controller.forward(from: 0.0);
        }
      });
      
    _generateNewTargets();
    _controller.forward();
  }

  void _generateNewTargets() {
    for (int i = 0; i < barCount; i++) {
      double maxH = (i == 3) ? 65.0 : (i == 2 || i == 4) ? 45.0 : 25.0;
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
        int actualIndex = widget.isLeft ? (barCount - 1 - index) : index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 5.5,
          height: currentHeights[actualIndex],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: LinearGradient(
              colors: [widget.primaryColor, widget.secondaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );
      }),
    );
  }
}
