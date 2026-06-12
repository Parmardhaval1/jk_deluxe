import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'ChooseGameController.dart';

class ChooseGame extends StatefulWidget {
  final String username;

  const ChooseGame({Key? key, required this.username}) : super(key: key);

  @override
  State<ChooseGame> createState() => _ChooseGameState();
}

class _ChooseGameState extends State<ChooseGame> {
  final ChooseGameController controller = Get.put(ChooseGameController());

  @override
  void initState() {
    super.initState();
    // Set the username in the controller when the widget initializes
    controller.setUsername(widget.username);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.withOpacity(0.9),
          ),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset('assets/back.jpg', fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              'ABC Online Trading Game',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Obx(
              () => Text(
                controller.username.value.isNotEmpty
                    ? controller.username.value
                    : 'Guest',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 440,
                  height: 220,
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 40,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.8,
                    children: List.generate(3, (index) => _buildCard(index)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    return GestureDetector(
      onTap: () => controller.navigateToGame(index),
      child: Card(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              controller.cardTexts[index],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Image.asset(
              controller.imagePaths[index],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
