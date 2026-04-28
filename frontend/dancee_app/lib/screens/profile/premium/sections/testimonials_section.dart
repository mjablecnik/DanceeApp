import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/premium_repository.dart';
import '../../../../i18n/strings.g.dart';
import '../components/testimonial_card.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.premium.testimonialsTitle,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FutureBuilder<List<TestimonialData>>(
            future: const PremiumRepository().getTestimonials(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return Column(
                children: snapshot.data!
                    .map(
                      (testimonial) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: TestimonialCard(
                          avatarUrl: testimonial.avatarUrl,
                          name: testimonial.name,
                          quote: testimonial.quote,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
