import '../models/user.dart';

class UserRepository {
  // 1. Khởi tạo 100 bản ghi mẫu ngay từ đầu để demo hiệu suất
  final List<User> _users = List.generate(
    100,
    (index) => User(
      id: index.toString(),
      name: 'User $index',
      email: 'user$index@example.com',
    ),
  );

  // 2. Lấy dữ liệu (Chỉ delay lần đầu giả lập tải từ server)
  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_users);
  }

  // 3. Các hàm CRUD cập nhật trực tiếp vào bộ nhớ (không delay để demo tốc độ)
  Future<void> addUser(User user) async {
    _users.add(user);
  }

  Future<void> updateUser(User user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((u) => u.id == id);
  }
}
