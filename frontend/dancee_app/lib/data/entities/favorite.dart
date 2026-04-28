import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  const Favorite({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.createdAt,
  });

  final int id;
  final String userId;
  final String itemType; // "event" or "course"
  final int itemId;
  final String? createdAt;

  factory Favorite.fromDirectus(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as int,
      userId: (json['user_id'] as String?) ?? '',
      itemType: (json['item_type'] as String?) ?? '',
      itemId: json['item_id'] as int,
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, userId, itemType, itemId, createdAt];
}
