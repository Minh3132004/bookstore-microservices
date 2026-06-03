import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/custom_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 32),
              CustomButton(
                text: 'Xem đơn hàng của tôi',
                icon: Icons.receipt_long,
                onPressed: () => Get.offAllNamed('/orders'),
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
