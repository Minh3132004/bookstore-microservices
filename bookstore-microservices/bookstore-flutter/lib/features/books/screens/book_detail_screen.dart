import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../core/models/book_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../favorites/controllers/favorite_controller.dart';
import '../../../shared/widgets/custom_button.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _dio = DioClient.instance;
  final _cartController = Get.put(CartController());
  final _favoriteController = Get.put(FavoriteController());

  BookModel? _book;
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bookId = Get.arguments as int;
    try {
      final bookResp = await _dio.get(ApiEndpoints.bookById(bookId));
      if (bookResp.data['success'] == true) {
        _book = BookModel.fromJson(bookResp.data['data']);
      }
      final reviewResp = await _dio.get(ApiEndpoints.reviewsByBook(bookId));
      if (reviewResp.data['success'] == true) {
        _reviews = reviewResp.data['data'] as List;
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Không thể tải chi tiết sách');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_book == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy sách')));
    }
    final book = _book!;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.nameBook, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  _favoriteController.isFavorite(book.idBook)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () => _favoriteController.toggleFavorite(book.idBook),
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: book.thumbnailUrl != null
                  ? CachedNetworkImage(imageUrl: book.thumbnailUrl!, fit: BoxFit.contain)
                  : const Icon(Icons.book, size: 120, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.nameBook,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Tác giả: ${book.author}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${book.sellPrice.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      if (book.discountPercent > 0)
                        Text('${book.listPrice.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(' ${book.avgRating.toStringAsFixed(1)}  •  '),
                      Text('Đã bán: ${book.soldQuantity}'),
                      const Spacer(),
                      Text('Còn lại: ${book.quantity}'),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(book.description ?? 'Chưa có mô tả'),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Text('Số lượng:'),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _quantity < book.quantity
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Thêm vào giỏ hàng',
                    icon: Icons.add_shopping_cart,
                    onPressed: book.quantity > 0
                        ? () => _cartController.addItem(book.idBook, quantity: _quantity)
                        : null,
                  ),
                  const Divider(height: 32),
                  Text('Đánh giá (${_reviews.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_reviews.isEmpty)
                    const Text('Chưa có đánh giá nào.')
                  else
                    ..._reviews.map((r) => _ReviewTile(review: r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final dynamic review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${review['userId'] ?? '?'}')),
        title: Row(
          children: List.generate(5, (i) {
            final rating = (review['ratingPoint'] ?? 0).toDouble();
            return Icon(
              i < rating ? Icons.star : Icons.star_border,
              size: 16,
              color: Colors.amber,
            );
          }),
        ),
        subtitle: Text(review['content'] ?? ''),
      ),
    );
  }
}
