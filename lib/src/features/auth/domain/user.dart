import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

/// User model representing an authenticated user.
///
/// Contains only essential user profile information for the auth domain.
/// Branch and other related data belong in their respective features.
/// Role permissions are managed by the user_roles feature.
@MappableClass()
class User with UserMappable {
  /// The user's unique ID.
  final String id;

  /// The user's display name.
  final String name;

  /// The user's userName for authentication.
  final String userName;

  /// The user's email address (optional).
  final String? email;

  /// The user's avatar URL (pre-computed).
  final String? avatarUrl;

  /// Whether the user's email has been verified.
  final bool verified;

  /// The user's branch ID (if assigned to a branch).
  final String? branch;

  const User({
    required this.id,
    required this.name,
    required this.userName,
    this.email,
    this.avatarUrl,
    this.verified = false,
    this.branch,
  });
}
