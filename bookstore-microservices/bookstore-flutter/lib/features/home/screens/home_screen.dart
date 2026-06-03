import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../books/controllers/book_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BookController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookStore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.toNamed('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/products'),
              icon: const Icon(Icons.menu_book),
              label: const Text('Xem tất cả sách'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Sách bán chạy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const Expanded(child: _BestSellerList()),
        ],
      ),
    );
  }
}

class _BestSellerList extends StatelessWidget {
  const _BestSellerList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final topBooks = controller.books.take(5).toList();
      return ListView.builder(
        itemCount: topBooks.length,
        itemBuilder: (ctx, i) {
          final book = topBooks[i];
          return ListTile(
            leading: const Icon(Icons.book, size: 40),
            title: Text(book.nameBook),
            subtitle: Text('${book.sellPrice.toStringAsFixed(0)}đ • Đã bán: ${book.soldQuantity}'),
            onTap: () => Get.toNamed('/book-detail', arguments: book.idBook),
          );
        },
      );
    });
  }
}
