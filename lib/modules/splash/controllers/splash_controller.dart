import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request both microphone and speech recognition permissions
    await [
      Permission.microphone,
      Permission.speech,
    ].request();
  }

  void getStarted() {
    Get.offNamed(AppRoutes.home);
  }
}
