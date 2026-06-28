// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRepositoryHash() => r'775f0a0cbfe43fcc5b0fbeec8ecf75a7b4fd0859';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = Provider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = ProviderRef<UserRepository>;
String _$filteredUserListHash() => r'dffd1304b8c85cc6d60106f11be11a3d2f946a7b';

/// See also [filteredUserList].
@ProviderFor(filteredUserList)
final filteredUserListProvider = AutoDisposeFutureProvider<List<User>>.internal(
  filteredUserList,
  name: r'filteredUserListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredUserListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredUserListRef = AutoDisposeFutureProviderRef<List<User>>;
String _$userListHash() => r'fbcf9e29354a0ae743040f600348bcbf4c20809a';

/// See also [UserList].
@ProviderFor(UserList)
final userListProvider =
    AutoDisposeAsyncNotifierProvider<UserList, List<User>>.internal(
      UserList.new,
      name: r'userListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserList = AutoDisposeAsyncNotifier<List<User>>;
String _$userSearchQueryHash() => r'5a72ab948c7f8d7c4144e4bf8bcfcf156db929de';

/// See also [UserSearchQuery].
@ProviderFor(UserSearchQuery)
final userSearchQueryProvider =
    AutoDisposeNotifierProvider<UserSearchQuery, String>.internal(
      UserSearchQuery.new,
      name: r'userSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
