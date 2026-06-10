import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final availableCoins = 0.obs;
  final box = GetStorage();
  final username = RxString('');
  final role = RxString('');
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    username.value = box.read('username') ?? '';
    if (username.value.isNotEmpty) {
      fetchProfileData();
    }
  }

  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(Api.getUrl('Application/profile.php?username=${username.value}')),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          availableCoins.value = int.tryParse(result['coins'].toString()) ?? 0;
          role.value = result['role'] ?? '';
          // Don't store password for security reasons
        } else {
          throw Exception(result['message'] ?? 'Failed to load profile');
        }
      } else {
        throw Exception('Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateCoins(int newAmount) {
    availableCoins.value = newAmount;
  }
}

class Profile extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
            backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'assets/jk.png',
                  width: 200,
                  height: 180,
                ),
                const Text(
                  'User Profile',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _buildProfileRow('User Name:', controller.username.value),
                const SizedBox(height: 8),

                _buildProfileRow(
                  'Available Coins:',
                  controller.availableCoins.value.toString(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ),
      ],
    );
  }
}