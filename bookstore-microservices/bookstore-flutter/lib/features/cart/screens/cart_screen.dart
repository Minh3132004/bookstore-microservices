import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Giỏ hàng trống!'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/products'),
                  child: const Text('Mua sách ngay'),
                ),
              ],
            ),
          );
        }
        final lines = controller.lines;
        return ListView.builder(
          itemCount: lines.length,
          itemBuilder: (ctx, i) {
            final line = lines[i];
            final item = line.item;
            final book = line.book;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 72,
                      child: book?.thumbnailUrl != null
                          ? CachedNetworkImage(
                              imageUrl: book!.thumbnailUrl!,
                              fit: BoxFit.cover,
                              placeholder: (c, u) =>
                                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (c, u, e) => const Icon(Icons.book, size: 40),
                            )
                          : const Icon(Icons.book, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book?.nameBook ?? 'Sách #${item.bookId}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${(book?.sellPrice ?? 0).toStringAsFixed(0)}đ',
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Thành tiền: ${line.lineTotal.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                  color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: item.quantity > 1
                                  ? () => controller.updateQuantity(
                                      item.idCartItem, item.quantity - 1)
                                  : null,
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => controller.updateQuantity(
                                  item.idCartItem, item.quantity + 1),
                            ),
                          ],
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => controller.removeItem(item.idCartItem),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() => controller.cartItems.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Tổng cộng', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('${controller.totalPrice.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.toNamed('/checkout'),
                      child: const Text('Đặt hàng'),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink()),
    );
  }
}
