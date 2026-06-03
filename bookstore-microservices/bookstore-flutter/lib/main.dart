import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/active_account_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/books/screens/products_screen.dart';
import 'features/books/screens/book_detail_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/checkout/screens/checkout_screen.dart';
import 'features/checkout/screens/payment_success_screen.dart';
import 'features/orders/screens/orders_screen.dart';
import 'features/orders/screens/order_detail_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/feedback/screens/feedback_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/user_management_screen.dart';
import 'features/admin/screens/book_management_screen.dart';
import 'features/admin/screens/genre_management_screen.dart';
import 'features/admin/screens/order_management_screen.dart';
import 'features/admin/screens/coupon_management_screen.dart';
import 'features/admin/screens/feedback_management_screen.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BookStoreApp());
}

class BookStoreApp extends StatelessWidget {
  const BookStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BookStore',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      getPages: [
        // Auth
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/active-account', page: () => const ActiveAccountScreen()),
        // Customer
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/products', page: () => const ProductsScreen()),
        GetPage(name: '/book-detail', page: () => const BookDetailScreen()),
        GetPage(name: '/cart', page: () => const CartScreen()),
        GetPage(name: '/checkout', page: () => const CheckoutScreen()),
        GetPage(name: '/payment-success', page: () => const PaymentSuccessScreen()),
        GetPage(name: '/orders', page: () => const OrdersScreen()),
        GetPage(name: '/order-detail', page: () => const OrderDetailScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/favorites', page: () => const FavoritesScreen()),
        GetPage(name: '/feedback', page: () => const FeedbackScreen()),
        // Admin
        GetPage(name: '/admin', page: () => const AdminDashboardScreen()),
        GetPage(name: '/admin/users', page: () => const UserManagementScreen()),
        GetPage(name: '/admin/books', page: () => const BookManagementScreen()),
        GetPage(name: '/admin/genres', page: () => const GenreManagementScreen()),
        GetPage(name: '/admin/orders', page: () => const OrderManagementScreen()),
        GetPage(name: '/admin/coupons', page: () => const CouponManagementScreen()),
        GetPage(name: '/admin/feedbacks', page: () => const FeedbackManagementScreen()),
      ],
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final role = await TokenStorage.getUserRole();
      Get.offAllNamed(role == 'ADMIN' ? '/admin' : '/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
