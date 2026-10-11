import 'package:get/get.dart';
import '../../../models/language_model.dart';
import '../../../services/remote_config_service.dart';

class HomeController extends GetxController {
  late final Rx<LanguageModel> _sourceLanguage;
  late final Rx<LanguageModel> _targetLanguage;
  
  final RxList<LanguageModel> searchResults = <LanguageModel>[].obs;
  
  RemoteConfigService get _config => Get.find<RemoteConfigService>();
  
  @override
  void onInit() {
    super.onInit();
    final langs = _config.languages;
    _sourceLanguage = (langs.firstWhereOrNull((l) => l.code == 'en') ?? langs.first).obs;
    _targetLanguage = (langs.firstWhereOrNull((l) => l.code == 'hi') ?? langs.first).obs;
    
    searchResults.assignAll(langs);
    
    // Listen to changes in the languages list from backend
    ever(_config.languages, (List<LanguageModel> updatedLangs) {
      if (updatedLangs.isNotEmpty) {
        searchResults.assignAll(updatedLangs);
        // Ensure current selected languages are still enabled, otherwise fallback
        if (updatedLangs.firstWhereOrNull((l) => l.code == _sourceLanguage.value.code) == null) {
          _sourceLanguage.value = updatedLangs.firstWhereOrNull((l) => l.code == 'en') ?? updatedLangs.first;
        }
        if (updatedLangs.firstWhereOrNull((l) => l.code == _targetLanguage.value.code) == null) {
          _targetLanguage.value = updatedLangs.firstWhereOrNull((l) => l.code == 'hi') ?? updatedLangs.first;
        }
      }
    });
  }

  LanguageModel get sourceLanguage => _sourceLanguage.value;
  LanguageModel get targetLanguage => _targetLanguage.value;

  void swapLanguages() {
    final temp = _sourceLanguage.value;
    _sourceLanguage.value = _targetLanguage.value;
    _targetLanguage.value = temp;
  }
  
  void searchLanguage(String query) {
    final langs = _config.languages;
    if (query.isEmpty) {
      searchResults.assignAll(langs);
    } else {
      final lowercaseQuery = query.toLowerCase();
      final results = langs.where((lang) {
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
    searchResults.assignAll(_config.languages);
  }
}
