import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem('Quản lý người dùng', Icons.people, '/admin/users'),
      _MenuItem('Quản lý sách', Icons.menu_book, '/admin/books'),
      _MenuItem('Quản lý thể loại', Icons.category, '/admin/genres'),
      _MenuItem('Quản lý đơn hàng', Icons.receipt_long, '/admin/orders'),
      _MenuItem('Quản lý mã giảm giá', Icons.local_offer, '/admin/coupons'),
      _MenuItem('Quản lý phản hồi', Icons.feedback, '/admin/feedbacks'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: items
            .map((item) => Card(
                  child: InkWell(
                    onTap: () => Get.toNamed(item.route),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 48, color: Colors.indigo),
                        const SizedBox(height: 12),
                        Text(item.title, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;
  _MenuItem(this.title, this.icon, this.route);
}
