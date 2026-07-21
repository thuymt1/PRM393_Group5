# Hearth & Horizon

Ứng dụng đặt homestay Flutter sử dụng Supabase và Riverpod MVVM.

## Luồng đặt phòng, hủy và hoàn tiền

Ứng dụng dùng trực tiếp cột `bookings.status` hiện có trên Supabase, không yêu cầu migration bổ sung.

Luồng đặt phòng: Customer thanh toán → Admin hoặc Host xác nhận. Luồng hủy: Customer gửi yêu cầu → Admin xác nhận hoàn/hủy.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
