import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/components/back_button_header.dart';
import 'sections/author_info_section.dart';
import 'sections/contact_form_section.dart';

class AuthorContactScreen extends StatelessWidget {
  const AuthorContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          BackButtonHeader(
            title: t.profile.support.contactAuthor,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xxl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthorInfoSection(),
                  SizedBox(height: AppSpacing.xxl),
                  ContactFormSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
