import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'selfcare_controller.dart';
import 'period_widgets.dart';

class SelfcareGuidePage extends StatefulWidget {
  const SelfcareGuidePage({super.key, required this.blood});
  final bool blood;

  @override
  State<SelfcareGuidePage> createState() => _SelfcareGuidePageState();
}

class _SelfcareGuidePageState extends State<SelfcareGuidePage> {
  final controller = Get.find<SelfcareController>();

  Future<void> _load() => widget.blood
      ? controller.fetchBloodGuides(forceRefresh: true)
      : controller.fetchHygieneGuides(forceRefresh: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.blood ? 'Panduan warna darah' : 'Panduan kebersihan'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Obx(() {
          final loading = widget.blood
              ? controller.isBloodLoading.value
              : controller.isHygieneLoading.value;
          final error = widget.blood
              ? controller.bloodError.value
              : controller.hygieneError.value;
          final empty = widget.blood
              ? controller.bloodGuides.isEmpty
              : controller.hygieneGuides.isEmpty;
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (error.isNotEmpty)
                  PeriodNotice(message: error, error: true, onRetry: _load),
                if (empty && !loading && error.isEmpty)
                  PeriodNotice(
                    message: 'Panduan belum tersedia. Coba muat ulang nanti.',
                    onRetry: _load,
                  ),
                if (widget.blood)
                  ...controller.bloodGuides.map(
                    (guide) => PeriodSection(
                      title: guide.colorName,
                      description: guide.status,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (RegExp(
                            r'^#[0-9a-fA-F]{6}$',
                          ).hasMatch(guide.hexColor)) ...[
                            Container(
                              width: 48,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(
                                  0xFF000000 |
                                      int.parse(
                                        guide.hexColor.substring(1),
                                        radix: 16,
                                      ),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            guide.description,
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...controller.hygieneGuides.map(
                    (guide) => PeriodSection(
                      title: '${guide.step}. ${guide.title}',
                      child: Text(
                        guide.description,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}
