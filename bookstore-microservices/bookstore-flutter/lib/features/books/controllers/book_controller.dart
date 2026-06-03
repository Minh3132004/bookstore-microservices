import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/book_model.dart';

class BookController extends GetxController {
  final _dio = DioClient.instance;

  final books = <BookModel>[].obs;
  final bestsellers = <BookModel>[].obs;
  final genres = <dynamic>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentPage = 0.obs;
  final totalPages = 1.obs;
  final searchName = ''.obs;
  final selectedGenreId = RxnInt();

  // Admin dùng list/paging riêng (size lớn hơn), không dùng chung customer search.
  final adminBooks = <BookModel>[].obs;
  final adminPage = 0.obs;
  final adminTotalPages = 1.obs;
  final adminLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
    fetchGenres();
    fetchBestsellers();
  }

  Future<void> fetchBooks({bool reset = false}) async {
    if (reset) {
      currentPage.value = 0;
      books.clear();
    }
    isLoading.value = true;
    errorMessage.value = '';
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
      errorMessage.value = e.response?.data?['message'] ?? 'Không thể tải sách';
    } finally {
      isLoading.value = false;
    }
  }

  /// Sách bán chạy: sắp theo soldQuantity giảm dần (dùng endpoint /books có sort).
  Future<void> fetchBestsellers({int size = 5}) async {
    try {
      final response = await _dio.get(ApiEndpoints.books, queryParameters: {
        'page': 0,
        'size': size,
        'sort': 'soldQuantity',
      });
      final body = response.data;
      if (body['success'] == true) {
        final content = body['data']['content'] as List;
        bestsellers.assignAll(content.map((e) => BookModel.fromJson(e)).toList());
      }
    } on DioException {
      // Không chặn home nếu lỗi; danh sách trống sẽ hiển thị empty state.
    }
  }

  Future<void> fetchGenres() async {
    try {
      final response = await _dio.get(ApiEndpoints.genres);
      if (response.data['success'] == true) {
        genres.assignAll(response.data['data'] as List);
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Không thể tải thể loại');
    }
  }

  Future<BookModel?> getBookById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.bookById(id));
      if (response.data['success'] == true) {
        return BookModel.fromJson(response.data['data']);
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Không thể tải thông tin sách');
    }
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

  // ---- Admin ----
  Future<void> fetchBooksForAdmin({bool reset = false, int size = 20}) async {
    if (reset) adminPage.value = 0;
    adminLoading.value = true;
    try {
      final response = await _dio.get(ApiEndpoints.books, queryParameters: {
        'page': adminPage.value,
        'size': size,
        'sort': 'idBook',
      });
      final body = response.data;
      if (body['success'] == true) {
        final pageData = body['data'];
        final content = pageData['content'] as List;
        adminBooks.assignAll(content.map((e) => BookModel.fromJson(e)).toList());
        adminTotalPages.value = pageData['totalPages'] ?? 1;
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Không thể tải sách');
    } finally {
      adminLoading.value = false;
    }
  }

  void adminNextPage() {
    if (adminPage.value < adminTotalPages.value - 1) {
      adminPage.value++;
      fetchBooksForAdmin();
    }
  }

  void adminPrevPage() {
    if (adminPage.value > 0) {
      adminPage.value--;
      fetchBooksForAdmin();
    }
  }
}
