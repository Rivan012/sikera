import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../onboarding_data.dart';

class OnboardingItem extends StatelessWidget {
  const OnboardingItem({super.key, required this.data});
  final OnboardingData data;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final colors = Theme.of(context).colorScheme;
      final size = (constraints.maxHeight * .48).clamp(140.0, 280.0);
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 32).clamp(0.0, double.infinity),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: data.icon == null
                      ? Center(
                          child: Container(
                            width: size * 0.76,
                            height: size * 0.76,
                            padding: EdgeInsets.all(size * 0.1),
                            decoration: BoxDecoration(
                              color: AppTheme.primary900,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radius2Xl,
                              ),
                            ),
                            child: Image.asset(
                              'assets/logo/sikera_logo_putih.png',
                              fit: BoxFit.contain,
                              cacheWidth: 800,
                            ),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            FractionallySizedBox(
                              widthFactor: .78,
                              heightFactor: .78,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  data.icon,
                                  size: size * .36,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            for (
                              var i = 0;
                              i < data.supportingIcons.length;
                              i++
                            )
                              Align(
                                alignment: i == 0
                                    ? Alignment.topRight
                                    : Alignment.bottomLeft,
                                child: Container(
                                  padding: EdgeInsets.all(size * .06),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: colors.outline),
                                  ),
                                  child: Icon(
                                    data.supportingIcons[i],
                                    size: size * .13,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: constraints.maxWidth < 360 ? 26 : 30,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
