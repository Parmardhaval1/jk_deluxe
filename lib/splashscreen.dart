import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:latest_jk/loginscreen.dart';

class SplashScreen extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('assets/jk.png', width: 300, height: 300),
      ),
    );
  }
}

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateToLogin();
  }

  void navigateToLogin() {
    Future.delayed(Duration(seconds: 3), () {
      Get.off(() => LoginScreen());
    });
  }
}