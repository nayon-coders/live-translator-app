import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../services/translation_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../../models/language_model.dart';
import 'dart:io';

class CameraTranslationController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  final imagePath = ''.obs;
  final isProcessing = false.obs;
  
  final extractedText = ''.obs;
  final translatedText = ''.obs;
  
  late final LanguageModel targetLanguage;
  final TranslationService _translationService = Get.find<TranslationService>();

  @override
  void onInit() {
    super.onInit();
    final homeController = Get.find<HomeController>();
    // Auto-detect source, we only need the target language
    targetLanguage = homeController.targetLanguage;
    
    // Automatically open camera when page loads, but give the page a moment to render
    Future.delayed(const Duration(milliseconds: 300), _openCamera);
  }

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        imagePath.value = image.path;
        _processImage(image.path);
      } else {
        // User canceled, go back
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open camera.');
      Get.back();
    }
  }

  Future<void> _processImage(String path) async {
    isProcessing.value = true;
    extractedText.value = '';
    translatedText.value = '';
    
    try {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      extractedText.value = recognizedText.text;
      
      if (extractedText.value.trim().isNotEmpty) {
         // Auto-translate using 'auto' for source
         final result = await _translationService.translate(
           text: extractedText.value,
           sourceCode: 'auto',
           targetCode: targetLanguage.code,
         );
         translatedText.value = result;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process image text.');
    } finally {
      isProcessing.value = false;
    }
  }
  
  void retake() {
    imagePath.value = '';
    extractedText.value = '';
    translatedText.value = '';
    _openCamera();
  }
}
