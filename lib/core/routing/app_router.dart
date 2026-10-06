import 'package:flutter/material.dart';
import '../../features/ai_coach/presentation/ai_coach_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/business_health/presentation/business_health_screen.dart';
import '../../features/business_setup/presentation/business_setup_screen.dart';
import '../../features/main_shell/presentation/main_shell_screen.dart';
import '../../features/customers/presentation/add_customer_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/create_order_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/products/presentation/add_product_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/suppliers/presentation/add_supplier_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';
import '../../features/todays_business/presentation/todays_business_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.businessSetup:
        return MaterialPageRoute(builder: (_) => const BusinessSetupScreen());
      case AppRoutes.mainShell:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case AppRoutes.products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case AppRoutes.addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      case AppRoutes.suppliers:
        return MaterialPageRoute(builder: (_) => const SuppliersScreen());
      case AppRoutes.addSupplier:
        return MaterialPageRoute(builder: (_) => const AddSupplierScreen());
      case AppRoutes.customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      case AppRoutes.addCustomer:
        return MaterialPageRoute(builder: (_) => const AddCustomerScreen());
      case AppRoutes.inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case AppRoutes.orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case AppRoutes.createOrder:
        return MaterialPageRoute(builder: (_) => const CreateOrderScreen());

      case AppRoutes.aiCoach:
        return MaterialPageRoute(builder: (_) => const AiCoachScreen());
      case AppRoutes.todaysBusiness:
        return MaterialPageRoute(builder: (_) => const TodaysBusinessScreen());
      case AppRoutes.analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case AppRoutes.businessHealth:
        return MaterialPageRoute(builder: (_) => const BusinessHealthScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
