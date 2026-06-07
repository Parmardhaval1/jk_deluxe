import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:latest_jk/choosegame.dart';

class LoginController extends GetxController {
  final username = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final box = GetStorage();

  Future<void> login() async {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both username and password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('https://demojkd.balajitechbiz.com/Application/user_login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username.value,
          'password': password.value,
        }),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200) {
        if (result['success'] == true) {
          box.write('username', username.value);

          Get.offAll(() => ChooseGame(username: username.value)); // Passing username as parameter
          Get.snackbar(
            'Success',
            result['message'] ?? 'Login successful',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(milliseconds: 500), // ✅ 0.5 second ke liye
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            result['message'] ?? 'Login failed',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(milliseconds: 500), // ✅ 0.5 second ke liye
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception('No user found with this username and password');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        '${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/jk.png',
                width: 250,
                height: 320,
              ),
              const Text(
                'Login Screen',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0,left: 12,right: 12),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: Colors.amber),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                      ),
                      onChanged: (value) => controller.username.value = value,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0, left: 12, bottom: 12),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.amber),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                        hintStyle: TextStyle(color: Colors.amber.withOpacity(0.6)),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                      ),
                      obscureText: true,
                      cursorColor: Colors.white,
                      onChanged: (value) => controller.password.value = value,
                    ),
                  ),
                  Obx(() => SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () => controller.login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.amber,
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.amber)
                          : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}