# REFACTOR PLAN — homestay_booking_app (PRM393_Group5)
## Mục tiêu: chuyển từ kiến trúc "Flutter + Supabase-as-backend" sang mô hình
## hybrid giống dự án japanese-learning: Backend Java (Spring Boot) xử lý toàn
## bộ business logic + database riêng, Supabase chỉ giữ vai trò Auth (OAuth/OTP)
## và Storage (ảnh). Flutter refactor theo layer chuẩn (MVVM + Riverpod).

---

## 0. NGUYÊN TẮC LÀM VIỆC CHO AGENT

- KHÔNG big-bang: refactor từng module một, giữ app chạy được sau mỗi bước.
- Mỗi bước phải build/run thử (`flutter analyze`, `mvn compile`) trước khi sang bước kế.
- Giữ nguyên UI/UX hiện có, chỉ đổi tầng data/service/state management.
- Không tự ý xoá code cũ ngay — di chuyển vào `/legacy` hoặc comment tạm rồi xoá
  ở bước dọn dẹp cuối cùng, để dễ rollback.
- Sau mỗi module hoàn thành, viết tóm tắt: file nào thêm/sửa/xoá, rủi ro gì.
- Đặt tên package/namespace nhất quán với dự án japanese-learning để dễ đối chiếu.

---

## 1. PHẠM VI TRÁCH NHIỆM (RANH GIỚI KIẾN TRÚC)

| Thành phần        | Đơn vị đảm nhiệm                                   |
|-------------------|-----------------------------------------------------|
| Đăng nhập/Đăng ký, OAuth (Google/Facebook), OTP, quên mật khẩu | Supabase Auth (giữ nguyên SDK `supabase_flutter`) |
| Upload/lưu ảnh (avatar, ảnh homestay, ảnh bài viết) | Supabase Storage (giữ nguyên) |
| Toàn bộ business logic: Homestay, Booking, Review, Article, Profile nghiệp vụ (role, điểm, lịch sử) | Backend Java (Spring Boot) — MySQL/PostgreSQL riêng |
| Xác thực request tới Backend Java | Spring Security verify JWT do Supabase phát hành |

---

## 2. GIAI ĐOẠN A — DỰNG BACKEND JAVA MỚI (project: `homestay-backend`)

### A.1. Khởi tạo project
- Spring Boot 3.2.x, Java 17+, Maven.
- Dependencies: `spring-boot-starter-web`, `spring-boot-starter-data-jpa`,
  `mysql-connector-j` (hoặc `postgresql`), `spring-boot-starter-validation`,
  `spring-boot-starter-oauth2-resource-server`, `mapstruct` + `lombok`
  (tham khảo `pom.xml` của japanese-learning).

### A.2. Cấu trúc package (đối chiếu japanese-learning)
```
com.example.homestay
├── entity/
│   ├── account/      User, Profile (liên kết supabase_uid), UserRole
│   ├── homestay/     Homestay, HomestayImage, PriceRule, Amenity
│   ├── booking/      Booking, BookingStatus
│   ├── review/       Review
│   └── article/      Article, ArticleCategory
├── enums/            RoleType, BookingStatus, HomestayStatus...
├── dto/
│   ├── request/      HomestayRequest, BookingRequest, ReviewRequest...
│   └── response/     HomestayResponse, BookingResponse, ApiResponse<T>...
├── mapper/           HomestayMapping, BookingMapping... (MapStruct)
├── features/
│   ├── homestay/     HomestayController, HomestayService, HomestayRepository
│   ├── booking/      BookingController, BookingService, BookingRepository
│   ├── review/       ReviewController, ReviewService, ReviewRepository
│   ├── article/      ArticleController, ArticleService, ArticleRepository
│   └── profile/      ProfileController, ProfileService, ProfileRepository
├── security/
│   ├── SecurityConfig.java        (cấu hình oauth2ResourceServer)
│   ├── SupabaseJwtConverter.java  (map claims -> Authentication + role)
│   └── CurrentUserResolver.java   (lấy supabase_uid từ SecurityContext)
└── configuration/
    └── SupabaseProperties.java   (project-url, jwt-secret/jwks-uri, ...)
```

### A.3. Bảo mật — verify JWT của Supabase
- Cấu hình `application.yml`:
  ```yaml
  spring:
    security:
      oauth2:
        resourceserver:
          jwt:
            jwk-set-uri: https://<project-ref>.supabase.co/auth/v1/keys
            # hoặc dùng secret HS256 nếu project cấu hình kiểu cũ
  ```
- `SecurityConfig`: mọi endpoint `/api/**` yêu cầu Bearer token hợp lệ,
  trừ các endpoint public (GET danh sách homestay công khai nếu cần).
- Từ JWT lấy `sub` (= supabase user id) → dùng làm khoá tra `Profile` trong
  MySQL. Nếu chưa có record → tạo mới "lazy sync" (KHÔNG cần webhook ở bước đầu).
- Role (customer/host/author) lưu Ở PHÍA JAVA (bảng `profiles.role`), không
  lấy role từ Supabase, tránh 2 nguồn sự thật.

### A.4. Migrate dữ liệu
- Viết script export dữ liệu hiện có từ Supabase (bảng `profiles`, `homestay`,
  `homestay_images`, `booking`, `review`, `article`...) sang MySQL/Postgres mới.
- Giữ nguyên các cột ảnh dạng URL (vẫn trỏ về Supabase Storage).

### A.5. Test
- Viết test cơ bản cho mỗi Controller (happy path) bằng `spring-boot-starter-test`.
- Đảm bảo `mvn clean verify` pass trước khi bước sang Giai đoạn B.

---

