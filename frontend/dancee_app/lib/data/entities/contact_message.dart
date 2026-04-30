import 'dart:convert';

import 'user_profile.dart';

enum ContactMessageType { bug, feature, feedback, other }

class ContactMessage {
  const ContactMessage({
    required this.type,
    required this.title,
    required this.body,
    required this.replyEmail,
    this.phone,
    required this.deviceInfo,
    required this.firebaseUid,
  });

  final ContactMessageType type;
  final String title;
  final String body;
  final String replyEmail;
  final String? phone;
  final DeviceInfoData deviceInfo;
  final String firebaseUid;

  Map<String, dynamic> toDirectus() {
    return {
      'type': type.name,
      'title': title,
      'message': body,
      'reply_email': replyEmail,
      if (phone != null) 'phone': phone,
      'device_info': jsonEncode({
        'app_version': deviceInfo.appVersion,
        'device_model': deviceInfo.device,
        'os_version': deviceInfo.os,
        'firebase_uid': firebaseUid,
      }),
    };
  }
}
