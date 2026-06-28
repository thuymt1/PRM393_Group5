import '../models/user.dart';

class UserRepository {
  final List<User> _users = List.generate(
    100,
    (index) => User(
      id: index.toString(),
      name: 'User $index',
      email: 'user$index@example.com',
    ),
  );

  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_users);
  }

  Future<void> addUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.add(user);
  }

  Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.removeWhere((u) => u.id == id);
  }
}
