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
                onTap: () => _showOrderDetail(controller, order['idOrder']),
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
                  onChanged: (newStatus) async {
                    if (newStatus != null) {
                      final ok = await controller.updateOrderStatus(order['idOrder'], newStatus);
                      if (ok) Get.snackbar('Thành công', 'Đã cập nhật trạng thái đơn');
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

  Future<void> _showOrderDetail(AdminController controller, int orderId) async {
    final order = await controller.getOrderDetail(orderId);
    if (order == null) return;
    final details = (order['listOrderDetails'] as List?) ?? [];
    Get.dialog(AlertDialog(
      title: Text('Chi tiết đơn #$orderId'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Người nhận: ${order['fullName'] ?? ''}'),
            Text('SĐT: ${order['phoneNumber'] ?? ''}'),
            Text('Địa chỉ: ${order['deliveryAddress'] ?? ''}'),
            Text('Trạng thái: ${order['status'] ?? ''}'),
            const Divider(),
            const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (details.isEmpty)
              const Text('(Không có dòng sản phẩm)')
            else
              ...details.map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                        'Sách #${d['bookId']} — SL ${d['quantity']} × ${(d['price'] ?? 0).toStringAsFixed(0)}đ'),
                  )),
            const Divider(),
            Text('Phí giao: ${(order['feeDelivery'] ?? 0).toStringAsFixed(0)}đ'),
            Text('Tổng: ${(order['totalPrice'] ?? 0).toStringAsFixed(0)}đ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('Đóng'))],
    ));
  }
}
