import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../../core/models/coupon_model.dart';

class CouponManagementScreen extends StatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  State<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen> {
  final controller = Get.put(AdminController());

  @override
  void initState() {
    super.initState();
    controller.fetchCoupons(page: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý mã giảm giá')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(controller),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.coupons.isEmpty) {
          return const Center(child: Text('Chưa có mã giảm giá nào.'));
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.coupons.length,
                itemBuilder: (ctx, i) {
                  final c = CouponModel.fromJson(
                      Map<String, dynamic>.from(controller.coupons[i]));
                  return Card(
                    child: ListTile(
                      title: Text(c.code,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Giảm ${c.discountPercent}% • HSD: ${c.expiryDate}'
                          '${c.isUsed ? ' • Đã dùng' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: c.isActive,
                            onChanged: (_) => controller.toggleCoupon(c.idCoupon),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteCoupon(c.idCoupon),
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

  void _showCreateDialog(AdminController controller) {
    final quantityCtrl = TextEditingController(text: '1');
    final discountCtrl = TextEditingController(text: '10');
    final expiryCtrl = TextEditingController(
        text: DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]);

    Get.dialog(AlertDialog(
      title: const Text('Tạo mã giảm giá'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: quantityCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Số lượng'),
          ),
          TextField(
            controller: discountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '% giảm giá'),
          ),
          TextField(
            controller: expiryCtrl,
            decoration: const InputDecoration(labelText: 'Ngày hết hạn (yyyy-MM-dd)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: () async {
            final success = await controller.createCouponBatch(
              int.tryParse(quantityCtrl.text) ?? 1,
              int.tryParse(discountCtrl.text) ?? 10,
              expiryCtrl.text.trim(),
            );
            Get.back();
            if (success) Get.snackbar('Thành công', 'Đã tạo mã giảm giá');
          },
          child: const Text('Tạo'),
        ),
      ],
    ));
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
              onPressed: controller.couponPage.value > 0 ? controller.couponPrevPage : null,
            ),
            Text('Trang ${controller.couponPage.value + 1} / ${controller.couponTotalPages.value}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: controller.couponPage.value < controller.couponTotalPages.value - 1
                  ? controller.couponNextPage
                  : null,
            ),
          ],
        ));
  }
}
