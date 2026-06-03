import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_firstNameCtrl, 'Họ đệm', Icons.person),
              const SizedBox(height: 12),
              _buildField(_lastNameCtrl, 'Tên', Icons.person_outline),
              const SizedBox(height: 12),
              _buildField(_emailCtrl, 'Email', Icons.email,
                  validator: (v) =>
                      v!.isEmpty || !v.contains('@') ? 'Email không hợp lệ' : null),
              const SizedBox(height: 12),
              _buildField(_usernameCtrl, 'Tên đăng nhập', Icons.account_circle),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock)),
                validator: (v) =>
                    v!.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (_authController.errorMessage.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_authController.errorMessage.value,
                        style: const TextStyle(color: Colors.red)),
                  );
                }
                return const SizedBox.shrink();
              }),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _authController.isLoading.value ? null : _onRegister,
                  child: _authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đăng ký'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon)),
      validator: validator ?? (v) => v!.isEmpty ? 'Không được để trống' : null,
    );
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _authController.register(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _firstNameCtrl.text.trim(),
      _lastNameCtrl.text.trim(),
    );
    if (success) {
      Get.snackbar('Thành công', 'Đăng ký thành công! Kiểm tra email để kích hoạt tài khoản.');
      Get.toNamed('/login');
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }
}
