import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'api.dart';
import '10toys.dart';
import 'ui_helpers.dart';

class ToysController extends GetxController {
  var data = <Item>[
    Item(img: 'assets/13.png', title: 'UMBRELLA', date: '', time: ''),
    Item(img: 'assets/ball.png', title: 'BALL', date: '', time: ''),
    Item(img: 'assets/bucket.png', title: 'BUCKET', date: '', time: ''),
    Item(img: 'assets/butterfly.png', title: 'BUTTERFLY', date: '', time: ''),
    Item(img: 'assets/pigeon.png', title: 'DOVE', date: '', time: ''),
  ].obs;

  var data2 = <Item>[
    Item(img: 'assets/rose.png', title: 'ROSE', date: '', time: ''),
    Item(img: 'assets/sun.png', title: 'SUN', date: '', time: ''),
    Item(img: 'assets/kite.png', title: 'KITE', date: '', time: ''),
    Item(img: 'assets/diya.png', title: 'DIYA', date: '', time: ''),
    Item(img: 'assets/top.png', title: 'TOP', date: '', time: ''),
  ].obs;

  var last5Draws = <Item>[].obs;

  Future<void> fetchLast5Draws() async {
    try {
      final response = await http.get(
        Uri.parse(Api.getUrl('Application/last5_toys.php')),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] is List) {
          List<dynamic> drawList = responseData['data'];

          last5Draws.assignAll(drawList.map((draw) {
            String formattedDate = '--/--/----';
            if (draw['drawdate'] != null && draw['drawdate'].toString().contains('-')) {
              final dateParts = draw['drawdate'].toString().split('-');
              if (dateParts.length == 3) {
                formattedDate = '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
              }
            }

            String imageUrl = draw['image']?.toString() ?? '';
            if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
              imageUrl = Api.getUrl('$imageUrl');
            }

            return Item(
              img: imageUrl, // Now using the full network image URL
              title: draw['tktname']?.toString() ?? 'Unknown',
              date: formattedDate,
              time: draw['drawtime']?.toString() ?? '--:-- --',
            );
          }).toList());
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching last 5 draws: $e');
    }
  }


  var itemCountMap = <String, int>{}.obs;
  var textControllers = <String, TextEditingController>{}.obs;
  var buttonValues = [1, 2, 5, 10, 15, 20].obs;
  var totalAmount = 0.obs;
  var initialAvailable = 0.obs;
  final available = 0.obs;
  final isSubmitting = false.obs; // true while a ticket purchase is in flight
  var totalClicks = 0.obs;
  var selectedButtonIndex = (-1).obs;
  var countdownDuration = const Duration(minutes: 5);
  var currentTime = "".obs;
  var timeSession = "".obs;
  var currentDate = "".obs;
  var remainingTime = "".obs;
  var isLessThanThirtySeconds = false.obs;
  final username = RxString(''); // Observable for username
  final box = GetStorage();
  late Timer _timer;
  late Timer _refreshTimer; // Add this with your other variables
  RxString selectedItemTitle = ''.obs;  // To track which yantra is selected
  RxString selectedNumber = ''.obs;

  Future<void> submitTickets() async {
    if (isSubmitting.value) return; // prevent double-submit while in flight
    isSubmitting.value = true;
    try {
      final coinsResponse = await http.post(
        Uri.parse(Api.getUrl('Application/coins_minus.php')),
        body: json.encode({
          "username": username.value,
          "coins": totalAmount.value,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (coinsResponse.statusCode != 200) {
        throw Exception('Failed to deduct coins');
      }

      List<String> ticketEntries = [];
      for (var entry in itemCountMap.entries) {
        if (entry.value > 0) {
          ticketEntries.add('${entry.key}-${entry.value}');
        }
      }
      String ticketNames = ticketEntries.join(',');

      String barcodeNo = _generate11DigitBarcode();

      final response = await http.post(
        Uri.parse(Api.getUrl('Application/10toys.php')),
        body: json.encode({
          "usernm": username.value,
          "ticketnm": ticketNames,
          "ticketCount": totalClicks.value,
          "totamount": totalAmount.value,
          "drawtime": timeSession.value,
          "barcodeno": barcodeNo
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Removed PDF generation code
        clearAll(); // Clear selections
        await fetchAvailableCoins(); // Refresh coin balance

        showSuccessDialog('Ticket Purchased Successfully');
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit tickets: ${response.body}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String _generate11DigitBarcode() {
    final random = Random();
    String barcode = '';

    for (int i = 0; i < 10; i++) {
      barcode += random.nextInt(10).toString();
    }

    int checkDigit = random.nextInt(10);
    barcode += checkDigit.toString();

    return barcode;
  }

  // Future<void> generateAndSavePdf(String barcodeNo, String ticketNames) async {
  //   final pdf = pw.Document();
  //
  //   final barcodeSvg = Barcode.code128().toSvg(
  //     barcodeNo,
  //     width: 200,
  //     height: 80,
  //     fontHeight: 10,
  //   );
  //
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a5,
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text('JK Delux - Yantra Tickets',
  //                 style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 10),
  //             pw.Text('Username: ${username.value}'),
  //             pw.Text('Draw Time: ${timeSession.value}'),
  //             pw.Text('Date: ${currentDate.value}'),
  //             pw.Text('Total Tickets: $totalClicks'),
  //             pw.Text('Total Amount: $totalAmount'),
  //             pw.SizedBox(height: 10),
  //             pw.Text('Tickets:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             pw.Text(ticketNames.replaceAll(',', '\n')),
  //             pw.SizedBox(height: 20),
  //             pw.Text('Barcode:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             pw.SvgImage(svg: barcodeSvg),
  //             pw.Text(barcodeNo,
  //                 style: pw.TextStyle(fontSize: 16),
  //                 textAlign: pw.TextAlign.center),
  //             pw.SizedBox(height: 20),
  //             pw.Text('Thank you for playing!',
  //                 style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // Save PDF to device
  //   final output = await getTemporaryDirectory();
  //   final file = File('${output.path}/ticket_$barcodeNo.pdf');
  //   await file.writeAsBytes(await pdf.save());
  //
  //   // Print or share the PDF
  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  // }

  Future<void> fetchAvailableCoins() async {
    try {
      print('[${DateTime.now()}] [DEBUG] Starting fetchAvailableCoins()');
      print('[${DateTime.now()}] [DEBUG] Current username: ${username.value}');

      final response = await http.post(
        Uri.parse(Api.getUrl('Application/retrieve_coins.php')),
        body: json.encode({'username': username.value}),
        headers: {'Content-Type': 'application/json'},
      );

      print('[${DateTime.now()}] [DEBUG] API response status: ${response.statusCode}');
      print('[${DateTime.now()}] [DEBUG] API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[${DateTime.now()}] [DEBUG] Decoded response: $data');

        if (data['success'] == true) {
          final newCoins = int.tryParse(data['coins'].toString()) ?? 0;
          print('[${DateTime.now()}] [DEBUG] New coins value: $newCoins');
          print('[${DateTime.now()}] [DEBUG] Before update - initialAvailable: ${initialAvailable.value}, available: ${available.value}');

          final oldCoins = available.value;
          final difference = newCoins - oldCoins;

          if (difference > 0 && difference % 100 == 0) {
            final multiple = difference ~/ 100;
            _showWinDialog(multiple * 100);
          }

          initialAvailable.value = newCoins;
          available.value = newCoins;
          print('[${DateTime.now()}] [DEBUG] After update - initialAvailable: ${initialAvailable.value}, available: ${available.value}');
        } else {
          print('[${DateTime.now()}] [DEBUG] API success flag is false');
        }
      } else {
        print('[${DateTime.now()}] [DEBUG] API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('[${DateTime.now()}] [DEBUG] Error in fetchAvailableCoins(): $e');
      print('[${DateTime.now()}] [DEBUG] Stack trace: ${e.toString()}');
    }
  }

  void _showWinDialog(int coinsWon) {
    Get.dialog(
      AlertDialog(
        title: const Text('Congratulations!', style: TextStyle(color: Colors.green)),
        content: Text('You won $coinsWon coins!'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _startAutoRefreshTimer() {
    print('[${DateTime.now()}] [toy DEBUG for session] Starting auto-refresh timer');

    // Initial fetch
    fetchAvailableCoins();
    fetchLast5Draws();

    // Store the last known session to detect changes
    String lastSession = _getCurrentSession();
    print('[${DateTime.now()}]toy  Initial session: $lastSession');

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      final now = DateTime.now();
      final currentSession = _getCurrentSession();

      print('[${now}] [toy DEBUG for session] Auto-refresh timer triggered');

      // Check if session has changed
      if (currentSession != lastSession) {
        print('[${now}] [toy SESSION CHANGE] New session: $currentSession');
        lastSession = currentSession;
        _onSessionChange(); // Trigger session change logic
      }

      // Regular refresh
      fetchAvailableCoins();
      fetchLast5Draws();
    });
  }
  @override
  void onInit() {
    super.onInit();
    username.value = box.read('username') ?? '';
    fetchAvailableCoins();
    fetchLast5Draws();

    for (var item in data) {
      itemCountMap[item.title] = 0;
      textControllers[item.title] = TextEditingController();
    }
    for (var item in data2) {
      itemCountMap[item.title] = 0;
      textControllers[item.title] = TextEditingController();
    }

    _startClock();
    _startSessionTimer();
    _startAutoRefreshTimer(); // Add this line
    timeSession.value = _getCurrentSession();
    currentDate.value = _getCurrentDate();
    remainingTime.value = _getRemainingTime();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      currentTime.value = _formatCurrentTime();
      remainingTime.value = _getRemainingTime();
    });
  }

  var shouldRefreshPage = false.obs;

  void _startSessionTimer() {
    final now = DateTime.now();
    final nextSessionStart = now.add(Duration(minutes: 5 - (now.minute % 5), seconds: -now.second));
    final initialDelay = nextSessionStart.difference(now);

    _onSessionChange();

    Future.delayed(initialDelay, () {
      _timer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
        _onSessionChange();
      });
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return "$hour:$minute:$second $period";
  }

  String _getCurrentSession() {
    final now = DateTime.now();
    final int currentMinute = now.minute;
    final int roundedMinute = (currentMinute ~/ 5) * 5;
    final DateTime baseSessionTime = DateTime(now.year, now.month, now.day, now.hour, roundedMinute);
    final DateTime sessionTime = baseSessionTime.add(const Duration(minutes: 5));
    final hour = sessionTime.hour % 12 == 0 ? 12 : sessionTime.hour % 12;
    final minute = sessionTime.minute.toString().padLeft(2, '0');
    final period = sessionTime.hour < 12 ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return "$day/$month/$year";
  }

  String _getRemainingTime() {
    final now = DateTime.now();
    final secondsSinceLastInterval = (now.minute % 5) * 60 + now.second;
    final secondsToNextInterval = 5 * 60 - secondsSinceLastInterval;
    final minutes = secondsToNextInterval ~/ 60;
    final seconds = secondsToNextInterval % 60;
    isLessThanThirtySeconds.value = secondsToNextInterval <= 20;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _onSessionChange() {
    clearAll();
    timeSession.value = _getCurrentSession();
    currentDate.value = _getCurrentDate();
    remainingTime.value = _getRemainingTime();

    fetchAvailableCoins();
    fetchLast5Draws();

    Future.delayed(const Duration(seconds: 10), () {
      shouldRefreshPage.value = true;
      print('[${DateTime.now()}] Full page refresh triggered (10 seconds after session change)');
    });
  }

  @override
  void onClose() {
    _refreshTimer.cancel(); // Add this line
    _timer.cancel();
    print('[${DateTime.now()}] Closing ToysController...');
    _timer.cancel();
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  void calculateTotalAmount() {
    int totalCost = 0;
    int newTotalAmount = 0;
    int newTotalClicks = 0;

    itemCountMap.forEach((key, value) {
      newTotalAmount += value * 11;
      newTotalClicks += value;
      totalCost += value * 11;
    });

    int newAvailable = initialAvailable.value - totalCost;

    if (newAvailable < 0) {
      newAvailable = 0;
    }

    if (newAvailable >= 0) {
      available.value = newAvailable;
      totalClicks.value = newTotalClicks;
      totalAmount.value = newTotalAmount;
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text("Insufficient Amount"),
          content: const Text("There's not enough coins available for further ticket."),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void clearAll() {
    itemCountMap.forEach((key, value) {
      itemCountMap[key] = 0;
      textControllers[key]?.text = '';
    });
    calculateTotalAmount();
    selectedButtonIndex.value = -1;
  }

  void selectItem(String title, int index) {
    selectedItemTitle.value = title;

    int addValue = int.tryParse(selectedNumber.value) ?? 0;

    final currentText = textControllers[title]?.text ?? '0';
    final currentValue = int.tryParse(currentText) ?? 0;

    final newValue = currentValue + addValue;

    textControllers[title]?.text = newValue.toString();

    itemCountMap[title] = newValue;
    calculateTotalAmount();
  }
}