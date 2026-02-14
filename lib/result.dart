import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ResultController.dart';

class ResultPage extends StatelessWidget {
  final ResultController controller = Get.put(ResultController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Results'),
        actions: [
          Obx(() => controller.isRefreshing.value
              ? Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.manualRefresh,
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.resultData.isEmpty) {
          return Center(child: Text('No results available'));
        }

        return ListView(
          children: [
            ListTile(
              title: Text('Username'),
              subtitle: Text(controller.username.value),
            ),
            ListTile(
              title: Text('Game Status'),
              subtitle: Text(controller.resultData['status']?.toString() ?? 'N/A'),
            ),
            ListTile(
              title: Text('Last Update'),
              subtitle: Text(controller.resultData['last_updated']?.toString() ?? 'N/A'),
            ),
            // Add more result fields as needed
          ],
        );
      }),
    );
  }
}