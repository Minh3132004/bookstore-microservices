import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

/// Controller gộp cho các màn hình quản trị (User, Book, Genre, Order, Coupon, Feedback).
class AdminController extends GetxController {
  final _dio = DioClient.instance;

  final users = <dynamic>[].obs;
  final genres = <dynamic>[].obs;
  final orders = <dynamic>[].obs;
  final coupons = <dynamic>[].obs;
  final feedbacks = <dynamic>[].obs;
  final unreadFeedbackCount = 0.obs;
  final isLoading = false.obs;

  // ----- USERS -----
  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final resp = await _dio.get(ApiEndpoints.users);
      if (resp.data['success'] == true) users.assignAll(resp.data['data'] as List);
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.patch(ApiEndpoints.userById(id), data: data);
      if (resp.data['success'] == true) {
        fetchUsers();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ----- GENRES -----
  Future<void> fetchGenres() async {
    isLoading.value = true;
    try {
      final resp = await _dio.get(ApiEndpoints.genres);
      if (resp.data['success'] == true) genres.assignAll(resp.data['data'] as List);
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGenre(String name) async {
    try {
      final resp = await _dio.post(ApiEndpoints.genres, data: {'nameGenre': name});
      if (resp.data['success'] == true) {
        fetchGenres();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateGenre(int id, String name) async {
    try {
      await _dio.put(ApiEndpoints.genreById(id), data: {'nameGenre': name});
      fetchGenres();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteGenre(int id) async {
    try {
      await _dio.delete(ApiEndpoints.genreById(id));
      genres.removeWhere((g) => g['idGenre'] == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ----- ORDERS -----
  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final resp = await _dio.get(ApiEndpoints.orders);
      if (resp.data['success'] == true) orders.assignAll(resp.data['data'] as List);
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      await _dio.put(ApiEndpoints.orderStatus(id), data: {'status': status});
      fetchOrders();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ----- COUPONS -----
  Future<void> fetchCoupons() async {
    isLoading.value = true;
    try {
      final resp = await _dio.get(ApiEndpoints.coupons);
      if (resp.data['success'] == true) {
        coupons.assignAll(resp.data['data']['content'] as List);
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCouponBatch(int quantity, int discountPercent, String expiryDate) async {
    try {
      await _dio.post('${ApiEndpoints.couponBatch}?quantity=$quantity',
          data: {'discountPercent': discountPercent, 'expiryDate': expiryDate});
      fetchCoupons();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleCoupon(int id) async {
    try {
      await _dio.put(ApiEndpoints.couponToggle(id));
      fetchCoupons();
    } catch (_) {}
  }

  Future<void> deleteCoupon(int id) async {
    try {
      await _dio.delete(ApiEndpoints.couponById(id));
      coupons.removeWhere((c) => c['idCoupon'] == id);
    } catch (_) {}
  }

  // ----- FEEDBACKS -----
  Future<void> fetchFeedbacks() async {
    isLoading.value = true;
    try {
      final resp = await _dio.get(ApiEndpoints.feedbacks);
      if (resp.data['success'] == true) {
        feedbacks.assignAll(resp.data['data']['content'] as List);
      }
      final countResp = await _dio.get(ApiEndpoints.feedbackUnreadCount);
      if (countResp.data['success'] == true) {
        unreadFeedbackCount.value = countResp.data['data'];
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<void> markFeedbackRead(int id) async {
    try {
      await _dio.put(ApiEndpoints.feedbackRead(id));
      fetchFeedbacks();
    } catch (_) {}
  }

  Future<void> deleteFeedback(int id) async {
    try {
      await _dio.delete(ApiEndpoints.feedbackById(id));
      feedbacks.removeWhere((f) => f['idFeedback'] == id);
    } catch (_) {}
  }
}
