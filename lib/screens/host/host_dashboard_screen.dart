import 'package:flutter/material.dart';

import 'dashboard/host_dashboard_theme.dart';
import 'dashboard/tabs/host_bookings_tab.dart';
import 'dashboard/tabs/host_homestays_tab.dart';
import 'dashboard/tabs/host_overview_tab.dart';
import 'dashboard/tabs/host_profile_tab.dart';

/// Shell điều hướng cho khu vực quản lý của Host.
///
/// Dữ liệu và nghiệp vụ của từng tab được quản lý bởi ViewModel tương ứng;
/// màn hình này chỉ chịu trách nhiệm chọn tab và điều hướng sang luồng đăng tin.
class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hostBackground,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            HostOverviewTab(onSelectTab: _selectTab),
            const HostBookingsTab(),
            const HostHomestaysTab(),
            const HostProfileTab(),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add-homestay-basic-info'),
              backgroundColor: hostOrange,
              elevation: 2,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Đăng homestay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _HostBottomNavigation(
        currentIndex: _currentIndex,
        onChanged: _selectTab,
      ),
    );
  }
}

class _HostBottomNavigation extends StatelessWidget {
  const _HostBottomNavigation({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      selectedItemColor: hostOrange,
      unselectedItemColor: const Color(0xFF9C928C),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      currentIndex: currentIndex,
      onTap: onChanged,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Đơn đặt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_work_outlined),
          activeIcon: Icon(Icons.home_work),
          label: 'Chỗ nghỉ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}
