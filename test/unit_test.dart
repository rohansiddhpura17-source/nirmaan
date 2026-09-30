import 'package:flutter_test/flutter_test.dart';
import 'package:nirmaan/models/product.dart';
import 'package:nirmaan/models/order.dart';
import 'package:nirmaan/shared/models/user_role.dart';
import 'package:nirmaan/services/auth/mock_auth_service.dart';
import 'package:nirmaan/repositories/auth_repository.dart';
import 'package:nirmaan/features/auth/controllers/auth_controller.dart';
import 'package:nirmaan/services/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SRS Role Permissions Verification', () {
    test('Business Owner has access to BI, Financials, and Twin', () {
      const role = UserRole.businessOwner;
      expect(role.canAccessBusinessIntelligence, isTrue);
      expect(role.canAccessFinancials, isTrue);
      expect(role.canRunBusinessTwin, isTrue);
      expect(role.canManageInventory, isTrue);
      expect(role.canAccessSystemGovernance, isFalse);
    });

    test('Store Manager has access to Operations but not full Governance', () {
      const role = UserRole.storeManager;
      expect(role.canManageInventory, isTrue);
      expect(role.canManageProducts, isTrue);
      expect(role.canProcessOrders, isTrue);
      expect(role.canAccessSystemGovernance, isFalse);
    });

    test('Sales Staff has fast execution access but restricted BI', () {
      const role = UserRole.salesStaff;
      expect(role.canProcessOrders, isTrue);
      expect(role.canAccessBusinessIntelligence, isFalse);
      expect(role.canRunBusinessTwin, isFalse);
      expect(role.canAccessSystemGovernance, isFalse);
    });

    test('Administrator has full system governance access', () {
      const role = UserRole.administrator;
      expect(role.canAccessSystemGovernance, isTrue);
      expect(role.canAccessBusinessIntelligence, isTrue);
      expect(role.canManageProducts, isTrue);
    });
  });

  group('Business Entity Calculations', () {
    test('ProductModel calculates low stock and margins correctly', () {
      final product = ProductModel(
        id: 'prod_01',
        name: 'Basmati Rice',
        category: 'Grains',
        purchasePrice: 100.0,
        sellingPrice: 150.0,
        stockQuantity: 5,
        lowStockThreshold: 10,
        createdAt: DateTime.now(),
      );

      expect(product.isLowStock, isTrue);
      expect(product.isOutOfStock, isFalse);
      // Margin = ((150 - 100) / 150) * 100 = 33.333%
      expect(product.profitMargin, closeTo(33.33, 0.01));
    });

    test('OrderItem calculates total price correctly', () {
      const item = OrderItemModel(
        id: 'item_01',
        productId: 'prod_01',
        productName: 'Rice',
        quantity: 3,
        unitPrice: 150.0,
      );

      expect(item.totalPrice, equals(450.0));
    });
  });

  group('Auth Controller & Mock Service', () {
    test('Login sets authenticated status and persists user', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final authService = MockAuthService(storageService: storage);
      final authRepo = AuthRepository(authService: authService);
      final authController = AuthController(authRepository: authRepo);

      expect(authController.status, equals(AuthStatus.initial));

      final success = await authController.login(
        email: 'owner@nirmaan.com',
        password: 'Password@123',
        role: UserRole.businessOwner,
      );

      expect(success, isTrue);
      expect(authController.status, equals(AuthStatus.authenticated));
      expect(authController.currentUser?.role, equals(UserRole.businessOwner));
      expect(authController.isAuthenticated, isTrue);

      // Verify logout
      await authController.logout();
      expect(authController.status, equals(AuthStatus.unauthenticated));
      expect(authController.currentUser, isNull);
    });
  });
}
