import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Nhập email để nhận mật khẩu tạm thời.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _authController.isLoading.value ? null : _onSubmit,
                child: _authController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gửi'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    final success = await _authController.forgotPassword(_emailCtrl.text.trim());
    if (success) {
      Get.snackbar('Thành công', 'Mật khẩu tạm thời đã được gửi đến email của bạn!');
      Get.toNamed('/login');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }
}
