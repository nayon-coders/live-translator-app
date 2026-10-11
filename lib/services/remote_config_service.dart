import 'package:get/get.dart';
import 'api_client.dart';
import '../models/language_model.dart';

class RemoteConfigService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();
  
  final RxList<LanguageModel> languages = <LanguageModel>[].obs;
  final RxMap<String, dynamic> settings = <String, dynamic>{}.obs;
  final RxList<dynamic> features = <dynamic>[].obs;
  final RxList<dynamic> practiceModes = <dynamic>[].obs;
  
  Future<RemoteConfigService> init() async {
    await _api.init();
    
    // Load initial from static fallback
    languages.assignAll(appLanguages);
    
    // Fetch from backend in background
    refreshConfig();
    return this;
  }
  
  Future<void> refreshConfig() async {
    final config = await _api.getConfig();
    if (config != null) {
      if (config['languages'] != null) {
        final List<dynamic> langsData = config['languages'];
        final parsed = langsData.map((e) => LanguageModel.fromMap({
          'name': e['name'],
          'nativeName': e['native_name'],
          'code': e['code'],
          'iso3': e['iso3'],
          'flag': e['flag']
        })).toList();
        
        if (parsed.isNotEmpty) {
          languages.assignAll(parsed);
        }
      }
      
      if (config['settings'] != null) {
        settings.assignAll(Map<String, dynamic>.from(config['settings']));
      }
      if (config['features'] != null) {
        features.assignAll(config['features']);
      }
      if (config['modes'] != null) {
        practiceModes.assignAll(config['modes']);
      }
    }
  }
  
  bool isFeatureEnabled(String key) {
    if (features.isEmpty) return true; // Default to true if not loaded
    final feature = features.firstWhere((f) => f['key'] == key, orElse: () => null);
    // MySQL returns 1 for true, 0 for false in tinyint
    return feature != null ? (feature['is_enabled'] == 1 || feature['is_enabled'] == true) : false;
  }
}
