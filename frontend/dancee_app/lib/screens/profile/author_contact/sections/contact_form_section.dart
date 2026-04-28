import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/colors.dart';
import '../../../../../core/theme.dart';
import '../../../../../data/user_repository.dart';
import '../../../../../i18n/strings.g.dart';
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
  final TextEditingController _emailController =
      TextEditingController(text: 'tereza.novakova@email.cz');
  late final Future<DeviceInfoData> _deviceInfoFuture =
      const UserRepository().getDeviceInfo();

  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _isSent = false;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isLoading = false;
      _isSent = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSent = false;
      });
    }
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
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
          onChanged: (v) => setState(() => _selectedSubject = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        SubjectOption(
          value: 'bug',
          icon: FontAwesomeIcons.bug,
          iconColor: appError,
          label: t.contact.form.reportBug,
          groupValue: _selectedSubject,
          onChanged: (v) => setState(() => _selectedSubject = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        SubjectOption(
          value: 'feature',
          icon: FontAwesomeIcons.lightbulb,
          iconColor: appYellow,
          label: t.contact.form.featureRequest,
          groupValue: _selectedSubject,
          onChanged: (v) => setState(() => _selectedSubject = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        SubjectOption(
          value: 'other',
          icon: FontAwesomeIcons.question,
          iconColor: appMuted,
          label: t.contact.form.other,
          groupValue: _selectedSubject,
          onChanged: (v) => setState(() => _selectedSubject = v),
        ),
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
          ),
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
          ),
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
          decoration: _fieldDecoration(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLoading || _isSent) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSent ? appSuccessDark : appPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              disabledBackgroundColor:
                  _isSent ? appSuccessDark : appPrimary.withValues(alpha: 0.7),
              disabledForegroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
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
                child: Icon(FontAwesomeIcons.circleInfo, color: appLightBlue, size: 14),
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
