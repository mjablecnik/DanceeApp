import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_state.freezed.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = _Initial;
  const factory FavoritesState.loading() = _Loading;
  const factory FavoritesState.loaded({
    required Set<int> eventIds,
    required Set<int> courseIds,
  }) = _Loaded;
  const factory FavoritesState.error({required String message}) = _Error;
}
