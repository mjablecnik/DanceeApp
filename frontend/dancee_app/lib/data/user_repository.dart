import 'package:flutter/material.dart';
import '../core/colors.dart';

// ─── Model classes ───────────────────────────────────────────────────────────

class UserDanceTag {
  final String label;
  final Color color;

  const UserDanceTag({required this.label, required this.color});
}

class UserData {
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? bio;
  final String? avatarUrl;
  final List<UserDanceTag> danceTags;
  final String experienceLevel;
  final String? instagram;
  final String? facebook;

  const UserData({
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.bio,
    this.avatarUrl,
    required this.danceTags,
    required this.experienceLevel,
    this.instagram,
    this.facebook,
  });
}

class DeviceInfoData {
  final String appVersion;
  final String device;
  final String os;

  const DeviceInfoData({
    required this.appVersion,
    required this.device,
    required this.os,
  });
}

// ─── Repository ───────────────────────────────────────────────────────────────

class UserRepository {
  const UserRepository();

  Future<UserData> getCurrentUser() async {
    return const UserData(
      name: 'Tereza Nováková',
      email: 'tereza.novakova@email.cz',
      phone: '+420 777 123 456',
      city: 'Praha',
      bio: 'Tanečnice a milovnice latinskoamerických tanců. Tančím salsu a bachatu již 5 let.',
      avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
      danceTags: [
        UserDanceTag(label: 'Salsa', color: appPrimary),
        UserDanceTag(label: 'Bachata', color: appAccent),
        UserDanceTag(label: 'Zouk', color: appTeal),
      ],
      experienceLevel: 'Mírně pokročilý',
      instagram: '@tereza_dance',
      facebook: 'facebook.com/tereza.novakova',
    );
  }

  Future<String> getAppVersion() async {
    return '1.2.5 (Build 125)';
  }

  Future<DeviceInfoData> getDeviceInfo() async {
    return const DeviceInfoData(
      appVersion: 'Dancee v1.2.5',
      device: 'iPhone 14 Pro',
      os: 'iOS 17.2',
    );
  }
}
