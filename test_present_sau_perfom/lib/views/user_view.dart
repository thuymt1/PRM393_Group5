import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../view_models/user_view_model.dart';

class UserView extends ConsumerWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3.1: Lắng nghe danh sách đã lọc để tối ưu UI
    final userListAsync = ref.watch(filteredUserListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM High Performance CRUD'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) =>
                  ref.read(userSearchQueryProvider.notifier).updateQuery(value),
              decoration: InputDecoration(
                hintText: 'Search by name or email (100+ items)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: userListAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          // 3.2: ListView.builder xử lý cực tốt danh sách dài
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text(user.name[0])),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUserDialog(context, ref, user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref.read(userListProvider.notifier).deleteUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUserDialog(BuildContext context, WidgetRef ref, {User? user}) {
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Add New User' : 'Update User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (user == null) {
                ref.read(userListProvider.notifier).addUser(nameController.text, emailController.text);
              } else {
                ref.read(userListProvider.notifier).updateUser(
                      user.copyWith(name: nameController.text, email: emailController.text),
                    );
              }
              Navigator.pop(context);
            },
            child: Text(user == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
