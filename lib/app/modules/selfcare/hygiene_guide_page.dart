import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'selfcare_controller.dart';

class HygieneGuidePage extends GetView<SelfcareController> {
  const HygieneGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hygieneTips = [
      {
        'title': 'Arah Membasuh yang Benar',
        'desc': 'Basuhlah organ reproduksi dari arah DEPAN ke BELAKANG (dari vagina/uretra ke arah anus), bukan sebaliknya. Hal ini mencegah bakteri usus (seperti E. coli) masuk ke saluran kemih.',
        'icon': Icons.arrow_downward_rounded,
      },
      {
        'title': 'Ganti Pembalut Secara Teratur',
        'desc': 'Ganti pembalut minimal setiap 3 hingga 4 jam sekali selama periode haid, bahkan jika volume darah sedang sedikit, untuk menghindari kelembaban berlebih dan kolonisasi kuman.',
        'icon': Icons.timer_outlined,
      },
      {
        'title': 'Gunakan Celana Dalam Katun',
        'desc': 'Pilihlah bahan pakaian dalam berbahan dasar katun yang memiliki sirkulasi udara baik dan menyerap keringat. Hindari celana dalam yang terlalu ketat.',
        'icon': Icons.dry_cleaning_outlined,
      },
      {
        'title': 'Hindari Sabun Wangi / Douching',
        'desc': 'Vagina memiliki mekanisme pembersihan alami dengan pH asam seimbang. Penggunaan sabun berparfum kuat atau cairan douching justru mematikan bakteri baik (Lactobacillus).',
        'icon': Icons.block_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Higienitas Reproduksi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: hygieneTips.length,
        itemBuilder: (context, index) {
          final tip = hygieneTips[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return CircleAvatar(
                      backgroundColor: isDark ? AppTheme.primary900.withValues(alpha: 0.4) : AppTheme.primary50,
                      child: Icon(tip['icon'] as IconData, color: isDark ? AppTheme.primary200 : AppTheme.primary700),
                    );
                  }),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tip['desc'] as String,
                          style: TextStyle(fontSize: 13, height: 1.4, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
