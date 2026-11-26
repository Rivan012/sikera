import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_assessment_model.dart';

class AdminQuestionCard extends StatelessWidget {
  const AdminQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final AdminQuestionModel question;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headingColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final successColor = isDark ? const Color(0xFF4ADE80) : AppTheme.success;
    final successBg = isDark
        ? AppTheme.success.withValues(alpha: 0.16)
        : AppTheme.successLight;

    return Card(
      key: ValueKey('admin-question-card-${question.id}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  'Soal ${index + 1}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.primary200 : AppTheme.primary700,
                  ),
                ),
                if (question.correctAnswer.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: successBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Kunci: ${question.correctAnswer}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question.questionText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.45,
                color: headingColor,
              ),
            ),
            if (question.options.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final option in question.options) ...[
                    Builder(
                      builder: (context) {
                        final isCorrect =
                            option.label.trim().toUpperCase() ==
                            question.correctAnswer.trim().toUpperCase();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? successBg
                                : (isDark
                                      ? AppTheme.elevatedSurfaceDark
                                      : AppTheme.pocketSurfaceLight),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                            border: Border.all(
                              color: isCorrect
                                  ? successColor.withValues(alpha: 0.45)
                                  : borderColor,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${option.label}.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: isCorrect
                                      ? successColor
                                      : headingColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.4,
                                    fontWeight: isCorrect
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isCorrect
                                        ? headingColor
                                        : secondaryColor,
                                  ),
                                ),
                              ),
                              if (isCorrect) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: successColor,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 10),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  key: ValueKey('edit-question-${question.id}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(104, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  onPressed: isDeleting ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  key: ValueKey('delete-question-${question.id}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(108, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                  ),
                  onPressed: isDeleting ? null : onDelete,
                  icon: isDeleting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.error,
                          ),
                        )
                      : const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(isDeleting ? 'Menghapus...' : 'Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
