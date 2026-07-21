import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../models/host_application_model.dart';

class AdminDashboardState {
  const AdminDashboardState({
    required this.stats,
    required this.applications,
    required this.homestays,
    required this.users,
    required this.bookings,
  });
  final Map<String, int> stats;
  final List<HostApplication> applications;
  final List<Map<String, dynamic>> homestays;
  final List<Map<String, dynamic>> users;
  final List<dynamic> bookings;
}

class AdminDashboardViewModel extends AsyncNotifier<AdminDashboardState> {
  bool _isRefreshing = false;

  @override
  Future<AdminDashboardState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> refreshBookings() async {
    final current = state.value;
    if (_isRefreshing || current == null) return;
    _isRefreshing = true;
    try {
      final bookings = await ref
          .read(bookingRepositoryProvider)
          .getAdminRequests();
      state = AsyncData(
        AdminDashboardState(
          stats: current.stats,
          applications: current.applications,
          homestays: current.homestays,
          users: current.users,
          bookings: bookings,
        ),
      );
    } catch (_) {
      // Giữ dữ liệu hiện tại; nút refresh đầy đủ vẫn hiển thị lỗi nếu cần.
    } finally {
      _isRefreshing = false;
    }
  }

  Future<AdminDashboardState> _load() async => AdminDashboardState(
    stats: await ref.read(adminRepositoryProvider).getStats(),
    applications: await ref.read(adminRepositoryProvider).getApplications(),
    homestays: await ref.read(adminRepositoryProvider).getHomestays(),
    users: await ref.read(adminRepositoryProvider).getUsers(),
    bookings: await ref.read(bookingRepositoryProvider).getAdminRequests(),
  );
}

final adminDashboardViewModelProvider =
    AsyncNotifierProvider<AdminDashboardViewModel, AdminDashboardState>(
      AdminDashboardViewModel.new,
    );
