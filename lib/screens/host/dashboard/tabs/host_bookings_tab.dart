import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/host/viewmodels/host_bookings_view_model.dart';
import '../../../../features/host/viewmodels/host_dashboard_view_model.dart';
import '../host_dashboard_theme.dart';
import '../widgets/host_dashboard_common.dart';

class HostBookingsTab extends ConsumerStatefulWidget {
  const HostBookingsTab({super.key});

  @override
  ConsumerState<HostBookingsTab> createState() => _HostBookingsTabState();
}

class _HostBookingsTabState extends ConsumerState<HostBookingsTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(hostBookingsViewModelProvider).query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    return ref.read(hostDashboardViewModelProvider.notifier).refresh();
  }

  Future<void> _openBooking(Map<String, dynamic> booking) async {
    final result = await Navigator.pushNamed(
      context,
      '/host-booking-detail',
      arguments: booking,
    );
    if (result == true) await _refresh();
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    try {
      await ref
          .read(hostBookingsViewModelProvider.notifier)
          .updateBooking(bookingId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'confirmed'
                ? 'Đã xác nhận đơn đặt phòng.'
                : 'Đã từ chối đơn đặt phòng.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(hostBookingsViewModelProvider);
    final filterViewModel = ref.read(hostBookingsViewModelProvider.notifier);

    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: () => const HostLoadingState(),
          error: (error, _) => HostErrorState(error: error, onRetry: _refresh),
          data: (dashboard) {
            final bookings = dashboard.bookings;
            final visibleBookings = filterState.applyTo(bookings);

            return Scaffold(
              backgroundColor: hostBackground,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Đơn đặt phòng',
                  style: TextStyle(
                    color: hostBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    children: [
                      _BookingListTools(
                        controller: _searchController,
                        state: filterState,
                        visibleCount: visibleBookings.length,
                        totalCount: bookings.length,
                        onQueryChanged: filterViewModel.setQuery,
                        onStatusChanged: filterViewModel.setStatusFilter,
                        onSortChanged: filterViewModel.setSort,
                        onClearQuery: () {
                          _searchController.clear();
                          filterViewModel.setQuery('');
                        },
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          color: hostOrange,
                          child: bookings.isEmpty
                              ? const _EmptyBookingsList()
                              : visibleBookings.isEmpty
                              ? HostNoSearchResults(
                                  message:
                                      'Không tìm thấy đơn phù hợp với điều kiện hiện tại.',
                                  onReset: () {
                                    _searchController.clear();
                                    filterViewModel.resetFilters();
                                  },
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    96,
                                  ),
                                  itemCount: visibleBookings.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final booking = visibleBookings[index];
                                    final bookingId = int.tryParse(
                                      booking['id']?.toString() ?? '',
                                    );
                                    return HostBookingCard(
                                      booking: booking,
                                      isUpdating:
                                          bookingId != null &&
                                          filterState.updatingIds.contains(
                                            bookingId,
                                          ),
                                      onOpen: () => _openBooking(booking),
                                      onUpdateStatus: _updateStatus,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }
}

class _BookingListTools extends StatelessWidget {
  const _BookingListTools({
    required this.controller,
    required this.state,
    required this.visibleCount,
    required this.totalCount,
    required this.onQueryChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onClearQuery,
  });

  final TextEditingController controller;
  final HostBookingsState state;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<HostBookingSort> onSortChanged;
  final VoidCallback onClearQuery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HostListSearch(
            controller: controller,
            hint: 'Tìm khách, homestay hoặc mã đơn...',
            onChanged: onQueryChanged,
            onClear: onClearQuery,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      HostFilterChoice(
                        label: 'Tất cả',
                        selected: state.statusFilter == 'all',
                        onSelected: () => onStatusChanged('all'),
                      ),
                      HostFilterChoice(
                        label: 'Chờ duyệt',
                        selected: state.statusFilter == 'pending',
                        onSelected: () => onStatusChanged('pending'),
                      ),
                      HostFilterChoice(
                        label: 'Đã xác nhận',
                        selected: state.statusFilter == 'confirmed',
                        onSelected: () => onStatusChanged('confirmed'),
                      ),
                      HostFilterChoice(
                        label: 'Hủy/hoàn tiền',
                        selected: state.statusFilter == 'cancel',
                        onSelected: () => onStatusChanged('cancel'),
                      ),
                      HostFilterChoice(
                        label: 'Đã từ chối',
                        selected: state.statusFilter == 'rejected',
                        onSelected: () => onStatusChanged('rejected'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HostSortButton<HostBookingSort>(
                label: _sortLabel(state.sort),
                selected: state.sort,
                onSelected: onSortChanged,
                items: const [
                  PopupMenuItem(
                    value: HostBookingSort.newest,
                    child: Text('Mới nhất'),
                  ),
                  PopupMenuItem(
                    value: HostBookingSort.oldest,
                    child: Text('Cũ nhất'),
                  ),
                  PopupMenuItem(
                    value: HostBookingSort.guestName,
                    child: Text('Tên khách A–Z'),
                  ),
                  PopupMenuItem(
                    value: HostBookingSort.priceHigh,
                    child: Text('Giá cao nhất'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$visibleCount/$totalCount đơn đặt phòng',
            style: const TextStyle(color: Color(0xFF8C8079), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _sortLabel(HostBookingSort sort) => switch (sort) {
    HostBookingSort.newest => 'Mới nhất',
    HostBookingSort.oldest => 'Cũ nhất',
    HostBookingSort.guestName => 'Tên A–Z',
    HostBookingSort.priceHigh => 'Giá cao',
  };
}

class _EmptyBookingsList extends StatelessWidget {
  const _EmptyBookingsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
      children: [
        Icon(Icons.event_note_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          'Chưa nhận được yêu cầu nào.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF8C8079), fontSize: 15),
        ),
      ],
    );
  }
}
