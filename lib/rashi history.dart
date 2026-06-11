import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'rashi history controller.dart';

class RashiHistory extends StatelessWidget {
  final String username;
  final RashiHistoryController controller;

  RashiHistory({required this.username}) : controller = Get.put(RashiHistoryController()) {
    controller.setUsername(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E2B76),
        title: Row(
          children: [
            const Text('Rashi History', style: TextStyle(color: Colors.white)),
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
                    columnSpacing: isSmallScreen ? 8 : 16, horizontalMargin: 8, headingRowHeight: 44, border: TableBorder.all(color: Colors.grey.shade500, width: 1),
                    dataRowMinHeight: 42,
                    dataRowMaxHeight: 80,
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
                              width: isSmallScreen ? 110 : 180,
                              child: Text(
                                data['ticketnm']?.toString() ?? 'N/A',
                                maxLines: 3,
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
                              width: isSmallScreen ? 90 : 150,
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