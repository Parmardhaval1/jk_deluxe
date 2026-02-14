import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latest_jk/yantra%20history%20controller.dart';

class YantraHistory extends StatelessWidget {
  final String username;
  final YantraHistoryController controller;

  YantraHistory({required this.username}) : controller = Get.put(YantraHistoryController()) {
    controller.setUsername(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E2B76),
        title: Row(
          children: [
            const Text('Yantra History', style: TextStyle(color: Colors.white)),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.manualRefresh,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyData.isEmpty) {
          return const Center(
            child: Text(
                'No history data available',
                style: TextStyle(fontSize: 18)),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: isSmallScreen ? 12 : 24,
                    dataRowMinHeight: 60, // Allows ~4 lines of text
                    dataRowMaxHeight: 100, // Optional max height
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Ticket Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Count',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Draw Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Open Draw',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Result',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Win Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows: controller.historyData.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: isSmallScreen ? 150 : 250,
                              child: Text(
                                data['ticketnm']?.toString() ?? 'N/A',
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data['ticketCount']?.toString() ?? '0',
                              textAlign: TextAlign.end,
                            ),
                          ),
                          DataCell(
                            Text(
                              '₹${data['totamount']?.toString() ?? '0'}',
                              textAlign: TextAlign.end,
                            ),
                          ),
                          DataCell(
                            Text(data['drawtime']?.toString() ?? 'N/A'),
                          ),
                          DataCell(
                            SizedBox(
                              width: isSmallScreen ? 100 : 200,
                              child: Text(data['drawopen']?.toString() ?? 'N/A'),
                            ),
                          ),
                          DataCell(
                            Text(
                              (data['result']?.toString() ?? 'PENDING').toUpperCase(),
                              style: TextStyle(
                                color: (data['isWin'] == true) ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '₹${data['winamount']?.toString() ?? '0'}',
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}