import '../../core/clients.dart';
import '../entities/favorite.dart';

class FavoritesRepository {
  FavoritesRepository({required DirectusClient client}) : _client = client;

  final DirectusClient _client;

  /// Lists all favorites for [userId].
  Future<List<Favorite>> getFavorites(String userId) async {
    final data = await _client.get(
      '/items/favorites',
      queryParameters: {
        'filter[user_id][_eq]': userId,
        'sort[]': '-created_at',
      },
    );

    final items = (data as List<dynamic>?) ?? [];
    return items
        .cast<Map<String, dynamic>>()
        .map(Favorite.fromDirectus)
        .toList();
  }

  /// Creates a favorite record. Returns the created record.
  Future<Favorite> addFavorite({
    required String userId,
    required String itemType,
    required int itemId,
  }) async {
    final data = await _client.post(
      '/items/favorites',
      data: {
        'user_id': userId,
        'item_type': itemType,
        'item_id': itemId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
    );

    return Favorite.fromDirectus(data as Map<String, dynamic>);
  }

  /// Deletes all favorites belonging to [userId]. Used during account deletion.
  /// Uses [Future.wait] to parallelize the individual delete calls.
  Future<void> deleteAllFavoritesForUser(String userId) async {
    final favorites = await getFavorites(userId);
    await Future.wait(
      favorites.map((fav) => _client.delete('/items/favorites/${fav.id}')),
    );
  }

  /// Deletes a favorite by matching userId + itemType + itemId.
  Future<void> removeFavorite({
    required String userId,
    required String itemType,
    required int itemId,
  }) async {
    // First find the favorite record matching these criteria
    final data = await _client.get(
      '/items/favorites',
      queryParameters: {
        'filter[user_id][_eq]': userId,
        'filter[item_type][_eq]': itemType,
        'filter[item_id][_eq]': itemId.toString(),
        'limit': '1',
      },
    );

    final items = (data as List<dynamic>?) ?? [];
    if (items.isEmpty) return;

    final favoriteId = (items.first as Map<String, dynamic>)['id'] as int;
    await _client.delete('/items/favorites/$favoriteId');
  }
}
