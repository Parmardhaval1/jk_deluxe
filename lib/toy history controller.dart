import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ToyHistoryController extends GetxController {
  static const refreshInterval = Duration(seconds: 5);

  final historyData = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final errorMessage = ''.obs;
  final username = ''.obs;
  final processedWins = <String>{}.obs;
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    print('YantraHistoryController initialized');
    _initializeData();
  }

  @override
  void onClose() {
    print('YantraHistoryController closing - cancelling timer');
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _initializeData() {
    print('Initializing data...');
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      final now = DateTime.now();
      print('\n--- Auto-refresh triggered at $now ---');
      if (username.value.isNotEmpty) {
        isRefreshing.value = true;
        _fetchHistoryData(isAutoRefresh: true);
      } else {
        print('Username is empty - skipping refresh');
      }
    });
  }

  void setUsername(String username) {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      print('Warning: Received empty username');
      return;
    }

    if (trimmedUsername != this.username.value) {
      print('Setting username to: $trimmedUsername');
      this.username.value = trimmedUsername;
      processedWins.clear();
      historyData.clear();

      _refreshTimer?.cancel();
      _startAutoRefresh();

      _fetchHistoryData();
    }
  }

  Future<void> _fetchHistoryData({bool isAutoRefresh = false}) async {
    try {
      if (username.value.isEmpty) {
        print('Username is empty - cannot fetch history');
        throw Exception('Username is empty');
      }

      if (!isAutoRefresh) {
        print('Starting manual refresh...');
        isLoading(true);
      }
      errorMessage('');

      final encodedUsername = Uri.encodeComponent(username.value);
      final url = Uri.parse('https://demojkd.balajitechbiz.com/Application/toy_history.php?usernm=$encodedUsername');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final processedData = _processApiData(data['data'] ?? []);

          for (var item in processedData) {
            if (item['isWin'] == true && item['winamount'] != '0') {
              final winAmount = int.tryParse(item['winamount'] ?? '0') ?? 0;
              if (winAmount > 0) {
                final uniqueKey = item['uniqueKey'];
                if (!processedWins.contains(uniqueKey)) {
                  //  print('New win detected - processing: $uniqueKey');
                  //await _addCoinsToUser(username.value, winAmount, uniqueKey);
                }
              }
            }
          }

          historyData.assignAll(processedData);
          if (historyData.isEmpty) {
            print('No history data available for user');
            errorMessage('No history data available for ${username.value}');
          } else {
            print('Successfully updated history data');
          }
        } else {
          print('API returned error: ${data['message']}');
          errorMessage(data['message'] ?? 'No data found for ${username.value}');
          historyData.clear();
        }
      } else {
        print('Server error: ${response.statusCode}');
        throw Exception('Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage('Error fetching data: ${e.toString()}');
      historyData.clear();
    } finally {
      if (!isAutoRefresh) {
        isLoading(false);
      }
      isRefreshing.value = false;
    }
  }

  List<Map<String, dynamic>> _processApiData(List<dynamic> apiData) {
    print('Processing API data (${apiData.length} items)');
    return apiData.map((item) {
      final uniqueKey = '${item['ticketnm']}_${item['drawtime']}';
      final isProcessed = processedWins.contains(uniqueKey);

      return {
        'ticketnm': item['ticketnm']?.toString() ?? 'N/A',
        'ticketCount': item['ticketCount']?.toString() ?? '0',
        'totamount': item['totamount']?.toString() ?? '0',
        'drawtime': item['drawtime']?.toString() ?? 'N/A',
        'drawopen': item['drawopen']?.toString() ?? 'N/A',
        'result': item['result']?.toString() ?? 'PENDING',
        'winamount': item['winamount']?.toString() ?? '0',
        'isWin': (item['result']?.toString().toUpperCase() == 'WIN'),
        'coinsAdded': isProcessed,
        'uniqueKey': uniqueKey,
      };
    }).toList();
  }

  void manualRefresh() {
    print('\n--- Manual refresh triggered ---');
    _fetchHistoryData();
  }
}