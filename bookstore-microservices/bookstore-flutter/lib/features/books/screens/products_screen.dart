import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/book_controller.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sách'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              onSubmitted: (v) => controller.search(v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sách...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.books.isEmpty) {
          return const Center(child: Text('Không tìm thấy sách nào.'));
        }
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.books.length,
                itemBuilder: (ctx, i) => _BookCard(book: controller.books[i]),
              ),
            ),
            _Pagination(controller: controller),
          ],
        );
      }),
    );
  }
}

class _BookCard extends StatelessWidget {
  final dynamic book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/book-detail', arguments: book.idBook),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: book.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: book.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (c, u, e) => const Icon(Icons.book, size: 60),
                    )
                  : const Center(child: Icon(Icons.book, size: 60)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.nameBook,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${book.sellPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  if (book.discountPercent > 0)
                    Text('-${book.discountPercent}%',
                        style: const TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final BookController controller;
  const _Pagination({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: controller.currentPage.value > 0 ? controller.prevPage : null,
        ),
        Text('Trang ${controller.currentPage.value + 1} / ${controller.totalPages.value}'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: controller.currentPage.value < controller.totalPages.value - 1
              ? controller.nextPage
              : null,
        ),
      ],
    ));
  }
}
