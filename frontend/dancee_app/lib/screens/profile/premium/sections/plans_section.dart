import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../data/premium_repository.dart';
import '../components/plan_card.dart';

class PlansSection extends StatelessWidget {
  const PlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: FutureBuilder<List<PremiumPlanData>>(
        future: const PremiumRepository().getPlans(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final plans = snapshot.data!;
          return Column(
            children: plans
                .map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: PlanCard(
                      title: plan.title,
                      subtitle: plan.subtitle,
                      price: plan.price,
                      originalPrice: plan.originalPrice,
                      note: plan.note,
                      ctaLabel: plan.ctaLabel,
                      badge: plan.badge,
                      isPrimary: plan.isPrimary,
                      onTap: () {},
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
