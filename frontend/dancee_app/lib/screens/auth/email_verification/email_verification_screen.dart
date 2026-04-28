import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../logic/states/auth_state.dart';
import '../../../shared/components/background_circles.dart';
import '../../../shared/elements/buttons/gradient_button.dart';
import '../../../shared/utils/auth_translations.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  bool _notVerifiedYet = false;
  StreamSubscription<AuthOperation>? _operationSuccessSub;

  AuthCubit get _authCubit => context.read<AuthCubit>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _operationSuccessSub?.cancel();
    // Listen for userReloaded events. When reloadUser() completes and the email
    // is still unverified, the AuthState may not change (same emailVerified=false
    // state as before), so BlocConsumer.listenWhen won't fire. Use the
    // operationSuccess stream instead to detect reload completion.
    _operationSuccessSub = _authCubit.operationSuccess.listen((op) {
      if (!mounted) return;
      if (op == AuthOperation.userReloaded) {
        final isVerified = _authCubit.state.maybeMap(
          authenticated: (s) => s.emailVerified,
          orElse: () => true, // non-authenticated: don't show the message
        );
        if (!isVerified) {
          setState(() => _notVerifiedYet = true);
        }
      } else if (op == AuthOperation.emailVerification) {
        // Show a SnackBar confirming the verification email was resent (Req 8.4).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.auth.emailVerification.resendConfirmed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _operationSuccessSub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr != prev,
      listener: (context, state) {
        state.maybeMap(
          authenticated: (s) {
            if (s.emailVerified) {
              if (s.isNewUser) {
                const OnboardingRoute().go(context);
              } else {
                const EventsRoute().go(context);
              }
            } else {
              setState(() => _notVerifiedYet = true);
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final email = state.maybeMap(
          authenticated: (s) => s.email ?? '',
          orElse: () => '',
        );

        // Use operationInProgress notifier so that sendEmailVerification and
        // reloadUser do not emit AuthState.loading() into the global auth state.
        return ListenableBuilder(
          listenable: _authCubit.operationInProgress,
          builder: (context, _) {
            final isLoading = _authCubit.operationInProgress.value;
            return Scaffold(
              backgroundColor: appBg,
              body: Stack(
                children: [
                  BackgroundCircles(animation: _floatAnim),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: AppSpacing.xxxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.xxxl),
                          const VerificationHeader(),
                          const SizedBox(height: AppSpacing.xl),
                          VerificationEmailCard(email: email),
                          if (_notVerifiedYet) ...[
                            const SizedBox(height: AppSpacing.lg),
                            const NotVerifiedMessage(),
                          ],
                          if (state.maybeMap(error: (_) => true, orElse: () => false)) ...[
                            const SizedBox(height: AppSpacing.lg),
                            VerificationErrorMessage(state: state),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          GradientButton(
                            label: t.auth.emailVerification.checkVerified,
                            onTap: () => _authCubit.reloadUser(),
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          VerificationResendButton(isLoading: isLoading),
                          const SizedBox(height: AppSpacing.xl),
                          VerificationSignOutButton(isLoading: isLoading),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class VerificationHeader extends StatelessWidget {
  const VerificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(AppRadius.round),
            boxShadow: [AppShadows.primaryLg],
          ),
          child: const Center(
            child: Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          t.auth.emailVerification.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize4xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
      ],
    );
  }
}

class VerificationEmailCard extends StatelessWidget {
  const VerificationEmailCard({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: appBorder),
      ),
      child: Text(
        t.auth.emailVerification.subtitle(email: email),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: appMuted,
          fontSize: AppTypography.fontSizeMd,
          height: 1.5,
        ),
      ),
    );
  }
}

class NotVerifiedMessage extends StatelessWidget {
  const NotVerifiedMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appError.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: appError, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              t.auth.emailVerification.notVerifiedYet,
              style: const TextStyle(
                color: appError,
                fontSize: AppTypography.fontSizeMd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationErrorMessage extends StatelessWidget {
  const VerificationErrorMessage({super.key, required this.state});

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final message = state.maybeMap(
      error: (s) => resolveAuthErrorKey(s.message),
      orElse: () => '',
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appError.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: appError, fontSize: AppTypography.fontSizeMd),
      ),
    );
  }
}

class VerificationResendButton extends StatelessWidget {
  const VerificationResendButton({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().sendEmailVerification(),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: appBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        minimumSize: const Size.fromHeight(56),
      ),
      child: Text(
        t.auth.emailVerification.resend,
        style: const TextStyle(
          color: appText,
          fontSize: AppTypography.fontSizeXl,
          fontWeight: AppTypography.fontWeightSemiBold,
        ),
      ),
    );
  }
}

class VerificationSignOutButton extends StatelessWidget {
  const VerificationSignOutButton({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().signOut(),
      child: Text(
        t.auth.emailVerification.signOut,
        style: const TextStyle(
          color: appMuted,
          fontSize: AppTypography.fontSizeMd,
        ),
      ),
    );
  }
}
