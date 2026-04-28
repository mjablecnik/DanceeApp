import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

// =============================================================================
// AppLoadingIndicator
// =============================================================================

/// Centered loading spinner used across features.
///
/// Displays a [CircularProgressIndicator] in the app's primary color,
/// centered within its parent. Use this instead of inline
/// `Center(child: CircularProgressIndicator())` patterns.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// =============================================================================
// AppErrorMessage
// =============================================================================

/// Reusable error display with icon, message, and optional retry button.
///
/// Shows an error icon, the [message] text, and an optional [onRetry]
/// button. Use this for inline error states within pages (not full-page
/// errors — see `ErrorPage` for that).
class AppErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const AppErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  retryLabel ?? 'Retry',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// AppEmptyState
// =============================================================================

/// Reusable empty state display with icon, title, and description.
///
/// Shows a circular icon container, a [title], and an optional
/// [description]. Use this when a list or section has no content to show.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.textTertiary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
