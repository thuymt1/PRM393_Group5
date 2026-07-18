import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../models/homestay_model.dart';

class HostDashboardState {
  const HostDashboardState({
    required this.bookings,
    required this.homestays,
    required this.profile,
  });
  final List<dynamic> bookings;
  final List<Homestay> homestays;
  final Map<String, dynamic>? profile;
}

class HostDashboardViewModel extends AsyncNotifier<HostDashboardState> {
  @override
  Future<HostDashboardState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> updateBooking(int id, String status) async {
    await ref.read(bookingRepositoryProvider).updateStatus(id, status);
    await refresh();
  }

  Future<HostDashboardState> _load() async => HostDashboardState(
    bookings: await ref.read(bookingRepositoryProvider).getHostRequests(),
    homestays: await ref.read(homestayRepositoryProvider).getMine(),
    profile: await ref.read(profileRepositoryProvider).getMine(),
  );
}

final hostDashboardViewModelProvider =
    AsyncNotifierProvider<HostDashboardViewModel, HostDashboardState>(
      HostDashboardViewModel.new,
    );
