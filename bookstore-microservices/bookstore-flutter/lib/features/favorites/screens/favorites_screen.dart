import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../controllers/favorite_controller.dart';
import '../../../core/models/book_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoriteController());

    return Scaffold(
      appBar: AppBar(title: const Text('Sách yêu thích')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.favorites.isEmpty) {
          return const Center(child: Text('Chưa có sách yêu thích nào.'));
        }
        return ListView.builder(
          itemCount: controller.favorites.length,
          itemBuilder: (ctx, i) {
            final fav = controller.favorites[i];
            final bookId = fav['bookId'] as int;
            return _FavoriteTile(
              bookId: bookId,
              onRemove: () => controller.removeFavorite(bookId),
            );
          },
        );
      }),
    );
  }
}

class _FavoriteTile extends StatefulWidget {
  final int bookId;
  final VoidCallback onRemove;

  const _FavoriteTile({required this.bookId, required this.onRemove});

  @override
  State<_FavoriteTile> createState() => _FavoriteTileState();
}

class _FavoriteTileState extends State<_FavoriteTile> {
  BookModel? _book;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final resp = await DioClient.instance.get(ApiEndpoints.bookById(widget.bookId));
      if (resp.data['success'] == true && mounted) {
        setState(() => _book = BookModel.fromJson(resp.data['data']));
      }
    } on DioException {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, size: 40),
        title: Text(_book?.nameBook ?? 'Đang tải... (ID: ${widget.bookId})'),
        subtitle: _book != null
            ? Text('${_book!.sellPrice.toStringAsFixed(0)}đ')
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: widget.onRemove,
        ),
        onTap: () => Get.toNamed('/book-detail', arguments: widget.bookId),
      ),
    );
  }
}
