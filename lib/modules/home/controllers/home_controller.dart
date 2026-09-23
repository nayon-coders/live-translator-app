import 'package:get/get.dart';
import '../../../models/language_model.dart';

class HomeController extends GetxController {
  final Rx<LanguageModel> _sourceLanguage = appLanguages.firstWhere((l) => l.code == 'en').obs;
  final Rx<LanguageModel> _targetLanguage = appLanguages.firstWhere((l) => l.code == 'hi').obs;
  
  final RxList<LanguageModel> searchResults = <LanguageModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    searchResults.assignAll(appLanguages);
  }

  LanguageModel get sourceLanguage => _sourceLanguage.value;
  LanguageModel get targetLanguage => _targetLanguage.value;

  void swapLanguages() {
    final temp = _sourceLanguage.value;
    _sourceLanguage.value = _targetLanguage.value;
    _targetLanguage.value = temp;
  }
  
  void searchLanguage(String query) {
    if (query.isEmpty) {
      searchResults.assignAll(appLanguages);
    } else {
      final lowercaseQuery = query.toLowerCase();
      final results = appLanguages.where((lang) {
        return lang.name.toLowerCase().contains(lowercaseQuery) || 
               lang.nativeName.toLowerCase().contains(lowercaseQuery);
      }).toList();
      searchResults.assignAll(results);
    }
  }
  
  void selectLanguage(LanguageModel language, bool isSource) {
    if (isSource) {
      _sourceLanguage.value = language;
    } else {
      _targetLanguage.value = language;
    }
  }
  
  void resetSearch() {
    searchResults.assignAll(appLanguages);
  }
}
