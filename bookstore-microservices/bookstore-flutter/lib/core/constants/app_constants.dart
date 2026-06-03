/// Hằng số dùng chung phía client.
class AppConstants {
  /// Phí giao hàng hiển thị ở màn checkout (chỉ để ước tính cho người dùng).
  /// PHẢI khớp với bản ghi Delivery id=1 ở order-service — tổng tiền cuối cùng
  /// luôn được server tính lại (R3), màn payment-success hiển thị số liệu server trả về.
  static const double shippingFee = 30000;
}
