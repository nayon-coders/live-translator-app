import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/camera_translation_controller.dart';

class CameraTranslationView extends GetView<CameraTranslationController> {
  const CameraTranslationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Camera Translation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.retake,
            tooltip: 'Retake Photo',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.imagePath.value.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Stack(
          children: [
            // Background Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.55,
              child: Image.file(
                File(controller.imagePath.value),
                fit: BoxFit.cover,
              ),
            ),
            
            // Scanning Overlay Effect (if processing)
            if (controller.isProcessing.value)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Container(
                  color: const Color(0xFF3B82F6).withAlpha(50),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),

            // Bottom Translation Card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Status or Result
                        if (controller.isProcessing.value)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Scanning & Translating...',
                                    style: TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Detecting language automatically',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (controller.extractedText.value.trim().isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text(
                                'No text found in image.',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Target Translation
                              Row(
                                children: [
                                  const Icon(Icons.language, color: Color(0xFF10B981), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.targetLanguage.name,
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.translatedText.value,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(color: Color(0xFFF1F5F9), thickness: 2),
                              ),

                              // Detected Source Text
                              const Row(
                                children: [
                                  Icon(Icons.document_scanner_outlined, color: Color(0xFF3B82F6), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Detected Text',
                                    style: TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.extractedText.value,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
