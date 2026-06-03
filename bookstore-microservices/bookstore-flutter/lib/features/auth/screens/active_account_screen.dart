import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../shared/widgets/custom_button.dart';

class ActiveAccountScreen extends StatefulWidget {
  const ActiveAccountScreen({super.key});

  @override
  State<ActiveAccountScreen> createState() => _ActiveAccountScreenState();
}

class _ActiveAccountScreenState extends State<ActiveAccountScreen> {
  final _dio = DioClient.instance;
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Hỗ trợ deep link: /active-account?email=...&code=...
    // Đọc từ URL query params (khi click link từ email trên web)
    final uri = Uri.base;
    final emailParam = uri.queryParameters['email'];
    final codeParam = uri.queryParameters['code'];

    if (emailParam != null && emailParam.isNotEmpty) {
      _emailCtrl.text = emailParam;
    }
    if (codeParam != null && codeParam.isNotEmpty) {
      _codeCtrl.text = codeParam;
      // Tự động kích hoạt nếu cả 2 params đều có
      if (emailParam != null && emailParam.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _activate());
      }
    }

    // Fallback: đọc từ GetX arguments (khi navigate nội bộ)
    final args = Get.arguments;
    if (args is Map) {
      if (_emailCtrl.text.isEmpty) _emailCtrl.text = args['email'] ?? '';
      if (_codeCtrl.text.isEmpty) _codeCtrl.text = args['code'] ?? '';
    }
  }

  Future<void> _activate() async {
    if (_emailCtrl.text.trim().isEmpty || _codeCtrl.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập email và mã kích hoạt');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final resp = await _dio.get(ApiEndpoints.activate, queryParameters: {
        'email': _emailCtrl.text.trim(),
        'code': _codeCtrl.text.trim(),
      });
      if (resp.data['success'] == true) {
        Get.snackbar('Thành công', 'Kích hoạt tài khoản thành công!');
        Get.offAllNamed('/login');
      } else {
        Get.snackbar('Lỗi', resp.data['message'] ?? 'Kích hoạt thất bại');
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Kích hoạt thất bại');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kích hoạt tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Nhập email và mã kích hoạt đã gửi đến hộp thư của bạn.'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                  labelText: 'Mã kích hoạt', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            CustomButton(text: 'Kích hoạt', isLoading: _isLoading, onPressed: _activate),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }
}
