import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import 'selfcare_controller.dart';

class BloodGuidePage extends GetView<SelfcareController> {
  const BloodGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fallbackBloodData = [
      {
        'title': 'Merah Terang',
        'subtitle': 'Darah Segar & Normal',
        'desc': 'Mengindikasikan aliran darah yang baru keluar dan mengalir lancar pada hari-hari awal menstruasi. Tanda sistem hormonal bekerja dengan baik.',
        'color': Colors.red.shade600,
      },
      {
        'title': 'Merah Tua / Coklat Gelap',
        'subtitle': 'Darah Oksidasi Normal',
        'desc': 'Darah sisa dari siklus atau aliran di akhir menstruasi yang teroksidasi saat meninggalkan tubuh. Umumnya normal dan tidak berbahaya.',
        'color': Colors.brown.shade700,
      },
      {
        'title': 'Merah Muda (Pink)',
        'subtitle': 'Kadar Estrogen Rendah / Flek Awal',
        'desc': 'Dapat terjadi saat darah haid bercampur dengan cairan serviks, atau indikasi kadar hormon estrogen yang relatif rendah.',
        'color': Colors.pink.shade300,
      },
      {
        'title': 'Oranye / Abu-abu Keabuan',
        'subtitle': 'Perlu Perhatian & Konsultasi',
        'desc': 'Bisa menjadi tanda infeksi vagina (bacterial vaginosis atau trikomoniasis) terutama jika disertai bau tidak sedap dan gatal.',
        'color': Colors.orange.shade700,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Warna Darah Haid'),
      ),
      body: Obx(() {
        final apiList = controller.bloodGuides;
        final list = apiList.isNotEmpty
            ? apiList.map((item) {
                if (item is Map) {
                  return {
                    'title': item['title']?.toString() ?? 'Warna Darah',
                    'subtitle': item['subtitle']?.toString() ?? 'Keterangan Medis',
                    'desc': item['description']?.toString() ?? item['desc']?.toString() ?? '',
                    'color': _getColorFromTitle(item['title']?.toString() ?? ''),
                  };
                }
                return fallbackBloodData.first;
              }).toList()
            : fallbackBloodData;

        return StateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
          onRetry: controller.fetchBloodGuides,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['subtitle'] as String,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['desc'] as String,
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
      }),
    );
  }

  Color _getColorFromTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('coklat') || lower.contains('tua')) return Colors.brown.shade700;
    if (lower.contains('pink') || lower.contains('muda')) return Colors.pink.shade300;
    if (lower.contains('oranye') || lower.contains('abu')) return Colors.orange.shade700;
    return Colors.red.shade600;
  }
}

