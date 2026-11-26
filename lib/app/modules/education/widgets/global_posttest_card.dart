import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/module_model.dart';

class GlobalPosttestCard extends StatelessWidget {
  const GlobalPosttestCard({
    super.key,
    required this.status,
    required this.now,
    required this.onStartPosttest,
    this.onViewModules,
  });

  final GlobalPosttestStatus status;
  final DateTime now;
  final VoidCallback onStartPosttest;
  final VoidCallback? onViewModules;

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateFormat('d MMM yyyy, HH.mm').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availability = status.availabilityAt(now);
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;

    final Color accentColor;
    final Color surfaceColor;
    final Color borderColor;
    final IconData statusIcon;
    final String statusLabel;
    final String description;

    switch (availability) {
      case PosttestAvailability.completed:
        accentColor = isDark ? const Color(0xFF4ADE80) : AppTheme.success;
        surfaceColor = isDark
            ? AppTheme.surfaceDark
            : AppTheme.surfaceLight;
        borderColor = isDark
            ? const Color(0xFF065F46)
            : const Color(0xFFA7F3D0);
        statusIcon = Icons.verified_rounded;
        statusLabel = 'Post-Test Selesai';
        final scoreText = status.posttestScore != null
            ? 'Skor: ${status.posttestScore}/100'
            : 'Evaluasi akhir telah diselesaikan.';
        final nGainText = status.nGainScore != null
            ? ' | N-Gain: ${status.nGainScore!.toStringAsFixed(2)}${status.effectivenessCategory != null ? ' (${status.effectivenessCategory})' : ''}'
            : '';
        description = '$scoreText$nGainText';
      case PosttestAvailability.available:
        accentColor = isDark ? AppTheme.primary200 : AppTheme.primary700;
        surfaceColor = isDark
            ? AppTheme.softAccentSurfaceDark
            : AppTheme.primary50;
        borderColor = isDark ? AppTheme.primary500 : AppTheme.strongBorderLight;
        statusIcon = Icons.quiz_rounded;
        statusLabel = 'Tersedia Sekarang';
        description =
            'Masa tunggu ${status.delayDays} hari setelah menuntaskan semua modul sudah selesai. Kerjakan Post-Test Akhir untuk mengevaluasi peningkatan pemahamanmu.';
      case PosttestAvailability.waitingCooldown:
        accentColor = isDark ? const Color(0xFFFBBF24) : AppTheme.warning;
        surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
        borderColor = isDark
            ? AppTheme.warning.withValues(alpha: 0.45)
            : AppTheme.warning.withValues(alpha: 0.35);
        statusIcon = Icons.schedule_rounded;
        statusLabel = 'Menunggu ${status.delayDays} Hari';
        final unlockAt = status.effectiveAvailableAt;
        final remaining = status.formatRemaining(now);
        description = unlockAt != null
            ? 'Semua modul telah selesai. Post-Test Akhir akan terbuka dalam $remaining (mulai ${_formatDateTime(unlockAt)}).'
            : 'Semua modul telah selesai. Post-Test Akhir akan terbuka ${status.delayDays} hari setelah penyelesaian seluruh modul.';
      case PosttestAvailability.lockedIncompleteModules:
        accentColor = secondaryColor;
        surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
        borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
        statusIcon = Icons.lock_outline_rounded;
        statusLabel = 'Belum Terbuka';
        final progressHint = status.totalModules > 0
            ? '${status.completedModules} dari ${status.totalModules} modul selesai. '
            : '';
        description =
            '${progressHint}Post-Test Akhir akan muncul ${status.delayDays} hari setelah kamu menyelesaikan seluruh modul.';
    }

    return Container(
      key: const ValueKey('global-posttest-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDark ? null : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(statusIcon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Post-Test Akhir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: headingColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(
                              alpha: isDark ? 0.18 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (availability == PosttestAvailability.available) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              key: const ValueKey('start-global-posttest-btn'),
              onPressed: onStartPosttest,
              icon: const Icon(Icons.quiz_outlined, size: 20),
              label: const Text(
                'Mulai Post-Test Akhir',
                textAlign: TextAlign.center,
              ),
            ),
          ] else if (availability ==
                  PosttestAvailability.lockedIncompleteModules &&
              onViewModules != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('posttest-view-modules-btn'),
              onPressed: onViewModules,
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: const Text(
                'Lihat Daftar Modul',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
