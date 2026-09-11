import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_pages.dart';
import 'education_controller.dart';

class ResultPage extends GetView<EducationController> {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : {};
    final bool isPretest = args['isPretest'] == true;
    final data = args['data'] is Map ? args['data'] as Map : {};

    final score = data['score'] ?? data['posttest_score'] ?? 0;
    final pretestScore = data['pretest_score'];
    final posttestScore = data['posttest_score'];
    final nGain = data['n_gain_score'];
    final category = data['effectiveness_category']?.toString();
    final pointsEarned = data['points_earned'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPretest ? 'Hasil Pre-Test' : 'Hasil Evaluasi Post-Test'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.primary,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isPretest ? 'Pre-Test Selesai!' : 'Selamat, Modul Selesai!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                isPretest
                    ? 'Akses submateri telah dibuka. Silakan pelajari materi yang tersedia.'
                    : 'Anda telah menyelesaikan seluruh materi dan post-test modul ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Detail Nilai Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nilai Diperoleh:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('$score / 100', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      if (!isPretest && pretestScore != null) ...[
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nilai Pre-Test:', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('$pretestScore / 100', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nilai Post-Test:', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('$posttestScore / 100', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (nGain != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Skor N-Gain:', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('$nGain (${category ?? '-'})', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ],
                          ),
                        ],
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Poin Kaspro Didapat:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('+$pointsEarned Poin', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  controller.refreshAllProgress();
                  Get.offAllNamed(Routes.HOME);
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
