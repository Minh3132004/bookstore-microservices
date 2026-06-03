import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/order_model.dart';
import '../../../core/storage/token_storage.dart';

class OrderController extends GetxController {
  final _dio = DioClient.instance;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> fetchMyOrders() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return;
    isLoading.value = true;
    try {
      final response = await _dio.get(ApiEndpoints.ordersByUser(userId));
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        orders.assignAll(data.map((e) => OrderModel.fromJson(e)).toList());
      }
    } on DioException catch (e) {
      errorMessage.value = e.response?.data?['message'] ?? 'Không thể tải đơn hàng';
    } finally {
      isLoading.value = false;
    }
  }

  Future<OrderModel?> getOrderById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.orderById(id));
      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  /// Tạo đơn hàng. orderItems = [{bookId, quantity}, ...]
  Future<bool> createOrder({
    required String deliveryAddress,
    required String phoneNumber,
    required String fullName,
    required double totalPriceProduct,
    required double totalPrice,
    required int paymentId,
    required String paymentStatus,
    String? note,
    required List<Map<String, int>> orderItems,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.post(ApiEndpoints.orders, data: {
        'deliveryAddress': deliveryAddress,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'totalPriceProduct': totalPriceProduct,
        'totalPrice': totalPrice,
        'paymentId': paymentId,
        'paymentStatus': paymentStatus,
        'note': note,
        'orderItems': orderItems,
      });
      if (response.data['success'] == true) return true;
      errorMessage.value = response.data['message'] ?? 'Đặt hàng thất bại';
      return false;
    } on DioException catch (e) {
      errorMessage.value = e.response?.data?['message'] ?? 'Lỗi kết nối';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await _dio.put(ApiEndpoints.cancelOrder(orderId));
      if (response.data['success'] == true) {
        await fetchMyOrders();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
