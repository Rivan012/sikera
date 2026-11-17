import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/module_model.dart';

class TestQuestionPager extends StatefulWidget {
  final List<QuestionModel> questions;
  final Map<String, String> answers;
  final bool isSubmitting;
  final void Function(String questionId, String answer) onAnswer;
  final VoidCallback onSubmit;

  const TestQuestionPager({
    super.key,
    required this.questions,
    required this.answers,
    required this.isSubmitting,
    required this.onAnswer,
    required this.onSubmit,
  });

  @override
  State<TestQuestionPager> createState() => _TestQuestionPagerState();
}

class _TestQuestionPagerState extends State<TestQuestionPager> {
  final _scrollController = ScrollController();
  final _questionFocus = FocusNode(skipTraversal: true);
  int _index = 0;

  @override
  void didUpdateWidget(covariant TestQuestionPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.questions, widget.questions)) {
      _index = 0;
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _questionFocus.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (widget.isSubmitting || index < 0 || index >= widget.questions.length) {
      return;
    }
    _scrollController.jumpTo(0);
    setState(() => _index = index);
    _questionFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppTheme.primary200 : AppTheme.primary700;
    final secondary = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final question = widget.questions[_index];
    final selectedAnswer = widget.answers[question.id.toString()];
    final hasAnswer = question.options.any(
      (option) => option.label == selectedAnswer,
    );
    final answeredCount = widget.questions
        .where(
          (q) => q.options.any(
            (option) => option.label == widget.answers[q.id.toString()],
          ),
        )
        .length;
    final isLast = _index == widget.questions.length - 1;
    final canContinue =
        !widget.isSubmitting &&
        hasAnswer &&
        (!isLast || answeredCount == widget.questions.length);

    return PopScope(
      canPop: !widget.isSubmitting,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 16,
                          runSpacing: 4,
                          children: [
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                'Soal ${_index + 1} dari ${widget.questions.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '$answeredCount terjawab',
                              style: TextStyle(color: secondary, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: answeredCount / widget.questions.length,
                          color: accent,
                          backgroundColor: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight,
                          minHeight: 4,
                          semanticsLabel:
                              '$answeredCount dari ${widget.questions.length} soal terjawab',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 12, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Focus(
                            focusNode: _questionFocus,
                            child: Semantics(
                              header: true,
                              child: Text(
                                question.questionText,
                                key: ValueKey('question-${question.id}'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          RadioGroup<String>(
                            groupValue: selectedAnswer,
                            onChanged: (answer) {
                              if (answer != null && !widget.isSubmitting) {
                                widget.onAnswer(question.id.toString(), answer);
                              }
                            },
                            child: Column(
                              children: question.options.map((option) {
                                final isSelected =
                                    selectedAnswer == option.label;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Material(
                                    color: isSelected
                                        ? (isDark
                                              ? AppTheme.softAccentSurfaceDark
                                              : AppTheme.primary50)
                                        : theme.colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isSelected ? accent : secondary,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: RadioListTile<String>(
                                      key: ValueKey(
                                        'answer-${question.id}-${option.label}',
                                      ),
                                      value: option.label,
                                      enabled: !widget.isSubmitting,
                                      activeColor: accent,
                                      titleAlignment:
                                          ListTileTitleAlignment.top,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      title: Text(
                                        '${option.label}. ${option.text}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          letterSpacing: 0,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        IconButton.outlined(
                          tooltip: 'Soal sebelumnya',
                          onPressed: _index == 0 || widget.isSubmitting
                              ? null
                              : () => _goTo(_index - 1),
                          icon: const Icon(Icons.arrow_back_rounded),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: !canContinue
                                ? null
                                : isLast
                                ? widget.onSubmit
                                : () => _goTo(_index + 1),
                            icon: widget.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      semanticsLabel: 'Mengirim jawaban',
                                    ),
                                  )
                                : Icon(
                                    isLast
                                        ? Icons.send_outlined
                                        : Icons.arrow_forward_rounded,
                                  ),
                            label: Text(
                              widget.isSubmitting
                                  ? 'Mengirim...'
                                  : isLast
                                  ? 'Kirim Jawaban'
                                  : 'Berikutnya',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
