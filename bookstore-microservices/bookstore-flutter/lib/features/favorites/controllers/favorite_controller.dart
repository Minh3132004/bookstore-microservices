import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';

class FavoriteController extends GetxController {
  final _dio = DioClient.instance;

  final favorites = <dynamic>[].obs; // danh sách FavoriteBook {idFavorite, userId, bookId}
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return;
    isLoading.value = true;
    try {
      final response = await _dio.get(ApiEndpoints.favoritesByUser(userId));
      if (response.data['success'] == true) {
        favorites.assignAll(response.data['data'] as List);
      }
    } on DioException {
      Get.snackbar('Lỗi', 'Không thể tải danh sách yêu thích');
    } finally {
      isLoading.value = false;
    }
  }

  bool isFavorite(int bookId) {
    return favorites.any((f) => f['bookId'] == bookId);
  }

  Future<void> addFavorite(int bookId) async {
    try {
      await _dio.post(ApiEndpoints.favorites, data: {'bookId': bookId});
      Get.snackbar('Thành công', 'Đã thêm vào yêu thích!');
      fetchFavorites();
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Không thể thêm');
    }
  }

  Future<void> removeFavorite(int bookId) async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return;
    try {
      await _dio.delete(ApiEndpoints.removeFavorite(bookId, userId));
      favorites.removeWhere((f) => f['bookId'] == bookId);
    } catch (_) {}
  }

  Future<void> toggleFavorite(int bookId) async {
    if (isFavorite(bookId)) {
      await removeFavorite(bookId);
    } else {
      await addFavorite(bookId);
    }
  }
}
