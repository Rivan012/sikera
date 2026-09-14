import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/period_assessment_model.dart';
import '../../data/models/selfcare_model.dart';

class PeriodSection extends StatelessWidget {
  const PeriodSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });
  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: TextStyle(color: periodSecondary(context), height: 1.45),
            ),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );
}

class PeriodNotice extends StatelessWidget {
  const PeriodNotice({
    super.key,
    required this.message,
    this.error = false,
    this.onRetry,
  });
  final String message;
  final bool error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.softAccentSurfaceDark
          : AppTheme.primary50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              error ? Icons.error_outline : Icons.info_outline,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (onRetry != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ),
      ],
    ),
  );
}

class AssessmentResultCard extends StatelessWidget {
  const AssessmentResultCard({
    super.key,
    required this.result,
    required this.name,
  });
  final PeriodAssessmentResult result;
  final String name;

  @override
  Widget build(BuildContext context) => PeriodSection(
    title:
        '$name: ${result.totalScore}${result.maxScore == null ? '' : '/${result.maxScore}'}',
    description: result.category,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.formula != null)
          Text(
            result.formula!,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        if (result.interpretation != null) ...[
          const SizedBox(height: 10),
          Text(result.interpretation!),
        ],
        if (result.advice != null) ...[
          const SizedBox(height: 10),
          Text(result.advice!),
        ],
        const SizedBox(height: 12),
        Text(
          'Hasil skrining dari kalkulator, bukan diagnosis.',
          style: TextStyle(fontSize: 12, color: periodSecondary(context)),
        ),
      ],
    ),
  );
}

String periodDate(String? value) {
  final date = DateTime.tryParse(value ?? '');
  if (date == null) return 'Belum tersedia';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class PeriodPredictionCard extends StatelessWidget {
  const PeriodPredictionCard({super.key, required this.prediction});
  final PeriodPredictionModel prediction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PeriodCalendar(prediction: prediction),
      PeriodSection(
        title: prediction.countdownText ?? 'Perkiraan siklus berikutnya',
        description: prediction.summaryNarrative,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dateRow(
              context,
              'Haid berikutnya',
              prediction.nextPeriodDate,
              Icons.calendar_month_outlined,
            ),
            _dateRow(
              context,
              'Estimasi ovulasi',
              prediction.ovulationDate,
              Icons.event_outlined,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Jendela masa subur\n${periodDate(prediction.fertileWindowStart)} s.d. ${periodDate(prediction.fertileWindowEnd)}',
                style: const TextStyle(height: 1.6),
              ),
            ),
            if (prediction.currentPhase != null) ...[
              const Divider(height: 28),
              Text(
                prediction.currentPhase!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (prediction.phaseDescription != null) ...[
                const SizedBox(height: 6),
                Text(prediction.phaseDescription!),
              ],
            ],
            if (prediction.clinicalDisclaimer != null) ...[
              const SizedBox(height: 18),
              Text(
                prediction.clinicalDisclaimer!,
                style: TextStyle(
                  color: periodSecondary(context),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
      if (prediction.upcomingCycles.isNotEmpty)
        PeriodSection(
          title: 'Siklus mendatang',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: prediction.upcomingCycles
                .map(
                  (cycle) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Haid: ${periodDate(cycle.periodStart)} s.d. ${periodDate(cycle.periodEnd)}\n'
                      'Ovulasi: ${periodDate(cycle.ovulationDate)}\n'
                      'Masa subur: ${periodDate(cycle.fertileStart)} s.d. ${periodDate(cycle.fertileEnd)}',
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ExpansionTile(
        key: const PageStorageKey('period-calculation-details'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        title: const Text('Detail perhitungan'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (prediction.cycleDay != null)
                  Text('Hari siklus: ${prediction.cycleDay}'),
                if (prediction.regularityStatus != null)
                  Text(prediction.regularityStatus!),
                for (final text in [
                  prediction.nextPeriodFormula,
                  prediction.ovulationFormula,
                  prediction.fertileWindowFormula,
                  prediction.oginoKnausFormatted,
                  prediction.oginoKnausFormula,
                  prediction.hormoneContext,
                  ...prediction.scientificReferences,
                ])
                  if (text != null && text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(text),
                    ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const PeriodNotice(
        message:
            'Tanggal di atas merupakan estimasi, bukan kepastian ovulasi atau dasar tunggal untuk mencegah kehamilan.',
      ),
    ],
  );

  Widget _dateRow(
    BuildContext context,
    String title,
    String date,
    IconData icon,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: periodSecondary(context)),
              ),
              const SizedBox(height: 4),
              Text(
                periodDate(date),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PeriodCalendar extends StatefulWidget {
  const PeriodCalendar({super.key, required this.prediction});
  final PeriodPredictionModel prediction;

  @override
  State<PeriodCalendar> createState() => _PeriodCalendarState();
}

class _PeriodCalendarState extends State<PeriodCalendar> {
  late DateTime month;

  @override
  void initState() {
    super.initState();
    final next =
        DateTime.tryParse(widget.prediction.nextPeriodDate) ?? DateTime.now();
    month = DateTime(next.year, next.month);
  }

  bool _between(DateTime date, String? startValue, String? endValue) {
    final start = DateTime.tryParse(startValue ?? '');
    final end = DateTime.tryParse(endValue ?? startValue ?? '');
    if (start == null || end == null) return false;
    return !date.isBefore(DateUtils.dateOnly(start)) &&
        !date.isAfter(DateUtils.dateOnly(end));
  }

  @override
  Widget build(BuildContext context) {
    final prediction = widget.prediction;
    final colors = Theme.of(context).colorScheme;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final offset = month.weekday - 1;
    final total = ((days + offset) / 7).ceil() * 7;
    return PeriodSection(
      title: 'Kalender perkiraan',
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Bulan sebelumnya',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                  () => month = DateTime(month.year, month.month - 1),
                ),
              ),
              Expanded(
                child: Text(
                  periodDate(month.toIso8601String()).substring(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Bulan berikutnya',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(
                  () => month = DateTime(month.year, month.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(day, style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: total,
            itemBuilder: (context, index) {
              final day = index - offset + 1;
              if (day < 1 || day > days) return const SizedBox.shrink();
              final date = DateTime(month.year, month.month, day);
              final period = _between(
                date,
                prediction.nextPeriodDate,
                prediction.nextPeriodEndDate,
              );
              final fertile = _between(
                date,
                prediction.fertileWindowStart,
                prediction.fertileWindowEnd,
              );
              final ovulation = _between(
                date,
                prediction.ovulationDate,
                prediction.ovulationDate,
              );
              return Semantics(
                label:
                    '${periodDate(date.toIso8601String())}${period ? ', perkiraan haid' : ''}${fertile ? ', estimasi masa subur' : ''}${ovulation ? ', estimasi ovulasi' : ''}',
                child: ExcludeSemantics(
                  child: Container(
                    decoration: BoxDecoration(
                      color: period
                          ? AppTheme.primary700
                          : fertile
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.softAccentSurfaceDark
                                : AppTheme.primary50)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: ovulation
                          ? Border.all(color: colors.primary, width: 2)
                          : null,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: period || ovulation
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: period ? Colors.white : colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legend(context, 'Haid', AppTheme.primary700, false),
              _legend(
                context,
                'Masa subur',
                Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.softAccentSurfaceDark
                    : AppTheme.primary50,
                false,
              ),
              _legend(context, 'Ovulasi', Colors.transparent, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(
    BuildContext context,
    String label,
    Color color,
    bool border,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: border
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}

Color periodSecondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppTheme.textSecondaryDark
    : AppTheme.textSecondaryLight;