## 3. GIAI ĐOẠN B — REFACTOR FLUTTER (thứ tự module: Article → Homestay → Booking → Auth)

### B.1. Thêm dependency
```yaml
flutter_riverpod: ^2.6.1
go_router: ^14.8.1
# giữ nguyên: supabase_flutter, image_picker, http
```

### B.2. Cấu trúc thư mục đích (đối chiếu japanese_learning_flutter)
```
lib/
├── data/
│   ├── models/         (giữ/điều chỉnh model hiện có theo response Java mới)
│   ├── repositories/    homestay_repository.dart, booking_repository.dart, ...
│   └── services/
│       ├── api_client.dart        <-- MỚI: base http client, tự đính JWT
│       ├── auth_service.dart      <-- giữ Supabase Auth (OAuth/OTP)
│       ├── storage_service.dart   <-- tách riêng phần Supabase Storage (ảnh)
│       ├── homestay_service.dart  <-- gọi Backend Java
│       ├── booking_service.dart   <-- gọi Backend Java
│       ├── review_service.dart    <-- gọi Backend Java
│       └── article_service.dart   <-- gọi Backend Java
├── providers/            auth_provider.dart, homestay_provider.dart, ...
├── routes/app_router.dart   (go_router, thay Navigator thủ công trong main.dart)
├── views/                (giữ cấu trúc theo role hiện có: customer/host/author/common)
└── widgets/
```

### B.3. `ApiClient` dùng chung (điểm mấu chốt nối JWT Supabase -> Backend Java)
```dart
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static String get baseUrl => /* giống ExamService.baseUrl ở dự án 1 */;

  Future<Map<String, String>> _authHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  Future<http.Response> get(String path, {Map<String,String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    return _client.get(uri, headers: await _authHeaders());
  }
  // post/put/delete tương tự...
}
```
- Mọi `xxx_service.dart` mới (homestay, booking, review, article) inject
  `ApiClient` này thay vì gọi `Supabase.instance.client.from(...)`.

### B.4. Tách AuthService / StorageService
- `AuthService`: CHỈ còn `signInWithOAuth()`, `signInWithOtp()`, `signOut()`,
  `authStateChanges`, `currentSession` — bỏ hết phần liên quan homestay/booking.
- `StorageService`: chuyển các hàm upload ảnh (avatar, ảnh homestay, ảnh bài
  viết) từ `api_service.dart` cũ sang đây, vẫn dùng `supabase_flutter` storage.

### B.5. Xoá dần `api_service.dart` cũ
- Theo từng module, cắt phần tương ứng ra khỏi `api_service.dart` (605 dòng)
  và thay bằng: `homestay_repository.dart` -> `homestay_service.dart` (gọi Java),
  cho tới khi `api_service.dart` chỉ còn (hoặc bị xoá hẳn, thay bằng
  auth_service.dart + storage_service.dart).

### B.6. Thêm Provider (Riverpod) cho từng feature
- Theo mẫu `exam_provider.dart`: tạo `XxxState` (data/isLoading/error) +
  `StateNotifier`/`AsyncNotifier` cho mỗi domain: `homestayProvider`,
  `bookingProvider`, `reviewProvider`, `articleProvider`, `authProvider`.
- Chuyển các màn hình từ `StatefulWidget` + `setState` sang
  `ConsumerWidget`/`ConsumerStatefulWidget` đọc state từ provider.

### B.7. Router tập trung
- Tạo `routes/app_router.dart` bằng `go_router`, định nghĩa route theo role
  (customer/*, host/*, author/*, common/*), thay thế import/Navigator thủ công
  trong `main.dart`.

### B.8. Model
- Điều chỉnh `fromJson` của `Homestay` và các model khác theo format response
  mới từ Backend Java (thường bọc trong `ApiResponse { data, message, ... }`
  giống `ExamResponse` bên dự án 1) thay vì format thô của Supabase.

---

## 4. THỨ TỰ THỰC THI ĐỀ XUẤT CHO AGENT

1. [Backend] Khởi tạo project Java, cấu hình SecurityConfig verify JWT Supabase.
2. [Backend] Module `article` (ít phụ thuộc nhất) — entity, dto, mapper, CRUD API.
3. [Flutter] Thêm `flutter_riverpod`, `go_router`; tạo `ApiClient`.
4. [Flutter] Refactor `author/*` screens theo pattern mới, trỏ qua `article_service.dart`.
5. Kiểm thử end-to-end module Article. Ghi chú vấn đề phát sinh.
6. Lặp lại bước 2-5 cho `homestay`, rồi `booking`, rồi `review`.
7. Cuối cùng: dọn `AuthService`/`StorageService`, xoá `api_service.dart` cũ,
   xoá code/tài nguyên không dùng, cập nhật README mô tả kiến trúc mới.

---

## 5. TIÊU CHÍ HOÀN THÀNH (Definition of Done)

- [ ] Backend Java chạy độc lập, có Swagger/OpenAPI mô tả API.
- [ ] Mọi API nghiệp vụ (homestay/booking/review/article) yêu cầu JWT hợp lệ.
- [ ] Flutter không còn gọi `supabase.from(...)` cho bảng nghiệp vụ, chỉ còn
      gọi Supabase cho `auth.*` và `storage.*`.
- [ ] Toàn bộ màn hình dùng Riverpod, không còn `setState` quản lý dữ liệu API.
- [ ] Điều hướng qua `go_router`, không còn import thủ công từng màn hình trong `main.dart`.
- [ ] `flutter analyze` và `mvn clean verify` đều pass.
- [ ] README cập nhật sơ đồ kiến trúc mới (Flutter <-> Supabase Auth/Storage,
      Flutter <-> Backend Java <-> MySQL).
