import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/colors.dart';
import '../../../../../core/service_locator.dart';
import '../../../../../core/theme.dart';
import '../../../../../data/entities/contact_message.dart';
import '../../../../../data/entities/user_profile.dart';
import '../../../../../data/repositories/profile_repository.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../../logic/cubits/auth_cubit.dart';
import '../../../../../logic/cubits/profile_cubit.dart';
import '../components/subject_option.dart';
import '../components/device_info_card.dart';

class ContactFormSection extends StatefulWidget {
  const ContactFormSection({super.key});

  @override
  State<ContactFormSection> createState() => _ContactFormSectionState();
}

class _ContactFormSectionState extends State<ContactFormSection> {
  String _selectedSubject = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late final Future<DeviceInfoData> _deviceInfoFuture =
      sl<ProfileRepository>().getDeviceInfo();

  bool _isLoading = false;
  bool _isSent = false;
  String? _errorMessage;

  String? _subjectError;
  String? _titleError;
  String? _messageError;
  String? _emailError;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Auto-fill email from AuthCubit
      final email = context.read<AuthCubit>().currentEmail;
      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
      // Auto-fill phone from ProfileCubit loaded state
      context.read<ProfileCubit>().state.maybeMap(
        loaded: (s) {
          final phone = s.profile.phone;
          if (phone != null && phone.isNotEmpty) {
            _phoneController.text = phone;
          }
        },
        orElse: () {},
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    final subjectError =
        _selectedSubject.isEmpty ? t.contact.form.typeRequired : null;
    final titleError = _titleController.text.trim().isEmpty
        ? t.contact.form.titleRequired
        : null;
    final messageError = _messageController.text.trim().isEmpty
        ? t.contact.form.messageRequired
        : null;
    final emailError = _emailController.text.trim().isEmpty
        ? t.contact.form.emailRequired
        : null;

    setState(() {
      _subjectError = subjectError;
      _titleError = titleError;
      _messageError = messageError;
      _emailError = emailError;
    });

    return subjectError == null &&
        titleError == null &&
        messageError == null &&
        emailError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final type = ContactMessageType.values.firstWhere(
      (e) => e.name == _selectedSubject,
      orElse: () => ContactMessageType.other,
    );
    final firebaseUid = context.read<AuthCubit>().currentUid ?? '';
    final profileCubit = context.read<ProfileCubit>();
    final deviceInfo = await _deviceInfoFuture;
    final phone = _phoneController.text.trim();

    final message = ContactMessage(
      type: type,
      title: _titleController.text.trim(),
      body: _messageController.text.trim(),
      replyEmail: _emailController.text.trim(),
      phone: phone.isEmpty ? null : phone,
      deviceInfo: deviceInfo,
      firebaseUid: firebaseUid,
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSent = false;
    });

    final success = await profileCubit.submitContactMessage(message);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _isSent = true;
      });
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isSent = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = t.contact.form.error;
      });
    }
  }

  InputDecoration _fieldDecoration({String? hintText, String? errorText}) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      hintStyle: const TextStyle(color: appMuted),
      filled: true,
      fillColor: appSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: appBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: appBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: appPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: appError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: appError, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.contact.form.subject,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SubjectOption(
          value: 'feedback',
          icon: FontAwesomeIcons.comment,
          iconColor: appPrimary,
          label: t.contact.form.feedback,
          groupValue: _selectedSubject,
          onChanged: (v) => setState(() {
            _selectedSubject = v;
            _subjectError = null;
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        SubjectOption(
          value: 'bug',
          icon: FontAwesomeIcons.bug,
          iconColor: appError,
          label: t.contact.form.reportBug,
          groupValue: _selectedSubject,
          onChanged: (v) => setState(() {
            _selectedSubject = v;
            _subjectError = null;
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        SubjectOption(
          value: 'feature',
          icon: FontAwesomeIcons.lightbulb,
          iconColor: appYellow,
          label: t.contact.form.featureRequest,
          groupValue: _selectedSubject,
          onChanged: (v) => setState(() {
            _selectedSubject = v;
            _subjectError = null;
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        SubjectOption(
          value: 'other',
          icon: FontAwesomeIcons.question,
          iconColor: appMuted,
          label: t.contact.form.other,
          groupValue: _selectedSubject,
          onChanged: (v) => setState(() {
            _selectedSubject = v;
            _subjectError = null;
          }),
        ),
        if (_subjectError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _subjectError!,
            style: const TextStyle(
              color: appError,
              fontSize: AppTypography.fontSizeSm,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          t.contact.form.title,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _titleController,
          style: const TextStyle(color: appText),
          decoration: _fieldDecoration(
            hintText: t.contact.form.titleHint,
            errorText: _titleError,
          ),
          onChanged: (_) {
            if (_titleError != null) setState(() => _titleError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          t.contact.form.message,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _messageController,
          maxLines: 6,
          style: const TextStyle(color: appText),
          decoration: _fieldDecoration(
            hintText: t.contact.form.messageHint,
            errorText: _messageError,
          ),
          onChanged: (_) {
            if (_messageError != null) setState(() => _messageError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<DeviceInfoData>(
          future: _deviceInfoFuture,
          builder: (context, snapshot) {
            final info = snapshot.data;
            return DeviceInfoCard(
              rows: [
                DeviceInfoRow(
                  label: t.contact.deviceInfoLabels.app,
                  value: info?.appVersion ?? '',
                ),
                DeviceInfoRow(
                  label: t.contact.deviceInfoLabels.device,
                  value: info?.device ?? '',
                ),
                DeviceInfoRow(
                  label: t.contact.deviceInfoLabels.os,
                  value: info?.os ?? '',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          t.contact.form.replyEmail,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: appText),
          decoration: _fieldDecoration(errorText: _emailError),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          t.common.form.phone,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: appText),
          decoration: _fieldDecoration(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (_errorMessage != null) ...[
          Container(
            decoration: BoxDecoration(
              color: appError.withValues(alpha: 0.1),
              border: Border.all(color: appError.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: appError,
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: appError,
                      fontSize: AppTypography.fontSizeSm,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLoading || _isSent) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSent ? appSuccessDark : appPrimary,
              foregroundColor: appWhite,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              disabledBackgroundColor:
                  _isSent ? appSuccessDark : appPrimary.withValues(alpha: 0.7),
              disabledForegroundColor: appWhite,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: appWhite,
                      strokeWidth: 2,
                    ),
                  )
                else if (_isSent)
                  const Icon(FontAwesomeIcons.check, size: 16)
                else
                  const Icon(FontAwesomeIcons.paperPlane, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _isLoading
                      ? t.contact.form.sending
                      : _isSent
                          ? t.contact.form.sent
                          : t.contact.form.submit,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSizeXl,
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_isSent)
          Container(
            decoration: BoxDecoration(
              color: appSuccessDark.withValues(alpha: 0.1),
              border: Border.all(color: appSuccessDark.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    FontAwesomeIcons.circleCheck,
                    color: appSuccessDark,
                    size: 14,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    t.contact.form.success,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: appSuccessDark,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: appPrimary.withValues(alpha: 0.1),
              border: Border.all(color: appPrimary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    FontAwesomeIcons.circleInfo,
                    color: appLightBlue,
                    size: 14,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.contact.responseTime,
                        style: const TextStyle(
                          fontSize: AppTypography.fontSizeMd,
                          fontWeight: AppTypography.fontWeightMedium,
                          color: appLightBlueTint,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        t.contact.responseTimeDetail,
                        style: const TextStyle(
                          fontSize: AppTypography.fontSizeSm,
                          color: appLightBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
