import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  static const _statuses = ['Đang xử lý', 'Đang giao', 'Hoàn thành', 'Bị huỷ'];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    controller.fetchOrders();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn hàng')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.orders.isEmpty) {
          return const Center(child: Text('Chưa có đơn hàng nào.'));
        }
        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (ctx, i) {
            final order = controller.orders[i];
            return Card(
              child: ListTile(
                title: Text('Đơn #${order['idOrder']} - ${order['fullName'] ?? ''}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng: ${(order['totalPrice'] ?? 0).toStringAsFixed(0)}đ'),
                    Text('Ngày: ${order['dateCreated'] ?? '-'}'),
                  ],
                ),
                trailing: DropdownButton<String>(
                  value: _statuses.contains(order['status']) ? order['status'] : null,
                  hint: const Text('Trạng thái'),
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      controller.updateOrderStatus(order['idOrder'], newStatus);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
