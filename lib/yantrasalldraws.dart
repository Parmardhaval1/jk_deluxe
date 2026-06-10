import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class YantraHistoryControl extends GetxController {
  final box = GetStorage();
  final username = ''.obs;
  final isLoading = true.obs;
  final historyItems = <Map<String, dynamic>>[].obs;
  final visibleItems = <Map<String, dynamic>>[].obs;
  final int batchSize = 15;
  final int initialLoad = 20;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    username.value = box.read('username') ?? '';
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(Api.getUrl('Application/yantra_alldraw.php')),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          final items = List<Map<String, dynamic>>.from(result['data'])
              .map((item) {
            // Debug print to check the image data
            print('Original image path: ${item['image']}');

            final imageUrl = Api.getUrl(item['image'].toString());
            print('Constructed image URL: $imageUrl');

            return {
              ...item,
              'image_url': imageUrl,
              'date': item['drawdate'] ?? item['date'] ?? 'N/A',
              'time': item['drawtime'] ?? item['time'] ?? 'N/A',
              'title': item['tktname'] ?? item['title'] ?? 'N/A',
            };
          }).toList();

          historyItems.assignAll(items);
          loadMoreItems(initialLoad: true);
        } else {
          throw Exception(result['message'] ?? 'Failed to load history');
        }
      } else {
        throw Exception('Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreItems({bool initialLoad = false}) {
    if (!hasMore) return;

    final currentLength = visibleItems.length;
    final remainingItems = historyItems.length - currentLength;
    final nextBatchSize = remainingItems > batchSize ? batchSize : remainingItems;

    if (nextBatchSize > 0) {
      visibleItems.addAll(historyItems.sublist(
          currentLength, currentLength + nextBatchSize));
    } else {
      hasMore = false;
    }
  }
}

class YantrasAlldraws extends StatefulWidget {
  const YantrasAlldraws({Key? key}) : super(key: key);

  @override
  State<YantrasAlldraws> createState() => _YantrasAlldrawsState();
}

class _YantrasAlldrawsState extends State<YantrasAlldraws> {
  final YantraHistoryControl controller = Get.put(YantraHistoryControl());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.loadMoreItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF0E2B76),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.amber),
            onPressed: () => Get.back(),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Yantra All Draw',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                ),
              ),
              Obx(() => Text(
                controller.username.value.isNotEmpty
                    ? controller.username.value
                    : 'Guest',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                ),
              )),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.visibleItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification &&
                _scrollController.position.extentAfter == 0) {
              controller.loadMoreItems();
            }
            return false;
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MasonryGridView.count(
              controller: _scrollController,
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: controller.visibleItems.length + (controller.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.visibleItems.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final item = controller.visibleItems[index];
                print('Displaying item at index $index: ${item['image_url']}');

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['date'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['time'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildImageWidget(item['image_url']),
                        const SizedBox(height: 4),
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    print('Loading image from URL: $imageUrl');
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, progress) {
        print('Image loading progress: $progress');
        return Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: progress.progress,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        print('Image load error: $error for URL: $url');
        return Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 20),
              Text(
                'Load Failed',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}