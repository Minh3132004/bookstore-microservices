import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final controller = Get.put(AdminController());

  @override
  void initState() {
    super.initState();
    controller.fetchFeedbacks(page: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Phản hồi (${controller.unreadFeedbackCount.value} chưa đọc)')),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.feedbacks.isEmpty) {
          return const Center(child: Text('Chưa có phản hồi nào.'));
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.feedbacks.length,
                itemBuilder: (ctx, i) {
                  final f = controller.feedbacks[i];
                  final isRead = f['read'] == true;
                  return Card(
                    color: isRead ? null : Colors.indigo.shade50,
                    child: ListTile(
                      leading: Icon(
                        isRead ? Icons.drafts : Icons.markunread,
                        color: isRead ? Colors.grey : Colors.indigo,
                      ),
                      title: Text(f['content'] ?? ''),
                      subtitle: Text('User ID: ${f['userId']} • ${f['createdAt'] ?? ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isRead)
                            IconButton(
                              icon: const Icon(Icons.done),
                              tooltip: 'Đánh dấu đã đọc',
                              onPressed: () => controller.markFeedbackRead(f['idFeedback']),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteFeedback(f['idFeedback']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _Pagination(controller: controller),
          ],
        );
      }),
    );
  }
}

class _Pagination extends StatelessWidget {
  final AdminController controller;
  const _Pagination({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: controller.feedbackPage.value > 0 ? controller.feedbackPrevPage : null,
            ),
            Text('Trang ${controller.feedbackPage.value + 1} / ${controller.feedbackTotalPages.value}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: controller.feedbackPage.value < controller.feedbackTotalPages.value - 1
                  ? controller.feedbackNextPage
                  : null,
            ),
          ],
        ));
  }
}
