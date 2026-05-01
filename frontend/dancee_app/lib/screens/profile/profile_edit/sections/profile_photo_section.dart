import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../logic/cubits/profile_cubit.dart';
import '../../../../shared/components/app_cached_image.dart';

class ProfilePhotoSection extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final bool isUploading;

  const ProfilePhotoSection({
    super.key,
    required this.avatarUrl,
    this.name = '',
    this.isUploading = false,
  });

  @override
  State<ProfilePhotoSection> createState() => _ProfilePhotoSectionState();
}

class _ProfilePhotoSectionState extends State<ProfilePhotoSection> {
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _showSourceSelection() async {
    if (widget.isUploading) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    t.profile.editProfile.avatar.sourceTitle,
                    style: const TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: AppTypography.fontWeightSemiBold,
                    ),
                  ),
                ),
                const Divider(color: appBorder, height: 1),
                if (!kIsWeb) ...[
                  ListTile(
                    leading: const Icon(Icons.camera_alt, color: appPrimary),
                    title: Text(
                      t.profile.editProfile.avatar.takePhoto,
                      style: const TextStyle(color: appText),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSourceSelected(ImageSource.camera);
                    },
                  ),
                  const Divider(color: appBorder, height: 1, indent: 16, endIndent: 16),
                ],
                ListTile(
                  leading: const Icon(Icons.photo_library, color: appPrimary),
                  title: Text(
                    t.profile.editProfile.avatar.chooseFromGallery,
                    style: const TextStyle(color: appText),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleSourceSelected(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSourceSelected(ImageSource source) async {
    if (kIsWeb) {
      await _pickAndCropImage(source);
      return;
    }

    final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final granted = await _ensurePermission(permission);
    if (granted) {
      await _pickAndCropImage(source);
    }
  }

  /// Checks permission and handles denied/permanently denied states.
  /// Returns true if permission is granted and picker can proceed.
  Future<bool> _ensurePermission(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      await _showOpenSettingsDialog();
      return false;
    }

    // Show rationale dialog, then request permission if user taps "Allow"
    final shouldRequest = await _showRationaleDialog();
    if (!shouldRequest) return false;

    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      await _showOpenSettingsDialog();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.profile.editProfile.avatar.permissionRequired)),
        );
      }
    }
    return false;
  }

  Future<bool> _showRationaleDialog() async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: appSurface,
            title: Text(
              t.profile.editProfile.avatar.permissionDeniedTitle,
              style: const TextStyle(color: appText),
            ),
            content: Text(
              t.profile.editProfile.avatar.permissionRequired,
              style: const TextStyle(color: appMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.common.cancel, style: const TextStyle(color: appMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.common.allow, style: const TextStyle(color: appPrimary)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showOpenSettingsDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appSurface,
        title: Text(
          t.profile.editProfile.avatar.permissionDeniedTitle,
          style: const TextStyle(color: appText),
        ),
        content: Text(
          t.profile.editProfile.avatar.permissionDeniedMessage,
          style: const TextStyle(color: appMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.common.cancel, style: const TextStyle(color: appMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(
              t.profile.editProfile.avatar.openSettings,
              style: const TextStyle(color: appPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Picks and crops an image from the given [source], then uploads it.
  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: appPrimary,
            backgroundColor: appBg,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            aspectRatioLockEnabled: true,
          ),
          if (kIsWeb) WebUiSettings(context: context),
        ],
      );
      if (croppedFile == null) return;

      if (!mounted) return;
      await context.read<ProfileCubit>().uploadAvatar(croppedFile.path, pickedFile.name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.profile.editProfile.avatar.uploadError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: widget.isUploading ? null : _showSourceSelection,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(color: appPrimary, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          widget.avatarUrl.isNotEmpty
                              ? AppCachedImage(
                                  imageUrl: widget.avatarUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: appPrimary.withValues(alpha: 0.15),
                                  child: Center(
                                    child: Text(
                                      _initials(widget.name),
                                      style: const TextStyle(
                                        color: appPrimary,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                          if (widget.isUploading)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: appPrimary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!widget.isUploading)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showSourceSelection,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: appPrimary,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: appBg, width: 2),
                        ),
                        child: const Center(
                          child: FaIcon(FontAwesomeIcons.camera, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: widget.isUploading ? null : _showSourceSelection,
            child: Text(
              t.profile.editProfile.changePhoto,
              style: TextStyle(
                color: widget.isUploading ? appMuted : appPrimary,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
