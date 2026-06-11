import 'package:flutter/material.dart';
import 'package:latest_jk/choosegame.dart';
import 'package:latest_jk/splashscreen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latest_jk/yantra%20history%20controller.dart';
import 'ChooseGameController.dart';
import 'authentication.dart';

void main() async {
  await GetStorage.init();  // Initialize GetStorage
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the AuthController
    Get.put(AuthController());
    Get.put(YantraHistoryController()); // Initialize the history controller
   // Get.put(ResultController()); // Initialize the result controller
    Get.put(ChooseGameController());

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 2)), // Optional splash delay
        builder: (context, snapshot) {
          // Check login status and redirect accordingly
          final authController = Get.find<AuthController>();
          return authController.isLoggedIn ? ChooseGame(username: '',) : SplashScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}