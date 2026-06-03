import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/controllers/order_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _dio = DioClient.instance;
  final _formKey = GlobalKey<FormState>();
  final _cartController = Get.find<CartController>();
  final _orderController = Get.put(OrderController());
  final _profileController = Get.put(ProfileController());

  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<dynamic> _paymentMethods = [];
  int? _selectedPaymentId;
  final _couponCtrl = TextEditingController();
  int _discountPercent = 0;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _initProfile();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final resp = await _dio.get(ApiEndpoints.payments);
      if (resp.data['success'] == true) {
        setState(() {
          _paymentMethods = resp.data['data'] as List;
          if (_paymentMethods.isNotEmpty) {
            _selectedPaymentId = _paymentMethods.first['idPayment'];
          }
        });
      }
    } on DioException {
      Get.snackbar('Lỗi', 'Không tải được phương thức thanh toán');
    }
  }

  /// Tải profile (nếu chưa có) rồi điền sẵn thông tin giao hàng — tránh race khi user null.
  Future<void> _initProfile() async {
    if (_profileController.user.value == null) {
      await _profileController.fetchProfile();
    }
    if (!mounted) return;
    _prefillProfile();
    setState(() => _loadingProfile = false);
  }

  void _prefillProfile() {
    final user = _profileController.user.value;
    if (user != null) {
      _fullNameCtrl.text = user.fullName;
      _phoneCtrl.text = user.phoneNumber ?? '';
      _addressCtrl.text = user.deliveryAddress ?? '';
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    try {
      final resp = await _dio.get(ApiEndpoints.couponValidate,
          queryParameters: {'code': code});
      if (resp.data['success'] == true) {
        setState(() => _discountPercent = resp.data['data']['discountPercent']);
        Get.snackbar('Thành công', 'Áp dụng mã giảm ${_discountPercent}%!');
      } else {
        Get.snackbar('Lỗi', resp.data['message'] ?? 'Mã không hợp lệ');
      }
    } on DioException catch (e) {
      Get.snackbar('Lỗi', e.response?.data?['message'] ?? 'Mã không hợp lệ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thông tin giao hàng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (_loadingProfile)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Đang tải thông tin giao hàng…'),
                    ],
                  ),
                ),
              _field(_fullNameCtrl, 'Họ và tên', Icons.person),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Số điện thoại', Icons.phone,
                  keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Địa chỉ giao hàng', Icons.location_on),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                    labelText: 'Ghi chú (tuỳ chọn)', border: OutlineInputBorder()),
              ),
              const Divider(height: 32),
              const Text('Mã giảm giá',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _couponCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nhập mã', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _applyCoupon, child: const Text('Áp dụng')),
                ],
              ),
              const Divider(height: 32),
              const Text('Phương thức thanh toán',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ..._paymentMethods.map((p) => RadioListTile<int>(
                    value: p['idPayment'],
                    groupValue: _selectedPaymentId,
                    title: Text(p['namePayment'] ?? ''),
                    subtitle: Text(p['description'] ?? ''),
                    onChanged: (v) => setState(() => _selectedPaymentId = v),
                  )),
              const Divider(height: 32),
              _buildTotalSection(),
              const SizedBox(height: 16),
              Obx(() => CustomButton(
                    text: 'Đặt hàng',
                    isLoading: _orderController.isLoading.value,
                    onPressed: _onPlaceOrder,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    final subtotal = _calcSubtotal();
    final discount = subtotal * _discountPercent / 100;
    final total = subtotal - discount + AppConstants.shippingFee;
    return Column(
      children: [
        _row('Tạm tính', '${subtotal.toStringAsFixed(0)}đ'),
        if (_discountPercent > 0)
          _row('Giảm giá ($_discountPercent%)', '-${discount.toStringAsFixed(0)}đ'),
        _row('Phí giao hàng', '${AppConstants.shippingFee.toStringAsFixed(0)}đ'),
        const Divider(),
        _row('Tổng cộng', '${total.toStringAsFixed(0)}đ', bold: true),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: bold ? 18 : 14,
        color: bold ? Colors.red : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  // Tạm tính lấy từ giỏ đã làm giàu (giá × SL). Server tính lại tổng cuối (R3).
  double _calcSubtotal() => _cartController.totalPrice;

  Future<void> _onPlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentId == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn phương thức thanh toán');
      return;
    }

    final subtotal = _calcSubtotal();
    final total = subtotal - (subtotal * _discountPercent / 100) + AppConstants.shippingFee;

    final orderItems = _cartController.cartItems
        .map((item) => {'bookId': item.bookId, 'quantity': item.quantity})
        .toList();

    final order = await _orderController.createOrder(
      deliveryAddress: _addressCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
      totalPriceProduct: subtotal,
      totalPrice: total,
      paymentId: _selectedPaymentId!,
      paymentStatus: 'PENDING',
      note: _noteCtrl.text.trim(),
      orderItems: orderItems,
    );

    if (order != null) {
      // Đánh dấu coupon đã dùng nếu có (báo lỗi rõ, không nuốt lỗi).
      if (_couponCtrl.text.trim().isNotEmpty && _discountPercent > 0) {
        try {
          await _dio.put(ApiEndpoints.couponUse,
              queryParameters: {'code': _couponCtrl.text.trim()});
        } on DioException catch (e) {
          Get.snackbar('Lưu ý', e.response?.data?['message'] ?? 'Không thể ghi nhận mã giảm giá');
        }
      }
      _cartController.fetchCart();
      // Dùng tổng server tính (order.totalPrice) cho màn xác nhận.
      Get.offNamed('/payment-success', arguments: {
        'orderId': order.idOrder,
        'totalPrice': order.totalPrice,
      });
    } else {
      Get.snackbar('Lỗi', _orderController.errorMessage.value);
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboard}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder(), prefixIcon: Icon(icon)),
      validator: (v) => v!.trim().isEmpty ? 'Không được để trống' : null,
    );
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }
}
