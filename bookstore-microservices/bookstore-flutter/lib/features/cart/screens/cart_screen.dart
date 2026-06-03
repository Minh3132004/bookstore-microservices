import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.cartItems.isEmpty) {
          return const Center(child: Text('Giỏ hàng trống!'));
        }
        return ListView.builder(
          itemCount: controller.cartItems.length,
          itemBuilder: (ctx, i) {
            final item = controller.cartItems[i];
            return ListTile(
              title: Text('Sách ID: ${item.bookId}'),
              subtitle: Text('Số lượng: ${item.quantity}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: item.quantity > 1
                        ? () => controller.updateQuantity(item.idCartItem, item.quantity - 1)
                        : null,
                  ),
                  Text('${item.quantity}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => controller.updateQuantity(item.idCartItem, item.quantity + 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.removeItem(item.idCartItem),
                  ),
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() => controller.cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/checkout'),
                child: const Text('Tiến hành đặt hàng'),
              ),
            )
          : const SizedBox.shrink()),
    );
  }
}
