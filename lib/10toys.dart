import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latest_jk/toy%20history.dart';
import 'package:latest_jk/toysalldraws.dart';
import 'LoginScreen.dart';
import 'Profile.dart';
import 'ToysController.dart';
import 'choosegame.dart';
import 'ui_helpers.dart';

class Item {
  final String img;
  final String title;
  String date;
  String time;
  Item({required this.img, required this.title, required this.date, required this.time});
}

class Toys extends StatelessWidget {
  final ToysController controller = Get.put(ToysController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Listen to refresh trigger (rebuilds when `shouldRefreshPage` changes)
      if (controller.shouldRefreshPage.value) {
        controller.shouldRefreshPage.value = false; // Reset flag
        print('[${DateTime.now()}] Rebuilding entire Toys page');
      }

      var screenSize = MediaQuery
          .of(context)
          .size;
      var screenWidth = screenSize.width;
      var screenHeight = screenSize.height;

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.1),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: AppBar(
              backgroundColor: const Color(0xFF0E2B76),
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'JK Delux',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),

                  // Grouped number containers with reduced spacing
                  Row(
                    children: [
                      _buildImageContainer('assets/ticket1.png', '1'),
                      SizedBox(width: 15),
                      _buildImageContainer('assets/ticket2.png', '2'),
                      SizedBox(width: 15),
                      _buildImageContainer('assets/ticket5.png', '5'),
                      SizedBox(width: 15),
                      _buildImageContainer('assets/ticket10.png', '10'),
                      SizedBox(width: 15),
                      _buildImageContainer('assets/ticket15.png', '15'),
                      SizedBox(width: 15),
                      _buildImageContainer('assets/ticket20.png', '20'),
                      SizedBox(width: 15),
                      _buildImageContainer('assets/ticket30.png', '30'),
                    ],
                  ),
                  Obx(() =>
                      Text(
                        controller.username.value.isNotEmpty
                            ? controller.username.value
                            : 'Guest',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      )),
                ],
              ),
              actions: [
                Obx(() => IconButton(
                      tooltip: 'Delete last ticket',
                      icon: controller.isDeleting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: controller.isDeleting.value
                          ? null
                          : () => controller.deleteLastTicket(),
                    )),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    controller.fetchAvailableCoins();
                    controller.fetchLast5Draws();
                  },
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: screenWidth * 0.14,
                    height: screenHeight * 0.82,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            final box = GetStorage();
                            final storedUsername = box.read('username') ?? '';
                            Get.to(() => ChooseGame(username: storedUsername));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDB1E1E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 30),
                          ),
                          child: const Text('Exit'),
                        ),
                        Image.asset(
                          'assets/jackpot.png',
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 1.0),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => Profile());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E2B76),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 30),
                          ),
                          child: const Text('Profile'),
                        ),
                        const SizedBox(height: 1.0),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => ToyHistory(username: controller.username.value));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E2B76),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 30),
                          ),
                          child: const Text('History'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final box = GetStorage();
                            await box.remove('username');
                            Get.offAll(() => LoginScreen());
                            Get.deleteAll(force: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDB1E1E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 30),
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Obx(() =>
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: List.generate(
                                  controller.data.length, (index) {
                                Item item = controller.data[index];
                                return GestureDetector(
                                  onTap: () =>
                                      controller.selectItem(item.title, index),
                                  child: Container(
                                    width: screenWidth * 0.12,
                                    height: screenHeight * 0.3,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.all(7),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 3),
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(item.img),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: 50,
                                            height: 25,
                                            child: TextField(
                                              keyboardType: TextInputType
                                                  .number,
                                              controller: controller
                                                  .textControllers[item.title],
                                              onChanged: (value) {
                                                int newValue = int.tryParse(
                                                    value) ?? 0;
                                                controller.itemCountMap[item
                                                    .title] = newValue;
                                                controller
                                                    .calculateTotalAmount();
                                              },
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              enabled: !controller
                                                  .isLessThanThirtySeconds
                                                  .value,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: controller
                                                    .isLessThanThirtySeconds
                                                    .value
                                                    ? Colors.black
                                                    : Colors.black,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(10.0),
                                                ),
                                                contentPadding: const EdgeInsets
                                                    .all(4),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            )),
                        Column(
                          children: [
                            Obx(() =>
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(
                                      controller.data2.length, (index) {
                                    Item item = controller.data2[index];
                                    return GestureDetector(
                                      onTap: () =>
                                          controller.selectItem(
                                              item.title, index),
                                      child: Container(
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.3,
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.shade100,
                                          borderRadius: BorderRadius.circular(
                                              10),
                                        ),
                                        margin: const EdgeInsets.all(7),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 3),
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(item.img),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                width: 50,
                                                height: 25,
                                                child: TextField(
                                                  keyboardType: TextInputType
                                                      .number,
                                                  controller: controller
                                                      .textControllers[item
                                                      .title],
                                                  onChanged: (value) {
                                                    int newValue = int.tryParse(
                                                        value) ?? 0;
                                                    controller.itemCountMap[item
                                                        .title] = newValue;
                                                    controller
                                                        .calculateTotalAmount();
                                                  },
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  enabled: !controller
                                                      .isLessThanThirtySeconds
                                                      .value,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: controller
                                                        .isLessThanThirtySeconds
                                                        .value
                                                        ? Colors.black
                                                        : Colors.black,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(10.0),
                                                    ),
                                                    contentPadding: const EdgeInsets
                                                        .all(4),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => controller.clearAll(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0E2B76),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(40, 20),
                                  ),
                                  child: const Text('Clear'),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => ToysAlldraws());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0E2B76),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(40, 20),
                                  ),
                                  child: const Text('All Draws'),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: (controller.isLessThanThirtySeconds.value ||
                                          controller.isSubmitting.value)
                                      ? null
                                      : () {
                                    if (controller.totalClicks.value > 0) {
                                      controller.submitTickets();
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Please select at least one ticket',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: controller
                                        .isLessThanThirtySeconds.value
                                        ? Colors
                                        .grey // Change color to indicate disabled state
                                        : const Color(0xFF0E2B76),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(70, 20),
                                  ),
                                  child: controller.isSubmitting.value
                                      ? buttonSpinner()
                                      : const Text('Ok'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Obx(() =>
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: screenWidth * 0.16,
                        height: screenHeight * 0.82,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Avl Coins',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.currency_rupee_rounded,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Obx(() =>
                                    Text(
                                      '${controller.available.value}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Tickets',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${controller.totalClicks.value}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${controller.totalAmount.value}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              controller.currentDate.value,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Draw Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              controller.timeSession.value,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Remaining Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Obx(() =>
                                Text(
                                  controller.remainingTime.value,
                                  style: TextStyle(
                                    color: controller.isLessThanThirtySeconds
                                        .value
                                        ? Colors.red
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                )),
                            const SizedBox(height: 2),
                            const Text(
                              'Current Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              controller.currentTime.value,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Last 5 Draws',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        controller.last5Draws.length, (index) {
                      Item item = controller.last5Draws[index];
                      return Container(
                        width: 98,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(7),
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                item.date,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.time,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(item.img), // Changed from AssetImage to NetworkImage
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // You can add error handling here
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Flexible(
                                child: Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImageContainer(String imagePath, String value) {
    return GestureDetector(
      onTap: () {
        // Only update the selected number for visual feedback
        controller.selectedNumber.value = value;
      },
      child: Obx(() => Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: controller.selectedNumber.value == value
              ? Colors.amber.withOpacity(0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          imagePath,
          width: 40,
          height: 40,
        ),
      )),
    );
  }
}