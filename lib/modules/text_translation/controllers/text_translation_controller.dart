import 'package:get/get.dart';

class TextTranslationController extends GetxController {
  final isExpanded = true.obs;

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }
}
