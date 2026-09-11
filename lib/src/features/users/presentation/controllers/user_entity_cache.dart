import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/user.dart';

part 'user_entity_cache.g.dart';

/// In-memory cache for single user entities.
///
/// Used to pre-cache newly created users to avoid race conditions
/// where the detail page loads before the network fetch completes.
@Riverpod(keepAlive: true)
class UserEntityCache extends _$UserEntityCache {
  @override
  Map<String, User> build() => {};

  /// Caches a user by ID.
  void cacheUser(User user) {
    state = {...state, user.id: user};
  }

  /// Gets a cached user by ID, if available.
  User? getUser(String id) => state[id];

  /// Clears all cached users (e.g. after organization switch).
  void clear() {
    state = {};
  }
}
