import 'package:equatable/equatable.dart';

// ─── DeviceInfoData ────────────────────────────────────────────────────────────

class DeviceInfoData extends Equatable {
  const DeviceInfoData({
    required this.appVersion,
    required this.device,
    required this.os,
  });

  final String appVersion;
  final String device;
  final String os;

  @override
  List<Object?> get props => [appVersion, device, os];
}

// ─── UserProfile ───────────────────────────────────────────────────────────────

class UserProfile extends Equatable {
  const UserProfile({
    required this.directusUserId,
    required this.firebaseUid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.city,
    this.bio,
    this.avatarUrl,
    required this.danceTags,
    required this.experienceLevel,
  });

  final String directusUserId;
  final String firebaseUid;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? city;
  final String? bio;
  final String? avatarUrl;
  final List<String> danceTags;
  final String experienceLevel;

  String get fullName => '$firstName $lastName'.trim();

  factory UserProfile.fromDirectus(
    Map<String, dynamic> json, {
    String directusBaseUrl = '',
  }) {
    // Avatar can be a UUID string or an expanded object with 'id'
    final rawAvatar = json['avatar'];
    final String? fileId;
    if (rawAvatar is Map<String, dynamic>) {
      fileId = rawAvatar['id']?.toString();
    } else if (rawAvatar != null) {
      fileId = rawAvatar.toString();
    } else {
      fileId = null;
    }
    final avatarUrl =
        (fileId != null && directusBaseUrl.isNotEmpty)
            ? '$directusBaseUrl/assets/$fileId'
            : null;

    final rawTags = json['dance_tags'];
    final List<String> danceTags;
    if (rawTags is List) {
      danceTags = rawTags.map((e) => e.toString()).toList();
    } else {
      danceTags = const [];
    }

    return UserProfile(
      directusUserId: (json['id'] ?? '').toString(),
      firebaseUid: (json['firebase_uid'] ?? '').toString(),
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: avatarUrl,
      danceTags: danceTags,
      experienceLevel: (json['experience_level'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toDirectus() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (city != null) 'city': city,
      if (bio != null) 'bio': bio,
      'dance_tags': danceTags,
      'experience_level': experienceLevel,
    };
  }

  @override
  List<Object?> get props => [
        directusUserId,
        firebaseUid,
        firstName,
        lastName,
        email,
        phone,
        city,
        bio,
        avatarUrl,
        danceTags,
        experienceLevel,
      ];
}
