import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed('/book-detail', arguments: book.idBook),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: book.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: book.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (c, u) =>
                                const Center(child: CircularProgressIndicator()),
                            errorWidget: (c, u, e) => const Icon(Icons.book, size: 60),
                          )
                        : const Center(child: Icon(Icons.book, size: 60, color: Colors.grey)),
                  ),
                  if (book.discountPercent > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('-${book.discountPercent}%',
                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                ],
              ),
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
                  const SizedBox(height: 2),
                  Text(book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${book.sellPrice.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(book.avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
