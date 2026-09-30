import 'package:flutter/material.dart';
import '../../../shared/components/bottom_nav_bar.dart';
import '../../customers/presentation/customers_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../more/presentation/more_screen.dart';
import '../../orders/presentation/orders_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  const MainShellScreen({super.key, this.initialIndex = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    DashboardScreen(),
    OrdersScreen(),
    InventoryScreen(),
    CustomersScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NirmaanBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
