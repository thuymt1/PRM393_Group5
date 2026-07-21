import 'package:flutter_test/flutter_test.dart';
import 'package:test_screen_project/features/host/viewmodels/host_bookings_view_model.dart';
import 'package:test_screen_project/features/host/viewmodels/host_dashboard_view_model.dart';
import 'package:test_screen_project/features/host/viewmodels/host_homestays_view_model.dart';
import 'package:test_screen_project/models/homestay_model.dart';

void main() {
  test(
    'booking state filters cancellation statuses and sorts newest first',
    () {
      const state = HostBookingsState(statusFilter: 'cancel');
      final result = state.applyTo([
        _booking(id: 1, status: 'confirmed', createdAt: '2026-01-01'),
        _booking(id: 2, status: 'cancelled', createdAt: '2026-01-02'),
        _booking(id: 3, status: 'refunded', createdAt: '2026-01-03'),
      ]);

      expect(result.map((booking) => booking['id']), [3, 2]);
    },
  );

  test('booking state searches guest and homestay data', () {
    const state = HostBookingsState(query: 'nhà gỗ');
    final result = state.applyTo([
      _booking(
        id: 1,
        status: 'pending',
        createdAt: '2026-01-01',
        guest: 'An',
        homestay: 'Nhà Gỗ Đà Lạt',
      ),
      _booking(
        id: 2,
        status: 'pending',
        createdAt: '2026-01-02',
        guest: 'Bình',
        homestay: 'Biển Xanh',
      ),
    ]);

    expect(result.single['id'], 1);
  });

  test('homestay state filters active homes and sorts by low price', () {
    const state = HostHomestaysState(
      statusFilter: 'active',
      sort: HostHomestaySort.priceLow,
    );
    final result = state.applyTo([
      _homestay(id: 1, name: 'A', price: 1500000, status: 'active'),
      _homestay(id: 2, name: 'B', price: 900000, status: 'active'),
      _homestay(id: 3, name: 'C', price: 500000, status: 'hidden'),
    ]);

    expect(result.map((homestay) => homestay.id), [2, 1]);
  });

  test(
    'dashboard summary derives counts, earnings and highlighted booking',
    () {
      final dashboard = HostDashboardState(
        bookings: [
          _booking(
            id: 1,
            status: 'confirmed',
            createdAt: '2026-01-01',
            totalPrice: 1200000,
          ),
          _booking(id: 2, status: 'pending', createdAt: '2026-01-02'),
          _booking(id: 3, status: 'cancel_pending', createdAt: '2026-01-03'),
        ],
        homestays: const [],
        profile: null,
        accountEmail: 'host@example.com',
      );

      expect(dashboard.summary.totalConfirmedEarnings, 1200000);
      expect(dashboard.summary.confirmedBookings, 1);
      expect(dashboard.summary.pendingBookings, 1);
      expect(dashboard.summary.cancellationBookings, 1);
      expect(dashboard.summary.highlightedBooking['id'], 2);
    },
  );
}

Map<String, dynamic> _booking({
  required int id,
  required String status,
  required String createdAt,
  String guest = 'Khách hàng',
  String homestay = 'Homestay',
  double totalPrice = 0,
}) {
  return {
    'id': id,
    'status': status,
    'created_at': createdAt,
    'total_price': totalPrice,
    'profiles': {'full_name': guest, 'email': 'guest@example.com'},
    'homestays': {'name': homestay},
  };
}

Homestay _homestay({
  required int id,
  required String name,
  required double price,
  required String status,
}) {
  return Homestay(
    id: id,
    name: name,
    description: '',
    address: '123 Trần Phú',
    city: 'Đà Lạt',
    pricePerNight: price,
    rating: 0,
    images: const [],
    category: '',
    status: status,
    hostId: 'host-id',
  );
}
