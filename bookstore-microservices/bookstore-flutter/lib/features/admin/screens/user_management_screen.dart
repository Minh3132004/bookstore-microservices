import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    controller.fetchUsers();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.users.isEmpty) {
          return const Center(child: Text('Chưa có người dùng nào.'));
        }
        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (ctx, i) {
            final user = controller.users[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${user['idUser']}')),
                title: Text('${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()),
                subtitle: Text(user['email'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(controller, user),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showEditDialog(AdminController controller, dynamic user) {
    final firstName = TextEditingController(text: user['firstName'] ?? '');
    final lastName = TextEditingController(text: user['lastName'] ?? '');
    final phone = TextEditingController(text: user['phoneNumber'] ?? '');

    Get.dialog(AlertDialog(
      title: const Text('Sửa người dùng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: firstName, decoration: const InputDecoration(labelText: 'Họ đệm')),
          TextField(controller: lastName, decoration: const InputDecoration(labelText: 'Tên')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'SĐT')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: () async {
            final success = await controller.updateUser(user['idUser'], {
              'firstName': firstName.text.trim(),
              'lastName': lastName.text.trim(),
              'phoneNumber': phone.text.trim(),
            });
            Get.back();
            Get.snackbar(success ? 'Thành công' : 'Lỗi',
                success ? 'Cập nhật thành công' : 'Cập nhật thất bại');
          },
          child: const Text('Lưu'),
        ),
      ],
    ));
  }
}
