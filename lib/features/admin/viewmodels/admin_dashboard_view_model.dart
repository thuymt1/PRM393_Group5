import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../models/host_application_model.dart';

class AdminDashboardState {
  const AdminDashboardState({
    required this.stats,
    required this.applications,
    required this.homestays,
    required this.users,
  });
  final Map<String, int> stats;
  final List<HostApplication> applications;
  final List<Map<String, dynamic>> homestays;
  final List<Map<String, dynamic>> users;
}

class AdminDashboardViewModel extends AsyncNotifier<AdminDashboardState> {
  @override
  Future<AdminDashboardState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<AdminDashboardState> _load() async => AdminDashboardState(
    stats: await ref.read(adminRepositoryProvider).getStats(),
    applications: await ref.read(adminRepositoryProvider).getApplications(),
    homestays: await ref.read(adminRepositoryProvider).getHomestays(),
    users: await ref.read(adminRepositoryProvider).getUsers(),
  );
}

final adminDashboardViewModelProvider =
    AsyncNotifierProvider<AdminDashboardViewModel, AdminDashboardState>(
      AdminDashboardViewModel.new,
    );
