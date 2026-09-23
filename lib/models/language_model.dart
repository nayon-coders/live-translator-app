class LanguageModel {
  final String name;
  final String nativeName;
  final String code;
  final String iso3;
  final String flag;

  const LanguageModel({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.iso3,
    required this.flag,
  });

  factory LanguageModel.fromMap(Map<String, dynamic> map) {
    return LanguageModel(
      name: map['name'],
      nativeName: map['nativeName'],
      code: map['code'],
      iso3: map['iso3'],
      flag: map['flag'],
    );
  }

  String get countryCode {
    if (flag.runes.length >= 2) {
      final codeUnits = flag.runes.toList();
      final first = codeUnits[0];
      final second = codeUnits[1];
      // Check if they are Regional Indicator Symbols (U+1F1E6 to U+1F1FF)
      if (first >= 127462 && first <= 127487 && second >= 127462 && second <= 127487) {
        return String.fromCharCode(first - 127462 + 65) + String.fromCharCode(second - 127462 + 65);
      }
    }
    // Edge cases
    if (code == 'cy') return 'GB';
    return 'US'; // Fallback
  }
}

final List<LanguageModel> appLanguages = [
  // =========================
  // 🌍 GLOBAL / MOST COMMON
  // =========================
  const LanguageModel(name: "English", nativeName: "English", code: "en", iso3: "eng", flag: "🇺🇸"),
  const LanguageModel(name: "Spanish", nativeName: "Español", code: "es", iso3: "spa", flag: "🇪🇸"),
  const LanguageModel(name: "Chinese (Simplified)", nativeName: "简体中文", code: "zh-CN", iso3: "zho", flag: "🇨🇳"),
  const LanguageModel(name: "Chinese (Traditional)", nativeName: "繁體中文", code: "zh-TW", iso3: "zho", flag: "🇹🇼"),
  const LanguageModel(name: "Japanese", nativeName: "日本語", code: "ja", iso3: "jpn", flag: "🇯🇵"),
  const LanguageModel(name: "Korean", nativeName: "한국어", code: "ko", iso3: "kor", flag: "🇰🇷"),
  const LanguageModel(name: "French", nativeName: "Français", code: "fr", iso3: "fra", flag: "🇫🇷"),
  const LanguageModel(name: "German", nativeName: "Deutsch", code: "de", iso3: "deu", flag: "🇩🇪"),
  const LanguageModel(name: "Portuguese", nativeName: "Português", code: "pt", iso3: "por", flag: "🇵🇹"),
  const LanguageModel(name: "Russian", nativeName: "Русский", code: "ru", iso3: "rus", flag: "🇷🇺"),
  const LanguageModel(name: "Arabic", nativeName: "العربية", code: "ar", iso3: "ara", flag: "🇸🇦"),
  const LanguageModel(name: "Italian", nativeName: "Italiano", code: "it", iso3: "ita", flag: "🇮🇹"),
  const LanguageModel(name: "Dutch", nativeName: "Nederlands", code: "nl", iso3: "nld", flag: "🇳🇱"),
  const LanguageModel(name: "Turkish", nativeName: "Türkçe", code: "tr", iso3: "tur", flag: "🇹🇷"),
  const LanguageModel(name: "Vietnamese", nativeName: "Tiếng Việt", code: "vi", iso3: "vie", flag: "🇻🇳"),
  const LanguageModel(name: "Thai", nativeName: "ไทย", code: "th", iso3: "tha", flag: "🇹🇭"),
  const LanguageModel(name: "Indonesian", nativeName: "Bahasa Indonesia", code: "id", iso3: "ind", flag: "🇮🇩"),
  const LanguageModel(name: "Malay", nativeName: "Bahasa Melayu", code: "ms", iso3: "msa", flag: "🇲🇾"),
  const LanguageModel(name: "Filipino", nativeName: "Filipino", code: "fil", iso3: "fil", flag: "🇵🇭"),
  const LanguageModel(name: "Persian", nativeName: "فارسی", code: "fa", iso3: "fas", flag: "🇮🇷"),
  const LanguageModel(name: "Hebrew", nativeName: "עברית", code: "he", iso3: "heb", flag: "🇮🇱"),
  const LanguageModel(name: "Ukrainian", nativeName: "Українська", code: "uk", iso3: "ukr", flag: "🇺🇦"),
  const LanguageModel(name: "Polish", nativeName: "Polski", code: "pl", iso3: "pol", flag: "🇵🇱"),
  const LanguageModel(name: "Romanian", nativeName: "Română", code: "ro", iso3: "ron", flag: "🇷🇴"),
  const LanguageModel(name: "Greek", nativeName: "Ελληνικά", code: "el", iso3: "ell", flag: "🇬🇷"),
  const LanguageModel(name: "Czech", nativeName: "Čeština", code: "cs", iso3: "ces", flag: "🇨🇿"),
  const LanguageModel(name: "Hungarian", nativeName: "Magyar", code: "hu", iso3: "hun", flag: "🇭🇺"),
  const LanguageModel(name: "Swedish", nativeName: "Svenska", code: "sv", iso3: "swe", flag: "🇸🇪"),
  const LanguageModel(name: "Norwegian", nativeName: "Norsk", code: "no", iso3: "nor", flag: "🇳🇴"),
  const LanguageModel(name: "Danish", nativeName: "Dansk", code: "da", iso3: "dan", flag: "🇩🇰"),
  const LanguageModel(name: "Finnish", nativeName: "Suomi", code: "fi", iso3: "fin", flag: "🇫🇮"),
  const LanguageModel(name: "Icelandic", nativeName: "Íslenska", code: "is", iso3: "isl", flag: "🇮🇸"),
  const LanguageModel(name: "Slovak", nativeName: "Slovenčina", code: "sk", iso3: "slk", flag: "🇸🇰"),
  const LanguageModel(name: "Bulgarian", nativeName: "Български", code: "bg", iso3: "bul", flag: "🇧🇬"),
  const LanguageModel(name: "Serbian", nativeName: "Српски", code: "sr", iso3: "srp", flag: "🇷🇸"),
  const LanguageModel(name: "Croatian", nativeName: "Hrvatski", code: "hr", iso3: "hrv", flag: "🇭🇷"),
  const LanguageModel(name: "Slovenian", nativeName: "Slovenščina", code: "sl", iso3: "slv", flag: "🇸🇮"),
  const LanguageModel(name: "Bosnian", nativeName: "Bosanski", code: "bs", iso3: "bos", flag: "🇧🇦"),
  const LanguageModel(name: "Albanian", nativeName: "Shqip", code: "sq", iso3: "sqi", flag: "🇦🇱"),
  const LanguageModel(name: "Macedonian", nativeName: "Македонски", code: "mk", iso3: "mkd", flag: "🇲🇰"),

  // =========================
  // 🌏 SOUTH ASIA
  // =========================
  const LanguageModel(name: "Bengali", nativeName: "বাংলা", code: "bn", iso3: "ben", flag: "🇧🇩"),
  const LanguageModel(name: "Hindi", nativeName: "हिन्दी", code: "hi", iso3: "hin", flag: "🇮🇳"),
  const LanguageModel(name: "Urdu", nativeName: "اردو", code: "ur", iso3: "urd", flag: "🇵🇰"),
  const LanguageModel(name: "Punjabi", nativeName: "ਪੰਜਾਬੀ", code: "pa", iso3: "pan", flag: "🇮🇳"),
  const LanguageModel(name: "Gujarati", nativeName: "ગુજરાતી", code: "gu", iso3: "guj", flag: "🇮🇳"),
  const LanguageModel(name: "Marathi", nativeName: "मराठी", code: "mr", iso3: "mar", flag: "🇮🇳"),
  const LanguageModel(name: "Tamil", nativeName: "தமிழ்", code: "ta", iso3: "tam", flag: "🇮🇳"),
  const LanguageModel(name: "Telugu", nativeName: "తెలుగు", code: "te", iso3: "tel", flag: "🇮🇳"),
  const LanguageModel(name: "Kannada", nativeName: "ಕನ್ನಡ", code: "kn", iso3: "kan", flag: "🇮🇳"),
  const LanguageModel(name: "Malayalam", nativeName: "മലയാളം", code: "ml", iso3: "mal", flag: "🇮🇳"),
  const LanguageModel(name: "Odia", nativeName: "ଓଡ଼ିଆ", code: "or", iso3: "ori", flag: "🇮🇳"),
  const LanguageModel(name: "Assamese", nativeName: "অসমীয়া", code: "as", iso3: "asm", flag: "🇮🇳"),
  const LanguageModel(name: "Nepali", nativeName: "नेपाली", code: "ne", iso3: "nep", flag: "🇳🇵"),
  const LanguageModel(name: "Sinhala", nativeName: "සිංහල", code: "si", iso3: "sin", flag: "🇱🇰"),

  // =========================
  // 🇮🇳 INDIA - SCHEDULED & OTHER MAJOR
  // =========================
  const LanguageModel(name: "Bodo", nativeName: "बड़ो", code: "brx", iso3: "brx", flag: "🇮🇳"),
  const LanguageModel(name: "Dogri", nativeName: "डोगरी", code: "doi", iso3: "doi", flag: "🇮🇳"),
  const LanguageModel(name: "Kashmiri", nativeName: "कॉशुर", code: "ks", iso3: "kas", flag: "🇮🇳"),
  const LanguageModel(name: "Konkani", nativeName: "कोंकणी", code: "kok", iso3: "kok", flag: "🇮🇳"),
  const LanguageModel(name: "Maithili", nativeName: "मैथिली", code: "mai", iso3: "mai", flag: "🇮🇳"),
  const LanguageModel(name: "Manipuri", nativeName: "মৈতৈলোন্", code: "mni", iso3: "mni", flag: "🇮🇳"),
  const LanguageModel(name: "Sanskrit", nativeName: "संस्कृतम्", code: "sa", iso3: "san", flag: "🇮🇳"),
  const LanguageModel(name: "Santali", nativeName: "ᱥᱟᱱᱛᱟᱲᱤ", code: "sat", iso3: "sat", flag: "🇮🇳"),
  const LanguageModel(name: "Sindhi", nativeName: "सिन्धी", code: "sd", iso3: "snd", flag: "🇮🇳"),
  const LanguageModel(name: "Bhojpuri", nativeName: "भोजपुरी", code: "bho", iso3: "bho", flag: "🇮🇳"),
  const LanguageModel(name: "Rajasthani", nativeName: "राजस्थानी", code: "raj", iso3: "raj", flag: "🇮🇳"),
  const LanguageModel(name: "Marwari", nativeName: "मारवाड़ी", code: "mwr", iso3: "mwr", flag: "🇮🇳"),
  const LanguageModel(name: "Magahi", nativeName: "मगही", code: "mag", iso3: "mag", flag: "🇮🇳"),
  const LanguageModel(name: "Awadhi", nativeName: "अवधी", code: "awa", iso3: "awa", flag: "🇮🇳"),
  const LanguageModel(name: "Chhattisgarhi", nativeName: "छत्तीसगढ़ी", code: "hne", iso3: "hne", flag: "🇮🇳"),
  const LanguageModel(name: "Haryanvi", nativeName: "हरियाणवी", code: "bgc", iso3: "bgc", flag: "🇮🇳"),
  const LanguageModel(name: "Tulu", nativeName: "ತುಳು", code: "tcy", iso3: "tcy", flag: "🇮🇳"),
  const LanguageModel(name: "Mizo", nativeName: "Mizo", code: "lus", iso3: "lus", flag: "🇮🇳"),
  const LanguageModel(name: "Khasi", nativeName: "Khasi", code: "kha", iso3: "kha", flag: "🇮🇳"),
  const LanguageModel(name: "Garo", nativeName: "Garo", code: "grt", iso3: "grt", flag: "🇮🇳"),

  // =========================
  // 🌍 MIDDLE EAST & AFRICA & SOUTHEAST ASIA & EUROPE & AMERICAS
  // =========================
  const LanguageModel(name: "Amharic", nativeName: "አማርኛ", code: "am", iso3: "amh", flag: "🇪🇹"),
  const LanguageModel(name: "Somali", nativeName: "Soomaali", code: "so", iso3: "som", flag: "🇸🇴"),
  const LanguageModel(name: "Pashto", nativeName: "پښتو", code: "ps", iso3: "pus", flag: "🇦🇫"),
  const LanguageModel(name: "Kurdish", nativeName: "Kurdî", code: "ku", iso3: "kur", flag: "🇮🇶"),
  const LanguageModel(name: "Armenian", nativeName: "Հայերեն", code: "hy", iso3: "hye", flag: "🇦🇲"),
  const LanguageModel(name: "Georgian", nativeName: "ქართული", code: "ka", iso3: "kat", flag: "🇬🇪"),
  const LanguageModel(name: "Azerbaijani", nativeName: "Azərbaycan dili", code: "az", iso3: "aze", flag: "🇦🇿"),
  const LanguageModel(name: "Kazakh", nativeName: "Қазақша", code: "kk", iso3: "kaz", flag: "🇰🇿"),
  const LanguageModel(name: "Uzbek", nativeName: "Oʻzbekcha", code: "uz", iso3: "uzb", flag: "🇺🇿"),
  const LanguageModel(name: "Burmese", nativeName: "မြန်မာ", code: "my", iso3: "mya", flag: "🇲🇲"),
  const LanguageModel(name: "Khmer", nativeName: "ខ្មែរ", code: "km", iso3: "khm", flag: "🇰🇭"),
  const LanguageModel(name: "Lao", nativeName: "ລາວ", code: "lo", iso3: "lao", flag: "🇱🇦"),
  const LanguageModel(name: "Mongolian", nativeName: "Монгол", code: "mn", iso3: "mon", flag: "🇲🇳"),
  const LanguageModel(name: "Swahili", nativeName: "Kiswahili", code: "sw", iso3: "swa", flag: "🇰🇪"),
  const LanguageModel(name: "Zulu", nativeName: "isiZulu", code: "zu", iso3: "zul", flag: "🇿🇦"),
  const LanguageModel(name: "Xhosa", nativeName: "isiXhosa", code: "xh", iso3: "xho", flag: "🇿🇦"),
  const LanguageModel(name: "Afrikaans", nativeName: "Afrikaans", code: "af", iso3: "afr", flag: "🇿🇦"),
  const LanguageModel(name: "Yoruba", nativeName: "Yorùbá", code: "yo", iso3: "yor", flag: "🇳🇬"),
  const LanguageModel(name: "Igbo", nativeName: "Igbo", code: "ig", iso3: "ibo", flag: "🇳🇬"),
  const LanguageModel(name: "Hausa", nativeName: "Hausa", code: "ha", iso3: "hau", flag: "🇳🇬"),
  const LanguageModel(name: "Estonian", nativeName: "Eesti", code: "et", iso3: "est", flag: "🇪🇪"),
  const LanguageModel(name: "Latvian", nativeName: "Latviešu", code: "lv", iso3: "lav", flag: "🇱🇻"),
  const LanguageModel(name: "Lithuanian", nativeName: "Lietuvių", code: "lt", iso3: "lit", flag: "🇱🇹"),
  const LanguageModel(name: "Catalan", nativeName: "Català", code: "ca", iso3: "cat", flag: "🇪🇸"),
  const LanguageModel(name: "Galician", nativeName: "Galego", code: "gl", iso3: "glg", flag: "🇪🇸"),
  const LanguageModel(name: "Basque", nativeName: "Euskara", code: "eu", iso3: "eus", flag: "🇪🇸"),
  const LanguageModel(name: "Welsh", nativeName: "Cymraeg", code: "cy", iso3: "cym", flag: "🏴"),
  const LanguageModel(name: "Irish", nativeName: "Gaeilge", code: "ga", iso3: "gle", flag: "🇮🇪"),
  const LanguageModel(name: "Maltese", nativeName: "Malti", code: "mt", iso3: "mlt", flag: "🇲🇹"),
  const LanguageModel(name: "Haitian Creole", nativeName: "Kreyòl Ayisyen", code: "ht", iso3: "hat", flag: "🇭🇹"),
  const LanguageModel(name: "Quechua", nativeName: "Runa Simi", code: "qu", iso3: "que", flag: "🇵🇪"),
  const LanguageModel(name: "Guarani", nativeName: "Avañe'ẽ", code: "gn", iso3: "grn", flag: "🇵🇾"),
];
