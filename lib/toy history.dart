import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latest_jk/toy%20history%20controller.dart';
import 'ui_helpers.dart';

class ToyHistory extends StatelessWidget {
  final String username;
  final ToyHistoryController controller;

  ToyHistory({required this.username})
      : controller = Get.put(ToyHistoryController()) {
    controller.setUsername(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E2B76),
        title: Row(
          children: [
            const Text('Toy History', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 10),
            Text(
              username.isNotEmpty ? username : 'Guest',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          refreshAction(controller.isRefreshing, controller.manualRefresh),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.historyData.isEmpty) {
          return const Center(
            child: Text('No history data available',
                style: TextStyle(fontSize: 18)),
          );
        }
        // A flex Table fills the available width exactly, so all 7 columns are
        // visible with NO horizontal scrolling; long values simply wrap.
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(6),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade600, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(2.7), // Ticket Name
              1: FlexColumnWidth(0.9), // Count
              2: FlexColumnWidth(1.3), // Amount
              3: FlexColumnWidth(1.7), // Draw Time
              4: FlexColumnWidth(2.1), // Open Draw
              5: FlexColumnWidth(1.6), // Result
              6: FlexColumnWidth(1.4), // Win
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF0E2B76)),
                children: [
                  historyCell('Ticket Name', header: true),
                  historyCell('Count', header: true),
                  historyCell('Amount', header: true),
                  historyCell('Draw Time', header: true),
                  historyCell('Open Draw', header: true),
                  historyCell('Result', header: true),
                  historyCell('Win', header: true),
                ],
              ),
              ...controller.historyData.map((data) {
                final isWin = data['isWin'] == true;
                final open = stripHtml(data['drawopen']?.toString());
                return TableRow(
                  children: [
                    historyCell(data['ticketnm']?.toString() ?? 'N/A',
                        align: TextAlign.left),
                    historyCell(data['ticketCount']?.toString() ?? '0'),
                    historyCell('₹${data['totamount']?.toString() ?? '0'}'),
                    historyCell(data['drawtime']?.toString() ?? 'N/A'),
                    historyCell(open.isEmpty ? 'N/A' : open),
                    historyCell(
                        (data['result']?.toString() ?? 'PENDING').toUpperCase(),
                        color: isWin ? Colors.green : Colors.red),
                    historyCell('₹${data['winamount']?.toString() ?? '0'}'),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      }),
    );
  }
}
