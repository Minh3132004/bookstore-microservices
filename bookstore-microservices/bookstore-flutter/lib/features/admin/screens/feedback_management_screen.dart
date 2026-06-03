import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class FeedbackManagementScreen extends StatelessWidget {
  const FeedbackManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    controller.fetchFeedbacks();

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
        return ListView.builder(
          itemCount: controller.feedbacks.length,
          itemBuilder: (ctx, i) {
            final f = controller.feedbacks[i];
            final isRead = f['read'] == true;
            return Card(
              color: isRead ? null : Colors.indigo.withOpacity(0.05),
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
        );
      }),
    );
  }
}
