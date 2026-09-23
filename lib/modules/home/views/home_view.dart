import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:ui';
import '../controllers/home_controller.dart';
import 'language_picker_sheet.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {},
          ),
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

          // Dark Gradient Overlay for Glassmorphism
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(
                      0xFF0F172A,
                    ).withAlpha(180), // Semi-transparent Navy
                    const Color(
                      0xFF0B1120,
                    ).withAlpha(240), // Darker Navy at bottom
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Language Selection Area
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Translate From',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLanguageSelector(
                            isSource: true,
                            marginRight: 60, // Space for the swap button
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Translate To',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLanguageSelector(
                            isSource: false,
                            marginRight: 60,
                          ),
                        ],
                      ),

                      // Swap Button
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(50),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.swap_vert,
                                  color: Colors.white,
                                ),
                                onPressed: controller.swapLanguages,
                                iconSize: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Glowing orb effect
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3B82F6).withAlpha(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9333EA).withAlpha(60),
                                  blurRadius: 60,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF9333EA),
                                    ], // Blue to Purple
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF9333EA,
                                      ).withAlpha(150),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      Get.toNamed('/live-translation');
                                    },
                                    child: const Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Tap to Speak',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => Text(
                              'Translate ${controller.sourceLanguage.name} to ${controller.targetLanguage.name}...',
                              style: TextStyle(
                                color: Colors.white.withAlpha(170),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha(30),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBottomAction(
                              Icons.camera_alt,
                              'Camera',
                              '(Scan Text)',
                              () {},
                            ),
                            _buildBottomAction(
                              Icons.chat_bubble_outline,
                              'Conversation',
                              '(2-way)',
                              () {
                                Get.toNamed('/conversation');
                              },
                            ),
                            _buildBottomAction(
                              Icons.mic_none,
                              'Voice',
                              '(Hands-free)',
                              () {
                                Get.toNamed('/live-translation');
                              },
                            ),
                            _buildBottomAction(
                              Icons.text_snippet_outlined,
                              'Text',
                              '(Keyboard)',
                              () {
                                Get.toNamed('/text-translation');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector({
    required bool isSource,
    required double marginRight,
  }) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          LanguagePickerSheet(isSource: isSource),
          isScrollControlled: true,
          ignoreSafeArea: false,
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: marginRight),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(50), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Obx(() {
                    final lang = isSource
                        ? controller.sourceLanguage
                        : controller.targetLanguage;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 32,
                        height: 24,
                        child: CountryFlag.fromCountryCode(lang.countryCode),
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => Text(
                        isSource
                            ? controller.sourceLanguage.name
                            : controller.targetLanguage.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withAlpha(170),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 9),
          ),
        ],
      ),
    );
  }
}
