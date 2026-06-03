import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feedback_controller.dart';
import '../../../shared/widgets/custom_button.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());
    final contentCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Gửi phản hồi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Chúng tôi rất mong nhận được góp ý của bạn!'),
            const SizedBox(height: 16),
            TextField(
              controller: contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Nội dung phản hồi',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => CustomButton(
                  text: 'Gửi',
                  icon: Icons.send,
                  isLoading: controller.isLoading.value,
                  onPressed: () async {
                    if (contentCtrl.text.trim().isEmpty) {
                      Get.snackbar('Lỗi', 'Vui lòng nhập nội dung');
                      return;
                    }
                    final success = await controller.sendFeedback(contentCtrl.text.trim());
                    if (success) {
                      Get.snackbar('Thành công', 'Cảm ơn phản hồi của bạn!');
                      contentCtrl.clear();
                      Get.back();
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
