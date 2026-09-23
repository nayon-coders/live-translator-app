import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/live_translation/views/live_translation_view.dart';
import '../modules/live_translation/bindings/live_translation_binding.dart';
import '../modules/conversation/views/conversation_view.dart';
import '../modules/conversation/bindings/conversation_binding.dart';
import '../modules/text_translation/views/text_translation_view.dart';
import '../modules/text_translation/bindings/text_translation_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.liveTranslation,
      page: () => const LiveTranslationView(),
      binding: LiveTranslationBinding(),
    ),
    GetPage(
      name: AppRoutes.conversation,
      page: () => const ConversationView(),
      binding: ConversationBinding(),
    ),
    GetPage(
      name: AppRoutes.textTranslation,
      page: () => const TextTranslationView(),
      binding: TextTranslationBinding(),
    ),
  ];
}
