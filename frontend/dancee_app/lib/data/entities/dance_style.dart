import 'package:equatable/equatable.dart';

import 'translation_utils.dart';

class DanceStyle extends Equatable {
  const DanceStyle({
    required this.code,
    required this.name,
    this.parentCode,
    required this.sortOrder,
  });

  final String code;
  final String name;
  final String? parentCode;
  final int sortOrder;

  factory DanceStyle.fromDirectus(
    Map<String, dynamic> json, {
    required String languageCode,
  }) {
    final translations = (json['translations'] as List<dynamic>?) ?? [];
    final translation = extractTranslation(translations, languageCode);

    final name = (translation?['name'] as String?) ??
        (json['name'] as String?) ??
        '';

    return DanceStyle(
      code: (json['code'] as String?) ?? '',
      name: name,
      parentCode: json['parent_code'] as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [code, name, parentCode, sortOrder];
}

