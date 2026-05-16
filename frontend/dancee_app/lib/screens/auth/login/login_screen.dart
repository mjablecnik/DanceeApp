import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/service_locator.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../services/destination_service.dart';
import '../../../shared/components/background_circles.dart';
import '../../../shared/sections/auth_header_section.dart';
import 'sections/login_form_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;
  late final bool _cameFromAuthGate;

  @override
  void initState() {
    super.initState();
    _cameFromAuthGate = sl<DestinationService>().hasDestination;
    _animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goBack() {
    sl<DestinationService>().consumeDestination();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _cameFromAuthGate,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _cameFromAuthGate) {
          _goBack();
        }
      },
      child: Scaffold(
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
                    if (_cameFromAuthGate)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _goBack,
                          child: Container(
                            width: AppSizes.iconButtonMd,
                            height: AppSizes.iconButtonMd,
                            decoration: BoxDecoration(
                              color: appSurface,
                              borderRadius: BorderRadius.circular(AppRadius.round),
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_back, size: AppIconSizes.sm, color: appText),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: AppSpacing.xxxl),
                    const SizedBox(height: AppSpacing.xl),
                    AuthHeaderSection(
                      title: t.auth.login.title,
                      subtitle: t.auth.login.subtitle,
                    ),
                    const SizedBox(height: 48),
                  const LoginFormSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
