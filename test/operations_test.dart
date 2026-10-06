import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nirmaan/features/customers/controllers/customer_controller.dart';
import 'package:nirmaan/features/customers/presentation/customers_screen.dart';
import 'package:nirmaan/features/inventory/controllers/inventory_controller.dart';
import 'package:nirmaan/features/inventory/presentation/inventory_screen.dart';
import 'package:nirmaan/features/orders/controllers/order_controller.dart';
import 'package:nirmaan/features/orders/presentation/create_order_screen.dart';
import 'package:nirmaan/features/orders/presentation/orders_screen.dart';
import 'package:nirmaan/features/products/controllers/product_controller.dart';
import 'package:nirmaan/features/products/presentation/products_screen.dart';
import 'package:nirmaan/features/suppliers/controllers/supplier_controller.dart';
import 'package:nirmaan/features/suppliers/presentation/suppliers_screen.dart';
import 'package:nirmaan/models/order.dart';
import 'package:nirmaan/repositories/customer_repository.dart';
import 'package:nirmaan/repositories/inventory_repository.dart';
import 'package:nirmaan/repositories/order_repository.dart';
import 'package:nirmaan/repositories/product_repository.dart';
import 'package:nirmaan/repositories/supplier_repository.dart';
import 'package:nirmaan/services/api/api_client.dart';
import 'package:provider/provider.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;
  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return handler(request);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  // =========================================================================
  // MODULE 1: PRODUCTS
  // =========================================================================
  group('Phase 4: Products Module Tests', () {
    test('ProductController loads products and adds a product', () async {
      final mockClient = MockHttpClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('/products')) {
          final data = [
            {
              'id': 'prod_01',
              'name': 'Basmati Rice 5kg',
              'category': 'Grains & Staples',
              'costPrice': 300.0,
              'purchasePrice': 300.0,
              'sellingPrice': 450.0,
              'currentStock': 20,
              'minStockThreshold': 5,
              'unit': 'kg',
              'status': 'ACTIVE',
            }
          ];
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' && request.url.path.contains('/products')) {
          final newProduct = {
            'id': 'prod_02',
            'name': 'Sunflower Oil 1L',
            'category': 'Edible Oils',
            'costPrice': 110.0,
            'purchasePrice': 110.0,
            'sellingPrice': 140.0,
            'currentStock': 50,
            'minStockThreshold': 10,
            'unit': 'L',
            'status': 'ACTIVE',
          };
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': newProduct}))),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.StreamedResponse(Stream.value([]), 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = ProductRepository(apiClient: apiClient);
      final controller = ProductController(productRepository: repo);

      await controller.loadProducts();
      expect(controller.products.length, equals(1));
      expect(controller.products.first.name, equals('Basmati Rice 5kg'));

      final added = await controller.createProduct(
        name: 'Sunflower Oil 1L',
        category: 'Edible Oils',
        purchasePrice: 110.0,
        sellingPrice: 140.0,
        initialStock: 50,
      );

      expect(added, isTrue);
      expect(controller.products.length, equals(2));
      expect(controller.products.first.name, equals('Sunflower Oil 1L'));
    });

    testWidgets('ProductsScreen displays loaded products with price & stock', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        final data = [
          {
            'id': 'prod_01',
            'name': 'Fortune Sunlite 1L',
            'category': 'Edible Oils',
            'costPrice': 120.0,
            'sellingPrice': 150.0,
            'currentStock': 15,
            'minStockThreshold': 5,
            'unit': 'pcs',
            'status': 'ACTIVE',
          }
        ];
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = ProductRepository(apiClient: apiClient);
      final controller = ProductController(productRepository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<ProductController>.value(
          value: controller,
          child: const MaterialApp(
            home: ProductsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Products Catalog'), findsOneWidget);
      expect(find.text('Fortune Sunlite 1L'), findsOneWidget);
      expect(find.text('₹150'), findsOneWidget);
      expect(find.text('15 pcs'), findsOneWidget);
    });
  });

  // =========================================================================
  // MODULE 2: SUPPLIERS
  // =========================================================================
  group('Phase 4: Suppliers Module Tests', () {
    test('SupplierController loads, creates, and deletes suppliers', () async {
      final mockClient = MockHttpClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('/suppliers')) {
          final data = [
            {
              'id': 'sup_01',
              'name': 'Balaji Traders',
              'category': 'Grocery',
              'phone': '+919876543210',
              'email': 'balaji@example.com',
            }
          ];
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' && request.url.path.contains('/suppliers')) {
          final created = {
            'id': 'sup_02',
            'name': 'Shree Ganesh Agency',
            'category': 'Dairy',
            'phone': '+919876500000',
          };
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': created}))),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'DELETE' && request.url.path.contains('/suppliers/sup_01')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'message': 'Deleted'}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.StreamedResponse(Stream.value([]), 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = SupplierRepository(apiClient: apiClient);
      final controller = SupplierController(supplierRepository: repo);

      await controller.loadSuppliers();
      expect(controller.suppliers.length, equals(1));
      expect(controller.suppliers.first.name, equals('Balaji Traders'));

      final added = await controller.createSupplier(
        name: 'Shree Ganesh Agency',
        category: 'Dairy',
        phone: '+919876500000',
      );
      expect(added, isTrue);
      expect(controller.suppliers.length, equals(2));

      final deleted = await controller.deleteSupplier('sup_01');
      expect(deleted, isTrue);
      expect(controller.suppliers.length, equals(1));
      expect(controller.suppliers.first.id, equals('sup_02'));
    });

    testWidgets('SuppliersScreen renders supplier cards', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        final data = [
          {
            'id': 'sup_01',
            'name': 'Arihant Enterprises',
            'category': 'FMCG Wholesale',
            'phone': '+919123456789',
            'email': 'arihant@wholesale.in',
            'address': 'Market Yard, Gate 2',
          }
        ];
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = SupplierRepository(apiClient: apiClient);
      final controller = SupplierController(supplierRepository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<SupplierController>.value(
          value: controller,
          child: const MaterialApp(
            home: SuppliersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Suppliers Directory'), findsOneWidget);
      expect(find.text('Arihant Enterprises'), findsOneWidget);
      expect(find.text('+919123456789'), findsOneWidget);
      expect(find.text('Market Yard, Gate 2'), findsOneWidget);
    });
  });

  // =========================================================================
  // MODULE 3: CUSTOMERS
  // =========================================================================
  group('Phase 4: Customers Module Tests', () {
    test('CustomerController loads, adds, and removes customers', () async {
      final mockClient = MockHttpClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('/customers')) {
          final data = [
            {
              'id': 'cust_01',
              'name': 'Pooja Verma',
              'phone': '+919876543210',
              'totalSpend': 2450.0,
              'loyaltyPoints': 240,
            }
          ];
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' && request.url.path.contains('/customers')) {
          final created = {
            'id': 'cust_02',
            'name': 'Sunil Joshi',
            'phone': '+919876599999',
            'totalSpend': 0.0,
            'loyaltyPoints': 0,
          };
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': created}))),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'DELETE' && request.url.path.contains('/customers/cust_01')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'message': 'Removed'}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.StreamedResponse(Stream.value([]), 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerRepository(apiClient: apiClient);
      final controller = CustomerController(customerRepository: repo);

      await controller.loadCustomers();
      expect(controller.customers.length, equals(1));
      expect(controller.customers.first.name, equals('Pooja Verma'));

      final added = await controller.createCustomer(
        name: 'Sunil Joshi',
        phone: '+919876599999',
      );
      expect(added, isTrue);
      expect(controller.customers.length, equals(2));

      final deleted = await controller.deleteCustomer('cust_01');
      expect(deleted, isTrue);
      expect(controller.customers.length, equals(1));
    });

    testWidgets('CustomersScreen renders customer list & stats', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        final data = [
          {
            'id': 'cust_01',
            'name': 'Rajesh Gupta',
            'phone': '+919811122233',
            'totalSpend': 5800.0,
            'loyaltyPoints': 580,
          }
        ];
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CustomerRepository(apiClient: apiClient);
      final controller = CustomerController(customerRepository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<CustomerController>.value(
          value: controller,
          child: const MaterialApp(
            home: CustomersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Customer Directory'), findsOneWidget);
      expect(find.text('Rajesh Gupta'), findsOneWidget);
      expect(find.text('₹5800'), findsOneWidget);
      expect(find.text('580 pts'), findsOneWidget);
    });
  });

  // =========================================================================
  // MODULE 4: INVENTORY
  // =========================================================================
  group('Phase 4: Inventory Module Tests', () {
    test('InventoryController loads inventory and processes stock adjustment', () async {
      int dynamicStock = 8;
      final mockClient = MockHttpClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('/inventory/summary')) {
          final summary = {
            'totalProducts': 12,
            'totalStockUnits': 450,
            'lowStockCount': 2,
            'outOfStockCount': 1,
            'inventoryValuation': 45000.0,
          };
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': summary}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' && request.url.path.contains('/inventory/items')) {
          final items = [
            {
              'productId': 'prod_inv_01',
              'name': 'Tata Tea Gold 500g',
              'category': 'Beverages',
              'currentStock': dynamicStock,
              'minStockThreshold': 10,
              'unit': 'packs',
              'costPrice': 240.0,
              'valuation': dynamicStock * 240.0,
              'stockStatus': dynamicStock < 10 ? 'LOW_STOCK' : 'IN_STOCK',
            }
          ];
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': items}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' && request.url.path.contains('/inventory/adjust')) {
          dynamicStock = 18;
          final result = {
            'productId': 'prod_inv_01',
            'previousStock': 8,
            'newStock': 18,
            'adjustment': 10,
            'type': 'RESTOCK',
            'reason': 'Shipment arrived',
          };
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': result}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' && request.url.path.contains('/inventory/movements')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': <Map<String, dynamic>>[]}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.StreamedResponse(Stream.value([]), 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = InventoryRepository(apiClient: apiClient);
      final controller = InventoryController(inventoryRepository: repo);

      await controller.loadInventory();
      expect(controller.summary.totalProducts, equals(12));
      expect(controller.items.length, equals(1));
      expect(controller.items.first.currentStock, equals(8));

      final adjusted = await controller.adjustStock(
        productId: 'prod_inv_01',
        type: 'RESTOCK',
        quantity: 10,
        reason: 'Shipment arrived',
      );

      expect(adjusted, isTrue);
      expect(controller.items.first.currentStock, equals(18));
      expect(controller.items.first.isLowStock, isFalse);
    });

    testWidgets('InventoryScreen renders KPI cards and items list', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        if (request.url.path.contains('/inventory/summary')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({
              'success': true,
              'data': {
                'totalProducts': 25,
                'totalStockUnits': 850,
                'lowStockCount': 3,
                'outOfStockCount': 0,
                'inventoryValuation': 75000.0,
              }
            }))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({
            'success': true,
            'data': [
              {
                'productId': 'p1',
                'name': 'Aashirvaad Atta 10kg',
                'category': 'Grains',
                'currentStock': 20,
                'minStockThreshold': 5,
                'unit': 'bags',
                'costPrice': 420.0,
                'valuation': 8400.0,
                'stockStatus': 'IN_STOCK',
              }
            ]
          }))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = InventoryRepository(apiClient: apiClient);
      final controller = InventoryController(inventoryRepository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<InventoryController>.value(
          value: controller,
          child: const MaterialApp(
            home: InventoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Inventory Management'), findsOneWidget);
      expect(find.text('Aashirvaad Atta 10kg'), findsOneWidget);
      expect(find.text('20 bags'), findsOneWidget);
      expect(find.text('₹8400'), findsOneWidget);
    });
  });

  // =========================================================================
  // MODULE 5: ORDERS & CONSISTENCY (STOCK DEDUCTION & RESTOCK)
  // =========================================================================
  group('Phase 4: Orders & Inventory Consistency Tests', () {
    test('OrderController creates order and cancels with stock restock', () async {
      final mockClient = MockHttpClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('/orders')) {
          final data = [
            {
              'id': 'ord_01',
              'orderNumber': 'ORD-1001',
              'customerId': 'cust_01',
              'customerName': 'Vikas Patel',
              'customerPhone': '+919988776655',
              'totalAmount': 900.0,
              'subtotal': 900.0,
              'discount': 0.0,
              'tax': 0.0,
              'orderStatus': 'COMPLETED',
              'paymentMethod': 'UPI',
              'items': [
                {
                  'productId': 'prod_01',
                  'productName': 'Basmati Rice 5kg',
                  'quantity': 2,
                  'unitPrice': 450.0,
                  'lineTotal': 900.0,
                }
              ],
            }
          ];
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' && request.url.path.contains('/orders/ord_01/cancel')) {
          final cancelledOrder = {
            'id': 'ord_01',
            'orderNumber': 'ORD-1001',
            'customerName': 'Vikas Patel',
            'totalAmount': 900.0,
            'subtotal': 900.0,
            'orderStatus': 'CANCELLED',
            'paymentMethod': 'UPI',
            'items': [
              {
                'productId': 'prod_01',
                'productName': 'Basmati Rice 5kg',
                'quantity': 2,
                'unitPrice': 450.0,
                'lineTotal': 900.0,
              }
            ],
          };
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({
              'success': true,
              'message': 'Order cancelled and stock restocked',
              'data': cancelledOrder,
            }))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.StreamedResponse(Stream.value([]), 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = OrderRepository(apiClient: apiClient);
      final controller = OrderController(orderRepository: repo);

      await controller.loadOrders();
      expect(controller.orders.length, equals(1));
      expect(controller.orders.first.orderStatus, equals('COMPLETED'));

      final cancelSuccess = await controller.cancelOrder('ord_01');
      expect(cancelSuccess, isTrue);
      expect(controller.orders.first.orderStatus, equals('CANCELLED'));
      expect(controller.orders.first.status, equals(OrderStatus.cancelled));
    });

    testWidgets('OrdersScreen renders order card and shows details modal on tap', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        final data = [
          {
            'id': 'ord_88',
            'orderNumber': 'ORD-8888',
            'customerName': 'Meena Kumari',
            'customerPhone': '+919876541234',
            'totalAmount': 650.0,
            'subtotal': 650.0,
            'discount': 0.0,
            'tax': 0.0,
            'orderStatus': 'COMPLETED',
            'paymentMethod': 'CASH',
            'items': [
              {
                'productId': 'p1',
                'productName': 'Sugar 5kg',
                'quantity': 1,
                'unitPrice': 220.0,
                'lineTotal': 220.0,
              },
              {
                'productId': 'p2',
                'productName': 'Wheat Flour 10kg',
                'quantity': 1,
                'unitPrice': 430.0,
                'lineTotal': 430.0,
              }
            ],
          }
        ];
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'success': true, 'data': data}))),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = OrderRepository(apiClient: apiClient);
      final controller = OrderController(orderRepository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<OrderController>.value(
          value: controller,
          child: const MaterialApp(
            home: OrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('#ORD-8888'), findsOneWidget);
      expect(find.text('Meena Kumari'), findsOneWidget);
      expect(find.text('₹650'), findsOneWidget);

      // Tap card to open modal sheet
      await tester.tap(find.text('Meena Kumari'));
      await tester.pumpAndSettle();

      expect(find.text('Order #ORD-8888'), findsOneWidget);
      expect(find.text('Sugar 5kg'), findsOneWidget);
      expect(find.text('Wheat Flour 10kg'), findsOneWidget);
      expect(find.text('Cancel Order'), findsOneWidget);
    });

    testWidgets('CreateOrderScreen allows selecting items and placing sales order', (tester) async {
      configureViewport(tester);

      final mockClient = MockHttpClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('/products')) {
          final products = [
            {
              'id': 'p1',
              'name': 'Daawat Rozana Basmati 5kg',
              'category': 'Rice',
              'costPrice': 320.0,
              'sellingPrice': 400.0,
              'currentStock': 25,
              'unit': 'bags',
              'status': 'ACTIVE',
            }
          ];
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': products}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' && request.url.path.contains('/customers')) {
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': <Map<String, dynamic>>[]}))),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' && request.url.path.contains('/orders')) {
          final newOrder = {
            'id': 'ord_new_01',
            'orderNumber': 'ORD-9999',
            'totalAmount': 400.0,
            'subtotal': 400.0,
            'discount': 0.0,
            'orderStatus': 'COMPLETED',
            'paymentMethod': 'UPI',
            'items': [
              {
                'productId': 'p1',
                'productName': 'Daawat Rozana Basmati 5kg',
                'quantity': 1,
                'unitPrice': 400.0,
                'lineTotal': 400.0,
              }
            ],
          };
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'success': true, 'data': newOrder}))),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.StreamedResponse(Stream.value([]), 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final productRepo = ProductRepository(apiClient: apiClient);
      final customerRepo = CustomerRepository(apiClient: apiClient);
      final orderRepo = OrderRepository(apiClient: apiClient);

      final productCtrl = ProductController(productRepository: productRepo);
      final customerCtrl = CustomerController(customerRepository: customerRepo);
      final orderCtrl = OrderController(orderRepository: orderRepo);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProductController>.value(value: productCtrl),
            ChangeNotifierProvider<CustomerController>.value(value: customerCtrl),
            ChangeNotifierProvider<OrderController>.value(value: orderCtrl),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('New Sales Order'), findsOneWidget);
      expect(find.text('Daawat Rozana Basmati 5kg'), findsOneWidget);

      // Add 1 quantity using the '+' icon button
      final addIcon = find.widgetWithIcon(IconButton, Icons.add_circle_outline);
      expect(addIcon, findsOneWidget);
      await tester.tap(addIcon);
      await tester.pumpAndSettle();

      expect(find.text('Subtotal: ₹400'), findsOneWidget);
      expect(find.text('Total: ₹400'), findsOneWidget);

      // Tap Complete Order
      final completeBtn = find.text('Complete Order');
      expect(completeBtn, findsOneWidget);
      await tester.tap(completeBtn);
      await tester.pumpAndSettle();

      // Order created in controller
      expect(orderCtrl.orders.length, equals(1));
      expect(orderCtrl.orders.first.orderNumber, equals('ORD-9999'));
    });
  });
}
