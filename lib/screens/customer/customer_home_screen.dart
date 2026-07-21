import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/customer/viewmodels/customer_home_view_model.dart';
import 'tabs/customer_bookings_tab.dart';
import 'tabs/customer_explore_tab.dart';
import 'tabs/customer_favorites_tab.dart';
import 'tabs/customer_profile_tab.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _currentIndex = 0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(
        () => ref.read(customerHomeViewModelProvider.notifier).refresh(),
      );
    }

    final List<Widget> tabs = const [
      CustomerExploreTab(),
      CustomerFavoritesTab(),
      CustomerBookingsTab(),
      CustomerProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE07A5F),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Khám phá',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Yêu thích',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Chuyến đi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}
