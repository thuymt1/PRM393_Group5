# Cấu trúc dự án Hearth & Horizon

## 1. Tổng quan

Dự án sử dụng Flutter, Supabase và Riverpod, được tổ chức theo mô hình MVVM (Model–View–ViewModel).

Mục tiêu của cấu trúc này là:

- Tách giao diện khỏi nghiệp vụ và truy cập dữ liệu.
- Giảm việc gọi Supabase trực tiếp trong Widget.
- Quản lý trạng thái bất đồng bộ thống nhất bằng Riverpod.
- Giúp từng chức năng dễ kiểm thử, bảo trì và mở rộng.

Luồng phụ thuộc chính:

```text
View → ViewModel → Repository → Data source → Supabase
View ← AsyncValue/State ← ViewModel
```

## 2. Cấu trúc thư mục mục tiêu

```text
lib/
├── main.dart
├── core/
│   ├── errors/
│   ├── providers/
│   ├── routing/
│   └── utils/
├── data/
│   ├── datasources/
│   └── repositories/
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   ├── customer/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   ├── host/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   ├── author/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   ├── admin/
│   │   ├── models/
│   │   ├── viewmodels/
│   │   └── views/
│   └── common/
│       ├── models/
│       ├── viewmodels/
│       └── views/
└── shared/
    ├── theme/
    └── widgets/
```

Trong thời gian chuyển đổi, các thư mục cũ như `screens/`, `services/`, `models/`, `utils/` và `widgets/` vẫn có thể tồn tại. Chúng sẽ được di chuyển dần sang cấu trúc mục tiêu, không nên xóa trước khi mọi tham chiếu đã được thay thế.

## 3. Trách nhiệm của từng tầng

### `core/`

Chứa hạ tầng và thành phần dùng chung toàn ứng dụng:

- `errors/`: exception và cách chuẩn hóa lỗi.
- `providers/`: provider nền tảng, ví dụ `supabaseClientProvider`.
- `routing/`: route name và cấu hình điều hướng.
- `utils/`: validator, formatter và helper không thuộc riêng feature nào.

`core` không được phụ thuộc vào View hoặc một feature cụ thể.

### `data/datasources/`

Là nơi giao tiếp trực tiếp với Supabase hoặc API bên ngoài:

- Thực hiện query, insert, update, upload file và xác thực.
- Chuyển lỗi kỹ thuật thành lỗi có thể xử lý ở tầng repository.
- Không chứa `BuildContext`, Navigator, Snackbar hoặc trạng thái giao diện.

### `data/repositories/`

Cung cấp API dữ liệu cho ViewModel. Các repository chính gồm:

- `AuthRepository`
- `ProfileRepository`
- `HomestayRepository`
- `BookingRepository`
- `ArticleRepository`
- `HostApplicationRepository`
- `NotificationRepository`
- `AdminRepository`

Mỗi repository nên có interface và implementation Supabase riêng. Provider của repository được khai báo trong `repository_providers.dart` để có thể override bằng fake khi kiểm thử.

### `features/<feature>/models/`

Chứa model và state chỉ thuộc một feature, ví dụ:

- `LoginFormState`
- `CustomerHomeState`
- `BookingState`
- `HostDashboardState`

Model dùng chung cho nhiều feature có thể đặt trong `features/common/models/` hoặc một thư mục model dùng chung phù hợp.

### `features/<feature>/viewmodels/`

ViewModel là cầu nối giữa View và Repository:

- Nhận thao tác từ người dùng.
- Gọi repository.
- Quản lý loading, data và error.
- Cung cấp state bất biến cho View.
- Dùng `Notifier`, `AsyncNotifier` hoặc provider phù hợp của Riverpod.

ViewModel không được:

- Nhận hoặc lưu `BuildContext`.
- Gọi Navigator.
- Hiển thị Dialog, Snackbar hoặc Widget.
- Truy cập trực tiếp các controller của giao diện.

### `features/<feature>/views/`

Chứa màn hình và Widget của feature:

