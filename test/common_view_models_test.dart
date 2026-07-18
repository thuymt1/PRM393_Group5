import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_screen_project/data/repositories/notification_repository.dart';
import 'package:test_screen_project/data/repositories/profile_repository.dart';
import 'package:test_screen_project/data/repositories/repository_providers.dart';
import 'package:test_screen_project/features/common/viewmodels/notification_view_model.dart';
import 'package:test_screen_project/features/common/viewmodels/profile_view_model.dart';

void main() {
  test(
    'NotificationViewModel loads and marks all notifications as read',
    () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifications = await container.read(
        notificationViewModelProvider.future,
      );
      expect(notifications.single['is_unread'], isTrue);

      container.read(notificationViewModelProvider.notifier).markAllRead();
      expect(
        container
            .read(notificationViewModelProvider)
            .value!
            .single['is_unread'],
        isFalse,
      );
    },
  );

  test(
    'ProfileViewModel loads profile through an overridable repository',
    () async {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final profile = await container.read(profileViewModelProvider.future);
      expect(profile?['full_name'], 'Test User');
    },
  );
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<List<Map<String, dynamic>>> getAll() async => [
    {'title': 'Test', 'is_unread': true},
  ];
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Map<String, dynamic>?> getMine() async => {'full_name': 'Test User'};

  @override
  Future<void> create({
    required String id,
    required String email,
    required String fullName,
    required String phone,
  }) => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>?> getById(String id) =>
      throw UnimplementedError();
  @override
  Future<void> update({required String fullName, required String phone}) =>
      throw UnimplementedError();
  @override
  Future<void> updateRole(String role) => throw UnimplementedError();
}
