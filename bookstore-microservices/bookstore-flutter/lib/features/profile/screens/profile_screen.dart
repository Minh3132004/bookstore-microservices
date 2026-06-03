import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = controller.user.value;
        if (user == null) {
          return const Center(child: Text('Không tải được thông tin'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickAvatar(controller),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          (user.avatar != null && user.avatar!.isNotEmpty)
                              ? CachedNetworkImageProvider(user.avatar!)
                              : null,
                      child: (user.avatar == null || user.avatar!.isEmpty)
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(user.fullName.isEmpty ? user.email : user.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              _infoTile(Icons.phone, 'Số điện thoại', user.phoneNumber ?? 'Chưa cập nhật'),
              _infoTile(Icons.location_on, 'Địa chỉ', user.deliveryAddress ?? 'Chưa cập nhật'),
              _infoTile(Icons.cake, 'Ngày sinh', user.dateOfBirth ?? 'Chưa cập nhật'),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Chỉnh sửa thông tin',
                icon: Icons.edit,
                onPressed: () => _showEditDialog(context, controller, user),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Get.toNamed('/orders'),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Đơn hàng của tôi'),
              ),
              OutlinedButton.icon(
                onPressed: () => Get.toNamed('/favorites'),
                icon: const Icon(Icons.favorite),
                label: const Text('Sách yêu thích'),
              ),
              OutlinedButton.icon(
                onPressed: () => Get.toNamed('/feedback'),
                icon: const Icon(Icons.feedback),
                label: const Text('Gửi phản hồi'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Future<void> _pickAvatar(ProfileController controller) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      final success = await controller.changeAvatar(File(picked.path));
      Get.snackbar(success ? 'Thành công' : 'Lỗi',
          success ? 'Đổi avatar thành công!' : 'Đổi avatar thất bại');
    }
  }

  void _showEditDialog(BuildContext context, ProfileController controller, user) {
    final firstNameCtrl = TextEditingController(text: user.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: user.lastName ?? '');
    final phoneCtrl = TextEditingController(text: user.phoneNumber ?? '');
    final addressCtrl = TextEditingController(text: user.deliveryAddress ?? '');

    Get.dialog(AlertDialog(
      title: const Text('Chỉnh sửa thông tin'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: firstNameCtrl, decoration: const InputDecoration(labelText: 'Họ đệm')),
            TextField(controller: lastNameCtrl, decoration: const InputDecoration(labelText: 'Tên')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'SĐT')),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Địa chỉ')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: () async {
            final success = await controller.updateProfile({
              'firstName': firstNameCtrl.text.trim(),
              'lastName': lastNameCtrl.text.trim(),
              'phoneNumber': phoneCtrl.text.trim(),
              'deliveryAddress': addressCtrl.text.trim(),
            });
            Get.back();
            Get.snackbar(success ? 'Thành công' : 'Lỗi',
                success ? 'Cập nhật thành công!' : 'Cập nhật thất bại');
          },
          child: const Text('Lưu'),
        ),
      ],
    ));
  }
}
