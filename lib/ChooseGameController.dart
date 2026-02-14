import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '10rashi.dart';
import '10toys.dart';
import '10yantras.dart';

class ChooseGameController extends GetxController {
  final List<String> cardTexts = ['10 Yantras', '10 Toys', '10 Rashi'];
  final List<String> imagePaths = ['assets/11.jpg', 'assets/13.png', 'assets/rashi1.png'];
  final username = RxString(''); // Observable username
  final isRefreshing = false.obs;
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void setUsername(String newUsername) {
    username.value = newUsername;
    // Start fetching data immediately when username is set
    if (username.value.isNotEmpty) {
      _fetchResultData();
      _fetchResultData1();
      _fetchResultData2();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (username.value.isNotEmpty) {
        _fetchResultData();
        _fetchResultData1();
        _fetchResultData2();
      }
    });
  }

  Future<void> _fetchResultData() async {
    try {
      isRefreshing.value = true;
      final encodedUsername = Uri.encodeComponent(username.value);
      final url = Uri.parse('https://demojkd.balajitechbiz.com/Application/result.php?username=$encodedUsername');

      print('Yantra Fetching results for: ${username.value}');
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching results: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _fetchResultData1() async {
    try {
      isRefreshing.value = true;
      final encodedUsername = Uri.encodeComponent(username.value);
      final url = Uri.parse('https://demojkd.balajitechbiz.com/Application/result1.php?username=$encodedUsername');

      print('Toys Fetching results for: ${username.value}');
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching results: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _fetchResultData2() async {
    try {
      isRefreshing.value = true;
      final encodedUsername = Uri.encodeComponent(username.value);
      final url = Uri.parse('https://demojkd.balajitechbiz.com/Application/result2.php?username=$encodedUsername');

      print('Rashi Fetching results for: ${username.value}');
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching results: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  void refreshData() {
    if (username.value.isNotEmpty) {
      _fetchResultData();
      _fetchResultData1();
      _fetchResultData2();
    }
  }

  void navigateToGame(int index) {
    switch (index) {
      case 0:
        Get.to(() => Yantras());
        break;
      case 1:
        Get.to(() => Toys());
        break;
      case 2:
        Get.to(() => Rashi());
        break;
    }
  }
}