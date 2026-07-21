import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/host/viewmodels/host_dashboard_view_model.dart';
import '../../../../features/host/viewmodels/host_homestays_view_model.dart';
import '../host_dashboard_theme.dart';
import '../widgets/host_dashboard_common.dart';

class HostHomestaysTab extends ConsumerStatefulWidget {
  const HostHomestaysTab({super.key});

  @override
  ConsumerState<HostHomestaysTab> createState() => _HostHomestaysTabState();
}

class _HostHomestaysTabState extends ConsumerState<HostHomestaysTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(hostHomestaysViewModelProvider).query,
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

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(hostHomestaysViewModelProvider);
    final filterViewModel = ref.read(hostHomestaysViewModelProvider.notifier);

    return ref
        .watch(hostDashboardViewModelProvider)
        .when(
          loading: () => const HostLoadingState(),
          error: (error, _) => HostErrorState(error: error, onRetry: _refresh),
          data: (dashboard) {
            final homestays = dashboard.homestays;
            final visibleHomestays = filterState.applyTo(homestays);

            return Scaffold(
              backgroundColor: hostBackground,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Homestay của tôi',
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
                      _HomestayListTools(
                        controller: _searchController,
                        state: filterState,
                        visibleCount: visibleHomestays.length,
                        totalCount: homestays.length,
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
                          child: homestays.isEmpty
                              ? const _EmptyHomestaysList()
                              : visibleHomestays.isEmpty
                              ? HostNoSearchResults(
                                  message:
                                      'Không tìm thấy homestay phù hợp với điều kiện hiện tại.',
                                  onReset: () {
                                    _searchController.clear();
                                    filterViewModel.resetFilters();
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    96,
                                  ),
                                  itemCount: visibleHomestays.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: HostHomestayCard(
                                        homestay: visibleHomestays[index],
                                      ),
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

class _HomestayListTools extends StatelessWidget {
  const _HomestayListTools({
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
  final HostHomestaysState state;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<HostHomestaySort> onSortChanged;
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
            hint: 'Tìm tên, địa chỉ hoặc thành phố...',
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
                        label: 'Đang hoạt động',
                        selected: state.statusFilter == 'active',
                        onSelected: () => onStatusChanged('active'),
                      ),
                      HostFilterChoice(
                        label: 'Tạm ẩn',
                        selected: state.statusFilter == 'hidden',
                        onSelected: () => onStatusChanged('hidden'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HostSortButton<HostHomestaySort>(
                label: _sortLabel(state.sort),
                selected: state.sort,
                onSelected: onSortChanged,
                items: const [
                  PopupMenuItem(
                    value: HostHomestaySort.newest,
                    child: Text('Mới đăng'),
                  ),
                  PopupMenuItem(
                    value: HostHomestaySort.nameAsc,
                    child: Text('Tên A–Z'),
                  ),
                  PopupMenuItem(
                    value: HostHomestaySort.nameDesc,
                    child: Text('Tên Z–A'),
                  ),
                  PopupMenuItem(
                    value: HostHomestaySort.priceLow,
                    child: Text('Giá thấp đến cao'),
                  ),
                  PopupMenuItem(
                    value: HostHomestaySort.priceHigh,
                    child: Text('Giá cao đến thấp'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$visibleCount/$totalCount homestay',
            style: const TextStyle(color: Color(0xFF8C8079), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _sortLabel(HostHomestaySort sort) => switch (sort) {
    HostHomestaySort.newest => 'Mới nhất',
    HostHomestaySort.nameAsc => 'Tên A–Z',
    HostHomestaySort.nameDesc => 'Tên Z–A',
    HostHomestaySort.priceLow => 'Giá thấp',
    HostHomestaySort.priceHigh => 'Giá cao',
  };
}

class _EmptyHomestaysList extends StatelessWidget {
  const _EmptyHomestaysList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 68, 20, 20),
      children: [
        Icon(
          Icons.add_home_work_outlined,
          size: 64,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        const Text(
          'Bạn chưa đăng homestay nào.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF8C8079), fontSize: 15),
        ),
      ],
    );
  }
}
