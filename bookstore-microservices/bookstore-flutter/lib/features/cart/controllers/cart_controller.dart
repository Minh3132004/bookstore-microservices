import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/cart_item_model.dart';
import '../../../core/storage/token_storage.dart';

class CartController extends GetxController {
  final _dio = DioClient.instance;

  final cartItems = <CartItemModel>[].obs;
  final isLoading = false.obs;

  double get totalPrice => cartItems.fold(0, (sum, item) => sum + (item.quantity * 0));

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return;
    isLoading.value = true;
    try {
      final response = await _dio.get(ApiEndpoints.cart(userId));
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        cartItems.assignAll(data.map((e) => CartItemModel.fromJson(e)).toList());
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải giỏ hàng');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(int bookId, {int quantity = 1}) async {
    try {
      await _dio.post(ApiEndpoints.cartItems, data: {'bookId': bookId, 'quantity': quantity});
      Get.snackbar('Thành công', 'Đã thêm vào giỏ hàng!');
      fetchCart();
    } on DioException {
      Get.snackbar('Lỗi', 'Không thể thêm vào giỏ hàng');
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    try {
      await _dio.put(ApiEndpoints.cartItem(cartItemId), data: {'quantity': quantity});
      fetchCart();
    } catch (_) {}
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _dio.delete(ApiEndpoints.cartItem(cartItemId));
      cartItems.removeWhere((item) => item.idCartItem == cartItemId);
    } catch (_) {}
  }
}
