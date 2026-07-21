import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/data/repositories/notification_repository.dart';
import '../lib/data/repositories/profile_repository.dart';
import '../lib/data/repositories/repository_providers.dart';
import '../lib/features/common/viewmodels/notification_view_model.dart';
import '../lib/features/common/viewmodels/profile_view_model.dart';

void main() {
  test(
    'NotificationViewModel loads items through an overridable repository',
    () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final items = await container.read(
        notificationViewModelProvider.future,
      );
      expect(items, hasLength(1));
      expect(items.first['title'], 'Test');
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

  @override
  Future<void> markAllRead() async {}
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
  }) async {}

  @override
  Future<Map<String, dynamic>?> getById(String id) async => null;

  @override
  Future<void> update({required String fullName, required String phone}) async {}

  @override
  Future<void> updateRole(String role) async {}

  @override
  Future<String> uploadAvatar({required Uint8List bytes, required String ext}) async => '';
}
