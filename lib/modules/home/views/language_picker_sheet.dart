import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';
import '../controllers/home_controller.dart';

class LanguagePickerSheet extends GetView<HomeController> {
  final bool isSource;
  
  const LanguagePickerSheet({super.key, required this.isSource});

  @override
  Widget build(BuildContext context) {
    // Reset search when sheet opens
    controller.resetSearch();
    
    return Container(
      height: Get.height * 0.85, // Fill 85% of screen
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Drag handle and Close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Title
          Text(
            isSource ? 'Translate From' : 'Translate To',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: controller.searchLanguage,
              decoration: InputDecoration(
                hintText: 'Search languages...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Language List
          Expanded(
            child: Obx(() {
              if (controller.searchResults.isEmpty) {
                return const Center(
                  child: Text('No languages found'),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final lang = controller.searchResults[index];
                  // Determine if this language is currently selected
                  final isSelected = isSource 
                      ? controller.sourceLanguage.code == lang.code
                      : controller.targetLanguage.code == lang.code;
                      
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 32,
                        height: 24,
                        child: CountryFlag.fromCountryCode(
                          lang.countryCode,
                        ),
                      ),
                    ),
                    title: Text(
                      lang.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Text(
                      lang.nativeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF3B82F6))
                        : null,
                    onTap: () {
                      controller.selectLanguage(lang, isSource);
                      Get.back(); // Close bottom sheet
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
