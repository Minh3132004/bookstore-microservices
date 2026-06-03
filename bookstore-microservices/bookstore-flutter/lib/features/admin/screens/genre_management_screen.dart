import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class GenreManagementScreen extends StatelessWidget {
  const GenreManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    controller.fetchGenres();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thể loại')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(controller),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.genres.length,
          itemBuilder: (ctx, i) {
            final genre = controller.genres[i];
            return Card(
              child: ListTile(
                title: Text(genre['nameGenre'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showDialog(controller, genre: genre),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteGenre(genre['idGenre']),
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

  void _showDialog(AdminController controller, {dynamic genre}) {
    final ctrl = TextEditingController(text: genre?['nameGenre'] ?? '');
    final isEdit = genre != null;

    Get.dialog(AlertDialog(
      title: Text(isEdit ? 'Sửa thể loại' : 'Thêm thể loại'),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(labelText: 'Tên thể loại'),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: () async {
            final name = ctrl.text.trim();
            if (name.isEmpty) return;
            final success = isEdit
                ? await controller.updateGenre(genre['idGenre'], name)
                : await controller.createGenre(name);
            Get.back();
            Get.snackbar(success ? 'Thành công' : 'Lỗi',
                success ? 'Đã lưu' : 'Thất bại');
          },
          child: const Text('Lưu'),
        ),
      ],
    ));
  }
}
