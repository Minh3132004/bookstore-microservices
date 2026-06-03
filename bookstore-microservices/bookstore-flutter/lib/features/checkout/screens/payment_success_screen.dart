import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/custom_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final int? orderId = args is Map ? args['orderId'] as int? : null;
    final double? totalPrice =
        args is Map && args['totalPrice'] != null ? (args['totalPrice'] as num).toDouble() : null;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 16),
              const Text('Đặt hàng thành công!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Cảm ơn bạn đã mua hàng. Đơn hàng đang được xử lý.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              if (orderId != null) ...[
                const SizedBox(height: 16),
                Text('Mã đơn hàng: #$orderId',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
              if (totalPrice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Tổng tiền: ${totalPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                          fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Xem đơn hàng',
                icon: Icons.receipt_long,
                onPressed: () => orderId != null
                    ? Get.offNamed('/order-detail', arguments: orderId)
                    : Get.offAllNamed('/orders'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.offAllNamed('/home'),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
