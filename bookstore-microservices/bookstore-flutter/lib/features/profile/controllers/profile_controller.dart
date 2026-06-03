import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/models/user_model.dart';
import '../../../core/storage/token_storage.dart';

class ProfileController extends GetxController {
  final _dio = DioClient.instance;

  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return;
    isLoading.value = true;
    try {
      final response = await _dio.get(ApiEndpoints.userById(userId));
      if (response.data['success'] == true) {
        user.value = UserModel.fromJson(response.data['data']);
      }
    } on DioException catch (e) {
      errorMessage.value = e.response?.data?['message'] ?? 'Không thể tải thông tin';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return false;
    try {
      final response = await _dio.put(ApiEndpoints.userProfile(userId), data: data);
      if (response.data['success'] == true) {
        await fetchProfile();
        return true;
      }
      errorMessage.value = response.data['message'] ?? '';
      return false;
    } on DioException catch (e) {
      errorMessage.value = e.response?.data?['message'] ?? 'Lỗi kết nối';
      return false;
    }
  }

  Future<bool> changeAvatar(File imageFile) async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return false;
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final response = await _dio.put(ApiEndpoints.userAvatar(userId),
          data: {'avatar': base64Image});
      if (response.data['success'] == true) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
