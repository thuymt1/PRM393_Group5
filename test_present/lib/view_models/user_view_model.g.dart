// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRepositoryHash() => r'f57c5c0b9b0485125e28199e7485d48a63f8ef70';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
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
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$filteredUserListHash() => r'f9d7b56292e38a7cc4f7688fbb857ea9bd230d68';

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
String _$userListHash() => r'd16a21b5084e2536822813a2aade15e8e6462da3';

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
String _$userSearchQueryHash() => r'985b43515b5c25e26bccf12bbefde0e6d2941495';

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
