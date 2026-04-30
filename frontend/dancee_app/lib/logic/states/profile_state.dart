import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/entities/user_profile.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded({required UserProfile profile}) = _Loaded;
  const factory ProfileState.updating({required UserProfile profile}) =
      _Updating;
  const factory ProfileState.error({required String message}) = _Error;
}