- Dùng `ConsumerWidget` hoặc `ConsumerStatefulWidget`.
- Theo dõi state bằng `ref.watch`.
- Gọi hành động bằng `ref.read(provider.notifier)`.
- Hiển thị loading, dữ liệu và lỗi từ ViewModel.
- Thực hiện điều hướng hoặc hiển thị thông báo dựa trên kết quả hành động.

`setState` chỉ nên dùng cho trạng thái giao diện cục bộ như:

- Ẩn/hiện mật khẩu.
- Tab hoặc animation controller.
- Focus và trạng thái mở/đóng tạm thời.

Không dùng `setState` để quản lý dữ liệu lấy từ Supabase hoặc trạng thái nghiệp vụ.

### `shared/`

Chứa thành phần giao diện dùng lại ở nhiều feature:

- Theme, màu sắc và typography.
- Button, card, loading indicator và empty state dùng chung.
- Không chứa nghiệp vụ riêng của Customer, Host, Author hoặc Admin.

## 4. Quy tắc Riverpod

Ví dụ khai báo repository provider:

```dart
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);
```

Ví dụ ViewModel:

```dart
class AuthViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}
```

Ví dụ View sử dụng ViewModel:

```dart
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return ElevatedButton(
      onPressed: authState.isLoading
          ? null
          : () => ref.read(authViewModelProvider.notifier).login(),
      child: authState.isLoading
          ? const CircularProgressIndicator()
          : const Text('Đăng nhập'),
    );
  }
}
```

## 5. Quy tắc đặt tên

| Thành phần | Quy tắc | Ví dụ |
|---|---|---|
| File | `snake_case.dart` | `auth_view_model.dart` |
| Model | Danh từ | `Homestay`, `Booking` |
| View | Hậu tố `Screen`, `Page` hoặc `View` | `LoginScreen` |
| ViewModel | Hậu tố `ViewModel` | `AuthViewModel` |
| Repository interface | Hậu tố `Repository` | `BookingRepository` |
| Implementation | Tiền tố nguồn dữ liệu | `SupabaseBookingRepository` |
| Riverpod provider | Hậu tố `Provider` | `bookingViewModelProvider` |

## 6. Quy trình thêm chức năng mới

Ví dụ khi thêm chức năng quản lý yêu thích:

1. Tạo hoặc cập nhật model liên quan.
2. Khai báo phương thức trong `HomestayRepository`.
3. Cài đặt query Supabase trong data source/repository implementation.
4. Tạo state và ViewModel cho chức năng yêu thích.
5. Tạo hoặc cập nhật View để theo dõi ViewModel.
6. Viết unit test cho repository và ViewModel.
7. Viết widget test cho hành vi chính của giao diện.
8. Chạy `flutter analyze` và `flutter test`.

## 7. Nguyên tắc kiểm thử

- Repository được kiểm thử với data source giả hoặc môi trường test riêng.
- ViewModel được kiểm thử bằng `ProviderContainer` và provider override.
- Widget test không kết nối trực tiếp Supabase; repository phải được override bằng fake.
- Mỗi luồng cần kiểm tra tối thiểu: loading, thành công, dữ liệu rỗng và lỗi.

## 8. Trạng thái chuyển đổi hiện tại

Phần Auth đã bắt đầu sử dụng MVVM và Riverpod, gồm provider Supabase, repository Auth/Profile/HostApplication và `AuthViewModel`.

Các màn Customer, Host, Author, Admin và Common vẫn còn một số chỗ gọi `ApiService`, `Supabase.instance`, `FutureBuilder` hoặc quản lý business state bằng `setState`. Các phần này cần tiếp tục được chuyển theo thứ tự:

1. Auth và Profile.
2. Customer và Booking.
3. Host và Homestay.
4. Author và Article.
5. Admin, Notification và các màn Common.

Chỉ xóa `services/api_service.dart` sau khi không còn file nào tham chiếu đến service này và toàn bộ kiểm thử đã thành công.
