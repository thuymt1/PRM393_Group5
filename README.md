# 🏡 Homestay Booking App

## 🌟 Tổng Quan Dự Án (Project Overview)


Chào mừng đến với hệ thống **Homestay Booking App** - nền tảng công nghệ toàn diện dành cho việc đặt phòng homestay, mang đến trải nghiệm tiện lợi, an toàn và chuyên nghiệp. Dự án được phát triển bởi Nhóm 5 môn học PRM393 nhằm mục đích giải quyết trọn vẹn nhu cầu kết nối giữa khách hàng có nhu cầu thuê chỗ ở (Customer) và những cá nhân/tổ chức cho thuê (Host), bên cạnh đó còn tích hợp các tiện ích quản lý và chia sẻ nội dung bài viết đánh giá.

### 🎯 Tầm nhìn & Mục tiêu
- **Trải nghiệm mượt mà:** Xây dựng ứng dụng di động tối ưu tốc độ, thân thiện và dễ sử dụng.
- **Vững chắc và Mở rộng:** Hệ thống backend mạnh mẽ, bảo mật cao và dễ dàng mở rộng để đáp ứng lượng lớn giao dịch trong tương lai.
- **Kiến trúc Hiện đại:** Phân tách rõ ràng giữa phân hệ quản lý danh tính (Identity) và logic nghiệp vụ cốt lõi (Business Logic).

### 🏗 Kiến trúc Hệ thống (Hybrid Architecture)
Hệ thống của chúng tôi tự hào sử dụng kiến trúc lai hiện đại, kết hợp sức mạnh của nhiều nền tảng công nghệ hàng đầu hiện nay:

1. **Frontend (Mobile App - Flutter):** 
   - Ứng dụng di động đa nền tảng được xây dựng bằng **Flutter**, mang lại trải nghiệm Native mượt mà cho cả iOS và Android.
   - Áp dụng cấu trúc **MVVM** kết hợp với **Riverpod** để quản lý trạng thái (State Management) chuyên nghiệp, giúp tối ưu hoá hiệu năng hiển thị màn hình, dễ dàng debug và bảo trì.
2. **Backend (Core Business - Java Spring Boot):** 
   - Đóng vai trò là bộ não của ứng dụng, xử lý 100% logic nghiệp vụ cốt lõi bao gồm: Quản lý Homestay, luồng Đặt phòng (Booking), Đánh giá (Review), Bài viết (Article), và Hồ sơ người dùng (Profile).
   - Thiết kế chuẩn RESTful API, được kết nối với hệ quản trị cơ sở dữ liệu mạnh mẽ **PostgreSQL**.
3. **Identity & Storage (Supabase):** 
   - Đảm nhận vai trò trọng yếu về mặt bảo mật thông qua **Supabase Auth** (Hỗ trợ Đăng nhập OAuth, OTP).
   - Quản lý kho lưu trữ phương tiện, hình ảnh qua **Supabase Storage** với độ trễ thấp và độ tin cậy cao.
   - **Bảo mật tối đa:** Spring Boot đóng vai trò xác thực (verify) JWT Token được phát hành bởi Supabase cho mọi request gửi tới server, đảm bảo tính bảo mật tuyệt đối.

---

## 🚀 Hướng Dẫn Khởi Chạy Dự Án (Getting Started)

Dự án được chia thành hai phân hệ chính: **Backend** (Java) và **Frontend** (Flutter). Dưới đây là các bước chi tiết để chạy dự án trên môi trường Local.

### 1️⃣ Khởi chạy Backend (Java Spring Boot)
**Yêu cầu hệ thống:**
- Java 17 hoặc mới hơn.
- Không cần cài đặt sẵn Gradle (dự án sử dụng Gradle Wrapper `gradlew` đi kèm).
- IDE (Khuyến nghị): IntelliJ IDEA, Eclipse, hoặc VS Code.

**Các bước thực hiện:**
1. **Mở thư mục Backend:** Mở Terminal/Command Prompt và di chuyển vào thư mục `backend`:
   ```bash
   cd backend
   ```
2. **Cấu hình Cơ sở dữ liệu (Database):** 
   - Hệ thống đã được thiết lập sẵn kết nối tới database PostgreSQL trên Supabase tại file `src/main/resources/application.properties`.
   - Các biến thiết yếu như `spring.datasource.url`, tài khoản và `supabase.jwt.secret` đã được thiết lập đầy đủ cho quá trình khởi chạy.
3. **Tải Dependencies & Build (Tùy chọn):**
   Sử dụng Gradle Wrapper để build dự án (bỏ qua test):
   ```bash
   .\gradlew build -x test
   ```
4. **Khởi động Server:**
   Chạy ứng dụng Spring Boot bằng lệnh sau:
   ```bash
   .\gradlew bootRun
   ```
   *(Server Backend sẽ khởi chạy và lắng nghe tại cổng `http://localhost:8080`)*

---

### 2️⃣ Khởi chạy Frontend (Flutter Mobile App)
**Yêu cầu hệ thống:**
- Flutter SDK (từ phiên bản `^3.11.5`).
- Android Studio / Xcode để chạy máy ảo (Emulator) hoặc thiết bị thật đã bật chế độ Developer.

**Các bước thực hiện:**
1. **Mở thư mục Frontend:** Di chuyển vào thư mục dự án Flutter `test_screen_project`:
   ```bash
   cd test_screen_project
   ```
2. **Cài đặt thư viện (Dependencies):**
   Tải toàn bộ các package được định nghĩa trong `pubspec.yaml` (bao gồm `flutter_riverpod`, `http`, `supabase_flutter`,...):
   ```bash
   flutter pub get
   ```
3. **Kết nối API Backend:**
   - Ứng dụng đã được tích hợp luồng gọi API thông qua lớp `ApiClient`.
   - **Lưu ý:** Nếu bạn chạy Frontend trên Android Emulator, bạn phải cấu hình `baseUrl` trong mã nguồn trỏ tới địa chỉ `http://10.0.2.2:8080/api` để kết nối được với Backend chạy trên máy tính. Nếu chạy thiết bị thật qua mạng LAN, vui lòng đổi `baseUrl` thành địa chỉ IPv4 của máy tính (VD: `http://192.168.1.x:8080/api`).
4. **Khởi chạy ứng dụng:**
   Mở máy ảo hoặc cắm thiết bị vào máy và chạy lệnh sau:
   ```bash
   flutter run
   ```
   *(Sau khi build xong, giao diện ứng dụng Homestay Booking sẽ xuất hiện trên màn hình thiết bị)*

