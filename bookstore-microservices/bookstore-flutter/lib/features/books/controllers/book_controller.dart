import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/book_model.dart';

class BookController extends GetxController {
  final _dio = DioClient.instance;

  final books = <BookModel>[].obs;
  final genres = <dynamic>[].obs;
  final isLoading = false.obs;
  final currentPage = 0.obs;
  final totalPages = 1.obs;
  final searchName = ''.obs;
  final selectedGenreId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
    fetchGenres();
  }

  Future<void> fetchBooks({bool reset = false}) async {
    if (reset) {
      currentPage.value = 0;
      books.clear();
    }
    isLoading.value = true;
    try {
      final response = await _dio.get(ApiEndpoints.bookSearch, queryParameters: {
        if (searchName.isNotEmpty) 'name': searchName.value,
        if (selectedGenreId.value != null) 'genreId': selectedGenreId.value,
        'page': currentPage.value,
        'size': 10,
      });
      final body = response.data;
      if (body['success'] == true) {
        final pageData = body['data'];
        final content = pageData['content'] as List;
        books.assignAll(content.map((e) => BookModel.fromJson(e)).toList());
        totalPages.value = pageData['totalPages'] ?? 1;
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Không thể tải sách');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGenres() async {
    try {
      final response = await _dio.get(ApiEndpoints.genres);
      if (response.data['success'] == true) {
        genres.assignAll(response.data['data'] as List);
      }
    } catch (_) {}
  }

  Future<BookModel?> getBookById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.bookById(id));
      if (response.data['success'] == true) {
        return BookModel.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  void search(String name, {int? genreId}) {
    searchName.value = name;
    selectedGenreId.value = genreId;
    fetchBooks(reset: true);
  }

  void nextPage() {
    if (currentPage.value < totalPages.value - 1) {
      currentPage.value++;
      fetchBooks();
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      fetchBooks();
    }
  }
}
