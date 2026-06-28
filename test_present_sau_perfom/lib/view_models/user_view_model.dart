import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

part 'user_view_model.g.dart';

// Bước 2.1: Giữ cho Repository luôn tồn tại trong bộ nhớ (Singleton-like)
@Riverpod(keepAlive: true)
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository();
}

// Bước 2.2: Quản lý danh sách User gốc và cập nhật State trực tiếp
@riverpod
class UserList extends _$UserList {
  @override
  FutureOr<List<User>> build() async {
    // Chỉ tải dữ liệu lần đầu tiên từ Repository
    final repository = ref.watch(userRepositoryProvider);
    return repository.getUsers();
  }

  Future<void> addUser(String name, String email) async {
    final repository = ref.read(userRepositoryProvider);
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );
    
    // Lưu vào Repository
    await repository.addUser(newUser);

    // TỐI ƯU HIỆU SUẤT: Cập nhật trực tiếp State hiện tại thay vì tải lại toàn bộ
    final previousState = state.valueOrNull ?? [];
    state = AsyncValue.data([...previousState, newUser]);
  }

  Future<void> updateUser(User updatedUser) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.updateUser(updatedUser);

    // Cập nhật trực tiếp vào State trong bộ nhớ
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final user in state.value!)
          if (user.id == updatedUser.id) updatedUser else user,
      ]);
    }
  }

  Future<void> deleteUser(String id) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.deleteUser(id);

    // Xóa trực tiếp khỏi State trong bộ nhớ
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final user in state.value!)
          if (user.id != id) user,
      ]);
    }
  }
}

// Bước 2.3: Logic tìm kiếm
@riverpod
class UserSearchQuery extends _$UserSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

// Bước 2.4: Tự động lọc danh sách dựa trên từ khóa (Tính toán lại ngay khi gõ)
@riverpod
FutureOr<List<User>> filteredUserList(FilteredUserListRef ref) {
  final usersAsync = ref.watch(userListProvider);
  final query = ref.watch(userSearchQueryProvider).trim().toLowerCase();

  // usersAsync.whenData trả về một AsyncValue, nhưng hàm này cần trả về FutureOr<List<User>>.
  // Chúng ta dùng .value (hoặc xử lý các trạng thái) để lấy dữ liệu thực tế.
  if (usersAsync is AsyncLoading) {
    // Trả về một Future không bao giờ hoàn thành hoặc xử lý tùy ý, 
    // nhưng cách tốt nhất là dùng .future của provider gốc
    return ref.watch(userListProvider.future);
  }

  final users = usersAsync.valueOrNull ?? [];
  if (query.isEmpty) return users;

  return users.where((user) {
    return user.name.toLowerCase().contains(query) ||
        user.email.toLowerCase().contains(query);
  }).toList();
}
