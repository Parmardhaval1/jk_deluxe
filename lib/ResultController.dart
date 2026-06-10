import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'dart:convert';
import 'dart:async';

class ResultController extends GetxController {
  static const refreshInterval = Duration(seconds: 5);
  final resultData = <String, dynamic>{}.obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final errorMessage = ''.obs;
  final box = GetStorage();
  final username = ''.obs;
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    print('ResultController initialized');
    _initializeData();
  }

  @override
  void onClose() {
    print('ResultController closing - cancelling timer');
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _initializeData() {
    print('Initializing data...');
    _loadUsername();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      final now = DateTime.now();
      print('\n---result Auto-refresh triggered at $now ---');
      if (username.value.isNotEmpty) {
        isRefreshing.value = true;
        _fetchResultData(isAutoRefresh: true);
      } else {
        print('for result Username is empty - skipping refresh');
        _loadUsername();
      }
    });
  }

  Future<void> _loadUsername() async {
    try {
      print('Loading username from GetStorage...');
      isLoading(true);
      await Future.delayed(Duration(milliseconds: 100));

      final storedUsername = box.read('username')?.toString().trim();
      if (storedUsername != null && storedUsername.isNotEmpty) {
        print('Found username: $storedUsername');
        if (username.value != storedUsername) {
          username.value = storedUsername;
          _fetchResultData();
        }
      } else {
        print('No username found in GetStorage');
        errorMessage('Please login to view results');
        isLoading(false);
      }
    } catch (e) {
      print('Error loading username: $e');
      errorMessage('Error loading user data');
      isLoading(false);
    }
  }

  Future<void> _fetchResultData({bool isAutoRefresh = false}) async {
    try {
      if (username.value.isEmpty) {
        print('Username is empty - cannot fetch results');
        throw Exception('Username not found');
      }

      if (!isAutoRefresh) {
        print('Starting manual refresh...');
        isLoading(true);
      }
      errorMessage('');

      final encodedUsername = Uri.encodeComponent(username.value);
      final url = Uri.parse(Api.getUrl('Application/result.php?username=$encodedUsername'));

      print('Fetching results for: ${username.value}');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');

        if (data['success'] == true) {
          resultData.value = data;
          print('Successfully updated result data');
        } else {
          print('API returned error: ${data['message']}');
          throw Exception(data['message'] ?? 'Failed to load results');
        }
      } else {
        print('Server error: ${response.statusCode}');
        throw Exception('Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching results: $e');
      errorMessage('Error fetching results: ${e.toString()}');
      resultData.clear();
    } finally {
      if (!isAutoRefresh) {
        isLoading(false);
        print('Manual refresh completed');
      }
      isRefreshing.value = false;
    }
  }

  void manualRefresh() {
    print('\n--- Manual refresh triggered ---');
    _fetchResultData();
  }

  void updateUsername(String newUsername) {
    final trimmedUsername = newUsername.trim();
    if (trimmedUsername != username.value) {
      print('ResultController updating username to: $trimmedUsername');
      username.value = trimmedUsername;
      box.write('username', trimmedUsername);
      box.save();
      resultData.clear();
      errorMessage('');
      _fetchResultData();
    }
  }

  void clearUserData() {
    print('Clearing user data...');
    username.value = '';
    resultData.clear();
    errorMessage('');
    box.remove('username');
  }
}