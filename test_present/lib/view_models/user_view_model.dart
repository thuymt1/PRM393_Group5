import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

part 'user_view_model.g.dart';

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository();
}

@riverpod
class UserList extends _$UserList {
  @override
  FutureOr<List<User>> build() async {
    final repository = ref.watch(userRepositoryProvider);
    return repository.getUsers();
  }

  Future<void> addUser(String name, String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userRepositoryProvider);
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
      );
      await repository.addUser(newUser);
      return repository.getUsers();
    });
  }

  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userRepositoryProvider);
      await repository.updateUser(user);
      return repository.getUsers();
    });
  }

  Future<void> deleteUser(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userRepositoryProvider);
      await repository.deleteUser(id);
      return repository.getUsers();
    });
  }
}

@riverpod
class UserSearchQuery extends _$UserSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
FutureOr<List<User>> filteredUserList(FilteredUserListRef ref) async {
  // Lắng nghe danh sách gốc
  final userListAsync = ref.watch(userListProvider);
  // Lắng nghe từ khóa tìm kiếm và chuẩn hóa (bỏ khoảng cách, chữ thường)
  final query = ref.watch(userSearchQueryProvider).trim().toLowerCase();

  return userListAsync.when(
    data: (users) {
      if (query.isEmpty) return users;

      // Lọc: chỉ giữ lại những user mà Tên hoặc Email có chứa từ khóa
      return users.where((user) {
        final name = user.name.toLowerCase();
        final email = user.email.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    },
    // Nếu đang load danh sách gốc, đợi nó load xong
    loading: () => ref.watch(userListProvider.future),
    error: (err, stack) => Future.error(err, stack),
  );
}
