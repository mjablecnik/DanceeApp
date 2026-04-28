import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the application.
///
/// This is a placeholder entity for the auth feature.
/// Fields will be expanded when backend integration is implemented.
///
/// This is an immutable class that uses Equatable for value equality comparison.
class User extends Equatable {
  /// Unique identifier for the user
  final String id;

  /// The user's email address
  final String email;

  /// The user's display name
  final String displayName;

  /// Optional URL to the user's profile photo
  final String? photoUrl;

  /// Creates a User with all required fields and optional fields.
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  /// Creates a User from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Converts this User to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Creates a copy of this User with the given fields replaced with new values.
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
