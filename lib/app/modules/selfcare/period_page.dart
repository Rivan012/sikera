import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/selfcare_model.dart';
import '../../routes/app_pages.dart';
import 'selfcare_controller.dart';
import 'period_widgets.dart';

class PeriodPage extends StatefulWidget {
  const PeriodPage({super.key});

  @override
  State<PeriodPage> createState() => _PeriodPageState();
}

class _PeriodPageState extends State<PeriodPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<SelfcareController>();
  final _formKey = GlobalKey<FormState>();
  final _simulationKey = GlobalKey<FormState>();
  final _simulationCycle = TextEditingController(text: '28');
  final _simulationDuration = TextEditingController(text: '5');
  final _simulationHistory = TextEditingController();
  late final TabController _tabs;
  DateTime? _simulationDate;
  int _calculator = 0;

  @override
  void initState() {
    super.initState();
    final requested = Get.arguments is Map ? Get.arguments['tab'] : null;
    _tabs = TabController(
      length: 4,
      vsync: this,
      initialIndex: requested is int
          ? requested.clamp(0, 3)
          : StorageService.hasToken
          ? 0
          : 3,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _simulationCycle.dispose();
    _simulationDuration.dispose();
    _simulationHistory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Catat Haid'),
      bottom: TabBar(
        controller: _tabs,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: (index) {
          if (index == 1) controller.fetchPeriodPrediction();
          if (index == 2) controller.fetchPeriodHistory();
        },
        tabs: const [
          Tab(text: 'Catatan'),
          Tab(text: 'Prediksi'),
          Tab(text: 'Riwayat'),
          Tab(text: 'Kalkulator'),
        ],
      ),
    ),
    body: ChipTheme(
      data: Theme.of(context).chipTheme.copyWith(
        selectedColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.primary200
            : AppTheme.primary700,
        checkmarkColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.primary900
            : Colors.white,
        labelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primary900
                      : Colors.white)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      child: TabBarView(
        controller: _tabs,
        children: [
          _scroll('period-form', _recordForm()),
          _scroll('period-prediction', _prediction()),
          _scroll('period-history', _history()),
          _scroll('period-calculators', _calculators()),
        ],
      ),
    ),
  );

  Widget _scroll(String key, Widget child) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: SingleChildScrollView(
        key: PageStorageKey(key),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: child,
      ),
    ),
  );

  Widget _protected(Widget Function() body) => Obx(() {
    final loading = controller.isLoading.value;
    if (!StorageService.hasToken) {
      return PeriodSection(
        title: 'Masuk untuk melihat catatanmu',
        description: 'Catatan dan riwayat haid tersimpan di akun mahasiswi.',
        child: FilledButton(
          onPressed: () => Get.toNamed(Routes.LOGIN),
          child: const Text('Masuk'),
        ),
      );
    }
    if (loading && controller.summaryData.value == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.errorMessage.value.isNotEmpty &&
        controller.summaryData.value == null) {
      return PeriodNotice(
        message: controller.errorMessage.value,
        error: true,
        onRetry: controller.loadSelfcare,
      );
    }
    if (!controller.isFemale.value) {
      return PeriodSection(
        title: 'Pencatatan khusus mahasiswi',
        description:
            'Akun ini tidak memiliki akses catatan haid. Kalkulator dan panduan tetap dapat digunakan.',
        child: OutlinedButton(
          onPressed: () => _tabs.animateTo(3),
          child: const Text('Buka kalkulator'),
        ),
      );
    }
    return body();
  });

  Widget _recordForm() => _protected(() {
    if (controller.periodSuccess.value.isNotEmpty) {
      return PeriodSection(
        title: 'Catatan tersimpan',
        description: controller.periodSuccess.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => _tabs.animateTo(1),
              child: const Text('Lihat prediksi'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _tabs.animateTo(2),
              child: const Text('Lihat riwayat'),
            ),
            TextButton(
              onPressed: controller.isSavingPeriod.value
                  ? null
                  : controller.resetPeriodForm,
              child: const Text('Buat catatan baru'),
            ),
          ],
        ),
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kenali pola siklusmu',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Catat tanggal, aliran, dan keluhan yang kamu alami. Catatan berhasil disimpan mendapat +10 poin.',
            style: TextStyle(color: periodSecondary(context), height: 1.45),
          ),
          const SizedBox(height: 22),
          AbsorbPointer(
            absorbing: controller.isSavingPeriod.value,
            child: Column(
              children: [
                PeriodSection(
                  title: '1. Pola haid',
                  child: Column(
                    children: [
                      _number(
                        controller.menarcheAgeController,
                        'Usia haid pertama (opsional)',
                        8,
                        25,
                        optional: true,
                        suffix: 'tahun',
                      ),
                      const SizedBox(height: 16),
                      _number(
                        controller.cycleLengthController,
                        'Panjang siklus',
                        15,
                        60,
                        suffix: 'hari',
                        helper:
                            'Jarak hari pertama haid ke hari pertama haid berikutnya.',
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => DropdownButtonFormField<bool>(
                          initialValue: controller.isRegular.value,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Apakah siklus biasanya teratur?',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Teratur'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Tidak teratur'),
                            ),
                          ],
                          validator: (value) => value == null
                              ? 'Pilih keteraturan siklus.'
                              : null,
                          onChanged: (value) =>
                              controller.isRegular.value = value,
                        ),
                      ),
                    ],
                  ),
                ),
                PeriodSection(
                  title: '2. Tanggal haid',
                  description:
                      'Biarkan tanggal selesai kosong jika haid masih berlangsung.',
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _dateButton(
                          'Tanggal mulai',
                          controller.startDate.value,
                          () => _pickDate(false),
                        ),
                        const SizedBox(height: 12),
                        _dateButton(
                          'Tanggal selesai',
                          controller.endDate.value,
                          controller.startDate.value == null
                              ? null
                              : () => _pickDate(true),
                        ),
                        if (controller.endDate.value != null)
                          TextButton(
                            onPressed: () => controller.endDate.value = null,
                            child: const Text('Haid masih berlangsung'),
                          ),
                        const SizedBox(height: 16),
                        if (controller.recordedDuration != null)
                          Text(
                            'Durasi otomatis: ${controller.recordedDuration} hari',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          )
                        else
                          _number(
                            controller.periodDurationController,
                            'Perkiraan durasi haid',
                            1,
                            14,
                            suffix: 'hari',
                            helper:
                                'Dipakai untuk estimasi selama tanggal selesai belum diketahui.',
                          ),
                      ],
                    ),
                  ),
                ),
                PeriodSection(
                  title: '3. Volume dan warna darah',
                  child: Column(
                    children: [
                      _dropdown(
                        'Level aliran',
                        controller.flowLevel.value,
                        const {
                          'ringan': 'Ringan',
                          'sedang': 'Sedang',
                          'deras': 'Deras',
                          'sangat_deras': 'Sangat deras',
                        },
                        (value) => controller.flowLevel.value = value,
                      ),
                      const SizedBox(height: 16),
                      _dropdown(
                        'Warna darah',
                        controller.flowColor.value,
                        const {
                          'Merah Terang': 'Merah terang',
                          'Merah Gelap': 'Merah gelap',
                          'Cokelat': 'Cokelat',
                          'Merah Muda': 'Merah muda',
                          'Hitam': 'Hitam',
                        },
                        (value) => controller.flowColor.value = value,
                      ),
                      const SizedBox(height: 16),
                      _dropdown(
                        'Konsistensi darah',
                        controller.bloodConsistency.value,
                        const {
                          'Sedang / Normal': 'Sedang',
                          'Cair / Encer': 'Cair / encer',
                          'Kental / Menggumpal': 'Kental / menggumpal',
                        },
                        (value) => controller.bloodConsistency.value = value,
                      ),
                      Obx(
                        () => SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Sertakan pencatatan PBAC'),
                          subtitle: const Text(
                            'Jumlah pembalut dan gumpalan pada siklus ini.',
                          ),
                          value: controller.includePbac.value,
                          onChanged: (value) {
                            controller.includePbac.value = value;
                            controller.invalidatePbac();
                          },
                        ),
                      ),
                      Obx(
                        () => controller.includePbac.value
                            ? _pbacFields()
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                PeriodSection(
                  title: '4. Nyeri dan aktivitas',
                  description:
                      'Isi pengalaman nyeri untuk evaluasi NRS dan WaLIDD.',
                  child: _waliddFields(),
                ),
                PeriodSection(
                  title: '5. Gejala dan catatan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(
                        () => Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: controller.availableSymptoms
                              .map(
                                (symptom) => FilterChip(
                                  label: Text(symptom),
                                  selected: controller.selectedSymptoms
                                      .contains(symptom),
                                  onSelected: (selected) {
                                    if (selected) {
                                      controller.selectedSymptoms.add(symptom);
                                    } else {
                                      controller.selectedSymptoms.remove(
                                        symptom,
                                      );
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: controller.notesController,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Catatan pribadi (opsional)',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (controller.periodError.value.isNotEmpty)
            PeriodNotice(message: controller.periodError.value, error: true),
          FilledButton(
            key: const ValueKey('save-period'),
            onPressed: controller.isSavingPeriod.value
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      controller.submitPeriod();
                    }
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              controller.isSavingPeriod.value
                  ? 'Menyimpan catatan…'
                  : 'Simpan catatan haid',
            ),
          ),
          const SizedBox(height: 18),
          _guides(),
        ],
      ),
    );
  });

  Future<void> _pickDate(bool isEnd) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final earliest = isEnd ? controller.startDate.value! : DateTime(2000);
    final initial =
        (isEnd ? controller.endDate.value : controller.startDate.value) ??
        today;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(earliest)
          ? earliest
          : initial.isAfter(today)
          ? today
          : initial,
      firstDate: earliest,
      lastDate: today,
    );
    if (selected == null) return;
    if (isEnd) {
      controller.endDate.value = selected;
    } else {
      controller.startDate.value = selected;
      if (controller.endDate.value?.isBefore(selected) ?? false) {
        controller.endDate.value = null;
      }
    }
  }

  Widget _dateButton(
    String label,
    DateTime? date,
    VoidCallback? action,
  ) => OutlinedButton.icon(
    onPressed: action,
    icon: const Icon(Icons.calendar_today_outlined, size: 20),
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        '$label: ${date == null ? 'Pilih tanggal' : periodDate(SelfcareController.dateOnly(date))}',
      ),
    ),
  );

  Widget _number(
    TextEditingController input,
    String label,
    int min,
    int max, {
    bool optional = false,
    String? suffix,
    String? helper,
    ValueChanged<String>? onChanged,
  }) => TextFormField(
    controller: input,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      suffixStyle: TextStyle(color: periodSecondary(context)),
      helperText: helper,
      helperMaxLines: 3,
    ),
    onChanged: onChanged,
    validator: (value) {
      if (optional && (value?.isEmpty ?? true)) return null;
      final number = int.tryParse(value ?? '');
      return number == null || number < min || number > max
          ? 'Isi angka $min–$max.'
          : null;
    },
  );

  Widget _dropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: options.containsKey(value) ? value : options.keys.first,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: options.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList(),
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );

  Widget _pbacFields() {
    const labels = {
      'pads_light': 'Pembalut bercak ringan',
      'pads_medium': 'Pembalut terisi sebagian',
      'pads_heavy': 'Pembalut penuh',
      'clots_small': 'Gumpalan kecil',
      'clots_large': 'Gumpalan besar',
    };
    return Obx(() {
      final counts = Map<String, int>.from(controller.pbacCounts);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jumlah selama satu siklus, bukan per hari. Isi sesuai pemakaian yang kamu catat.',
            style: TextStyle(fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 12),
          ...labels.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final controls = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Kurangi ${entry.value}',
                        onPressed: counts[entry.key]! > 0
                            ? () {
                                controller.pbacCounts[entry.key] =
                                    controller.pbacCounts[entry.key]! - 1;
                                controller.invalidatePbac();
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 38,
                        child: Text(
                          '${counts[entry.key]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tambah ${entry.value}',
                        onPressed: counts[entry.key]! < 100
                            ? () {
                                controller.pbacCounts[entry.key] =
                                    controller.pbacCounts[entry.key]! + 1;
                                controller.invalidatePbac();
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  );
                  if (constraints.maxWidth < 350 ||
                      MediaQuery.textScalerOf(context).scale(14) > 20) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(entry.value), controls],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: Text(entry.value)),
                      controls,
                    ],
                  );
                },
              ),
            ),
          ),
          OutlinedButton(
            onPressed: controller.isCalculatingPbac.value
                ? null
                : controller.calculatePbac,
            child: Text(
              controller.isCalculatingPbac.value
                  ? 'Menghitung PBAC…'
                  : 'Hitung skor PBAC',
            ),
          ),
          const SizedBox(height: 12),
          if (controller.pbacError.value.isNotEmpty)
            PeriodNotice(
              message: controller.pbacError.value,
              error: true,
              onRetry: controller.calculatePbac,
            ),
          if (controller.pbacResult.value != null)
            AssessmentResultCard(
              result: controller.pbacResult.value!,
              name: 'PBAC',
            ),
        ],
      );
    });
  }

  Widget _waliddFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Skor nyeri NRS: ${controller.painScore.value}/10',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: controller.painScore.value.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: '${controller.painScore.value}',
              onChanged: (value) {
                controller.painScore.value = value.round();
                controller.invalidateWalidd();
              },
            ),
            const Text(
              '0 = tidak nyeri · 10 = nyeri terberat',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<int>(
              initialValue: controller.workingAbility.value,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Dampak pada aktivitas (W)',
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Tidak terganggu')),
                DropdownMenuItem(value: 1, child: Text('Sedikit terganggu')),
                DropdownMenuItem(value: 2, child: Text('Cukup terganggu')),
                DropdownMenuItem(
                  value: 3,
                  child: Text('Harus beristirahat di tempat tidur'),
                ),
              ],
              onChanged: (value) {
                controller.workingAbility.value = value ?? 0;
                controller.invalidateWalidd();
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Lokasi nyeri (L)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 8,
              children:
                  const {
                        'perut_bawah': 'Perut bawah',
                        'pinggang': 'Pinggang',
                        'paha_dalam': 'Paha dalam',
                      }.entries
                      .map(
                        (entry) => FilterChip(
                          label: Text(entry.value),
                          selected: controller.painLocations.contains(
                            entry.key,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              controller.painLocations.add(entry.key);
                            } else {
                              controller.painLocations.remove(entry.key);
                            }
                            controller.invalidateWalidd();
                          },
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _number(
        controller.painDaysController,
        'Jumlah hari nyeri (D)',
        0,
        30,
        suffix: 'hari',
        onChanged: (_) => controller.invalidateWalidd(),
      ),
      const SizedBox(height: 16),
      Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton(
              onPressed: controller.isCalculatingWalidd.value
                  ? null
                  : controller.calculateWalidd,
              child: Text(
                controller.isCalculatingWalidd.value
                    ? 'Menghitung WaLIDD…'
                    : 'Hitung skor WaLIDD',
              ),
            ),
            const SizedBox(height: 12),
            if (controller.waliddError.value.isNotEmpty)
              PeriodNotice(
                message: controller.waliddError.value,
                error: true,
                onRetry: controller.calculateWalidd,
              ),
            if (controller.waliddResult.value != null)
              AssessmentResultCard(
                result: controller.waliddResult.value!,
                name: 'WaLIDD',
              ),
          ],
        ),
      ),
    ],
  );

  Widget _prediction() => _protected(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.isPredictionLoading.value)
          const LinearProgressIndicator(),
        if (controller.predictionError.value.isNotEmpty)
          PeriodNotice(
            message: controller.predictionError.value,
            error: true,
            onRetry: controller.fetchPeriodPrediction,
          ),
        if (controller.periodPredictions.value != null) ...[
          const Text(
            'Berdasarkan catatan tersimpan',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          PeriodPredictionCard(prediction: controller.periodPredictions.value!),
        ] else if (!controller.isPredictionLoading.value &&
            controller.predictionError.value.isEmpty)
          PeriodSection(
            title: 'Belum ada prediksi',
            description:
                'Simpan tanggal mulai haid agar perkiraan siklus bisa ditampilkan.',
            child: FilledButton(
              onPressed: () => _tabs.animateTo(0),
              child: const Text('Catat haid'),
            ),
          ),
        OutlinedButton(
          onPressed: controller.isPredictionLoading.value
              ? null
              : controller.fetchPeriodPrediction,
          child: const Text('Muat ulang prediksi'),
        ),
      ],
    ),
  );

  Widget _history() => _protected(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '20 catatan terakhir',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (controller.isHistoryLoading.value) const LinearProgressIndicator(),
        if (controller.historyError.value.isNotEmpty)
          PeriodNotice(
            message: controller.historyError.value,
            error: true,
            onRetry: controller.fetchPeriodHistory,
          ),
        if (controller.periodHistory.isEmpty &&
            !controller.isHistoryLoading.value &&
            controller.historyError.value.isEmpty)
          PeriodSection(
            title: 'Belum ada catatan haid',
            description: 'Catatan yang berhasil disimpan akan muncul di sini.',
            child: FilledButton(
              onPressed: () => _tabs.animateTo(0),
              child: const Text('Buat catatan pertama'),
            ),
          ),
        ...controller.periodHistory.map(_historyItem),
        OutlinedButton(
          onPressed: controller.isHistoryLoading.value
              ? null
              : controller.fetchPeriodHistory,
          child: const Text('Muat ulang riwayat'),
        ),
      ],
    ),
  );

  Widget _historyItem(PeriodRecordModel item) => PeriodSection(
    title: periodDate(item.startDate),
    description: item.endDate == null
        ? 'Tanggal selesai belum dicatat'
        : 'Selesai ${periodDate(item.endDate)}',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Siklus ${item.cycleLength} hari · ${item.endDate == null ? 'Perkiraan durasi' : 'Durasi'} ${item.periodDuration} hari',
        ),
        const SizedBox(height: 8),
        Text(
          'Aliran ${item.flowLevel.replaceAll('_', ' ')} · ${item.flowColor}',
        ),
        if (item.menarcheAge != null)
          Text('Haid pertama: ${item.menarcheAge} tahun'),
        if (item.isRegular != null)
          Text(item.isRegular! ? 'Siklus teratur' : 'Siklus tidak teratur'),
        const SizedBox(height: 8),
        Text('NRS ${item.nrsPainScore}/10'),
        if (item.waliddTotalScore != null)
          Text(
            'WaLIDD ${item.waliddTotalScore}/12 · ${item.waliddCategory ?? ''}',
          ),
        if (item.pbacScore != null)
          Text('PBAC ${item.pbacScore} · ${item.volumeCategory ?? ''}'),
        if (item.symptoms.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(item.symptoms.join(', ')),
        ],
        if (item.notes?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text(item.notes!),
        ],
      ],
    ),
  );

  Widget _calculators() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Kalkulator mandiri',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      Text(
        'Bisa digunakan tanpa login. Perhitungan di sini tidak menyimpan catatan atau menambah poin.',
        style: TextStyle(color: periodSecondary(context), height: 1.45),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        children: ['Siklus', 'PBAC', 'WaLIDD']
            .asMap()
            .entries
            .map(
              (entry) => ChoiceChip(
                label: Text(entry.value),
                selected: _calculator == entry.key,
                onSelected: (_) => setState(() => _calculator = entry.key),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 16),
      if (_calculator == 0) _simulation(),
      if (_calculator == 1)
        PeriodSection(title: 'Skor volume PBAC', child: _pbacFields()),
      if (_calculator == 2)
        PeriodSection(title: 'Evaluasi nyeri WaLIDD', child: _waliddFields()),
      _guides(),
    ],
  );

  Widget _simulation() => Form(
    key: _simulationKey,
    child: Column(
      children: [
        PeriodSection(
          title: 'Simulasi siklus',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dateButton(
                'Hari pertama haid terakhir',
                _simulationDate,
                () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _simulationDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (selected != null) {
                    controller.invalidateSimulation();
                    setState(() => _simulationDate = selected);
                  }
                },
              ),
              const SizedBox(height: 16),
              _number(
                _simulationCycle,
                'Panjang siklus',
                15,
                60,
                suffix: 'hari',
                onChanged: (_) => controller.invalidateSimulation(),
              ),
              const SizedBox(height: 16),
              _number(
                _simulationDuration,
                'Durasi haid',
                1,
                14,
                suffix: 'hari',
                onChanged: (_) => controller.invalidateSimulation(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _simulationHistory,
                decoration: const InputDecoration(
                  labelText: 'Riwayat panjang siklus (opsional)',
                  hintText: 'Contoh: 27, 29, 28',
                  helperText:
                      'Pisahkan dengan koma. Dipakai untuk variasi siklus.',
                  helperMaxLines: 2,
                ),
                onChanged: (_) => controller.invalidateSimulation(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return value.split(',').any((s) {
                        final number = int.tryParse(s.trim());
                        return number == null || number < 15 || number > 60;
                      })
                      ? 'Isi daftar angka 15–60, dipisahkan koma.'
                      : null;
                },
              ),
              const SizedBox(height: 18),
              Obx(
                () => FilledButton(
                  onPressed: controller.isCalculatingSimulation.value
                      ? null
                      : () {
                          if (!_simulationKey.currentState!.validate()) return;
                          if (_simulationDate == null) {
                            controller.simulationError.value =
                                'Pilih hari pertama haid terakhir.';
                            return;
                          }
                          controller.calculatePeriodSimulation(
                            lastPeriodDate: _simulationDate!,
                            cycleLength: int.parse(_simulationCycle.text),
                            periodDuration: int.parse(_simulationDuration.text),
                            cycleHistory: _simulationHistory.text.trim().isEmpty
                                ? null
                                : _simulationHistory.text
                                      .split(',')
                                      .map((s) => int.parse(s.trim()))
                                      .toList(),
                          );
                        },
                  child: Text(
                    controller.isCalculatingSimulation.value
                        ? 'Menghitung…'
                        : 'Hitung perkiraan siklus',
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Column(
            children: [
              if (controller.simulationError.value.isNotEmpty)
                PeriodNotice(
                  message: controller.simulationError.value,
                  error: true,
                ),
              if (controller.simulationResult.value != null)
                PeriodPredictionCard(
                  prediction: controller.simulationResult.value!,
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _guides() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      TextButton.icon(
        onPressed: () => Get.toNamed(Routes.SELFCARE_BLOOD_GUIDE),
        icon: const Icon(Icons.water_drop_outlined),
        label: const Text('Panduan warna darah'),
      ),
      TextButton.icon(
        onPressed: () => Get.toNamed(Routes.SELFCARE_HYGIENE_GUIDE),
        icon: const Icon(Icons.clean_hands_outlined),
        label: const Text('Panduan kebersihan'),
      ),
    ],
  );
}
