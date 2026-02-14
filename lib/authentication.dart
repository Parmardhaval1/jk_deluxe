// controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final box = GetStorage();

  bool get isLoggedIn => box.read('isLoggedIn') ?? false;

  void login() {
    box.write('isLoggedIn', true);
    update();
  }

  void logout() {
    box.remove('isLoggedIn');
    update();
  }
}