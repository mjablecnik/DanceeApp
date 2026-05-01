import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/entities/contact_message.dart';
import '../../data/repositories/profile_repository.dart';
import '../cubits/auth_cubit.dart';
import '../states/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository profileRepository,
    required AuthCubit authCubit,
  })  : _profileRepository = profileRepository,
        _authCubit = authCubit,
        super(const ProfileState.initial());

  final ProfileRepository _profileRepository;
  final AuthCubit _authCubit;

  /// Loads the profile for the currently authenticated user.
  Future<void> loadProfile() async {
    final uid = _authCubit.currentUid;
    if (uid == null) {
      emit(const ProfileState.error(message: 'profile.errors.notAuthenticated'));
      return;
    }
    emit(const ProfileState.loading());
    try {
      final profile = await _profileRepository.getUserProfile(uid);
      debugPrint('[ProfileCubit] Loaded profile: ${profile.fullName} (${profile.email})');
      emit(ProfileState.loaded(profile: profile));
    } catch (e) {
      debugPrint('[ProfileCubit] Failed to load profile: $e');
      emit(const ProfileState.error(message: 'profile.errors.loadFailed'));
    }
  }

  /// Updates the profile with [fields] and re-emits the loaded state.
  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final currentProfile = state.maybeMap(
      loaded: (s) => s.profile,
      updating: (s) => s.profile,
      orElse: () => null,
    );
    if (currentProfile == null) return;

    emit(ProfileState.updating(profile: currentProfile));
    try {
      final updated = await _profileRepository.updateUserProfile(
        currentProfile.directusUserId,
        fields,
      );
      emit(ProfileState.loaded(profile: updated));
    } catch (e) {
      emit(ProfileState.loaded(profile: currentProfile));
      rethrow;
    }
  }

  /// Submits a [ContactMessage] to the CMS. Returns true on success.
  Future<bool> submitContactMessage(ContactMessage message) async {
    try {
      await _profileRepository.submitContactMessage(message);
      return true;
    } catch (e) {
      return false;
    }
  }
}
