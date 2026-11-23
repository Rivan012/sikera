import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/dashboard_model.dart';
import '../../routes/app_pages.dart';
import 'education_controller.dart';
import 'widgets/module_banner.dart';

class EducationTab extends GetView<EducationController> {
  const EducationTab({super.key, this.standalone = false});

  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        automaticallyImplyLeading: standalone,
      ),
      body: Obx(() {
        final modules = controller.modules;
        final completed = modules
            .where((m) => m.progressPercentage >= 100)
            .length;
        final progress = modules.isEmpty
            ? 0
            : (modules.fold<int>(0, (sum, m) => sum + m.progressPercentage) /
                      modules.length)
                  .round();

        return StateView(
          isLoading: controller.isLoading.value,
          loadingMessage: 'Memuat materi edukasi...',
          errorMessage: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : null,
          isEmpty: modules.isEmpty,
          emptyMessage: 'Belum ada materi yang tersedia.',
          emptyIcon: Icons.menu_book_outlined,
          onRetry: controller.fetchModules,
          child: RefreshIndicator(
            color: AppTheme.primary700,
            onRefresh: () => controller.fetchModules(forceRefresh: true),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _progressSummary(
                      context,
                      modules: modules,
                      completed: completed,
                      progress: progress,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pilih materi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.primary900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${modules.length} modul',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (
                          var index = 0;
                          index < modules.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 12),
                          _moduleCard(modules[index], isDark),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openModule(int moduleId) {
    controller.fetchModuleDetail(moduleId);
    Get.toNamed(
      Routes.EDUCATION_MODULE_DETAIL,
      arguments: moduleId,
    )?.then((_) {
      controller.fetchModules(forceRefresh: true);
    });
  }

  Widget _progressSummary(
    BuildContext context, {
    required List<DashboardModuleModel> modules,
    required int completed,
    required int progress,
    required bool isDark,
  }) {
    final total = modules.length;
    final completedTopics = modules.fold<int>(
      0,
      (sum, m) => sum + m.completedTopics,
    );
    final totalTopics = modules.fold<int>(0, (sum, m) => sum + m.totalTopics);
    final nextModule =
        modules.firstWhereOrNull(
          (m) => m.progressPercentage > 0 && m.progressPercentage < 100,
        ) ??
        modules.firstWhereOrNull((m) => m.progressPercentage < 100);
    final allDone = total > 0 && completed == total;
    final headline = allDone
        ? 'Semua materi tuntas'
        : progress > 0
        ? 'Lanjutkan progres belajarmu'
        : 'Mulai perjalanan belajarmu';
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final scaledBody = MediaQuery.textScalerOf(context).scale(14);

    final gradientColors = isDark
        ? const [Color(0xFF0D2B42), Color(0xFF0F3854), Color(0xFF124869)]
        : const [AppTheme.primary900, Color(0xFF023E7D), Color(0xFF0068A0)];
    final eyebrowColor = isDark ? AppTheme.primary200 : AppTheme.primary50;
    final bodyOnCard = isDark ? AppTheme.textSecondaryDark : Color(0xFFE3F6FC);
    final ringTrackColor = Colors.white.withValues(alpha: isDark ? 0.14 : 0.20);
    final ringFillColor = allDone
        ? const Color(0xFF4ADE80)
        : (isDark ? AppTheme.primary500 : AppTheme.primary200);
    final ctaBg = isDark ? AppTheme.primary500 : AppTheme.surfaceLight;
    const ctaFg = AppTheme.primary900;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 290 || scaledBody > 18;
        final pad = constraints.maxWidth < 340 ? 16.0 : 20.0;

        final summaryTexts = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Kemajuan belajar',
                  style: TextStyle(
                    color: eyebrowColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (compact)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Text(
                      '$progress%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              headline,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.22,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$completed dari $total modul selesai',
              style: TextStyle(color: bodyOnCard, fontSize: 13.5, height: 1.4),
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(
              color: isDark
                  ? AppTheme.primary500.withValues(alpha: 0.30)
                  : AppTheme.primary700.withValues(alpha: 0.20),
            ),
            boxShadow: isDark ? null : AppTheme.elevatedCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (compact)
                summaryTexts
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: summaryTexts),
                    const SizedBox(width: 16),
                    _ProgressRing(
                      progress: progress / 100,
                      label: '$progress%',
                      size: constraints.maxWidth >= 480 ? 80 : 72,
                      trackColor: ringTrackColor,
                      fillColor: ringFillColor,
                      reduceMotion: reduceMotion,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Rata-rata kemajuan belajar',
                value: '$progress%',
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      for (var i = 0; i < modules.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusPill,
                            ),
                            child: SizedBox(
                              height: 7,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ColoredBox(color: ringTrackColor),
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor:
                                        (modules[i].progressPercentage / 100)
                                            .clamp(0.0, 1.0),
                                    child: ColoredBox(
                                      color:
                                          modules[i].progressPercentage >= 100
                                          ? const Color(0xFF4ADE80)
                                          : ringFillColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: eyebrowColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$completedTopics/$totalTopics submateri tuntas',
                          style: TextStyle(
                            color: bodyOnCard,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (nextModule != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 16,
                          color: eyebrowColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Aktif: Modul ${nextModule.moduleNumber}',
                            style: TextStyle(
                              color: bodyOnCard,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (nextModule != null) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  key: const ValueKey('education-continue-cta'),
                  onPressed: () => _openModule(nextModule.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: ctaBg,
                    foregroundColor: ctaFg,
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    nextModule.progressPercentage > 0
                        ? 'Lanjutkan Modul ${nextModule.moduleNumber}'
                        : 'Mulai Modul ${nextModule.moduleNumber}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _moduleCard(DashboardModuleModel module, bool isDark) {
    return Material(
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: _moduleRow(module, isDark),
      ),
    );
  }

  Widget _moduleRow(DashboardModuleModel module, bool isDark) {
    final progress = module.progressPercentage.clamp(0, 100);
    final completed = progress == 100;
    final started = progress > 0 && !completed;
    final status = completed
        ? 'Selesai'
        : started
        ? 'Sedang dipelajari'
        : 'Belum dimulai';
    final action = completed
        ? 'Baca lagi'
        : started
        ? 'Lanjutkan'
        : 'Buka materi';
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final statusColor = completed
        ? (isDark ? const Color(0xFF4ADE80) : AppTheme.success)
        : secondaryColor;

    return Semantics(
      button: true,
      child: InkWell(
        key: ValueKey('education-module-${module.id}'),
        focusColor: (isDark ? AppTheme.primary200 : AppTheme.primary700)
            .withValues(alpha: 0.16),
        onTap: () => _openModule(module.id),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBannerSource =
                module.id > 0 || module.bannerImage?.trim().isNotEmpty == true;
            final showBanner =
                constraints.maxWidth >= 280 &&
                MediaQuery.textScalerOf(context).scale(14) <= 18 &&
                hasBannerSource;
            final bannerWidth = showBanner
                ? (constraints.maxWidth * 0.56).clamp(164.0, 300.0)
                : 0.0;
            final textRightPadding = showBanner
                ? (constraints.maxWidth * 0.40).clamp(130.0, 210.0)
                : 16.0;

            final content = Padding(
              padding: EdgeInsets.fromLTRB(16, 16, textRightPadding, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Modul ${module.moduleNumber}',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.title,
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.primary900,
                      fontSize: 17.5,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${module.completedTopics} dari ${module.totalTopics} submateri',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (started) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 4,
                        backgroundColor: isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight,
                        valueColor: AlwaysStoppedAnimation(
                          isDark ? AppTheme.primary500 : AppTheme.primary700,
                        ),
                        semanticsLabel: 'Kemajuan ${module.title}',
                        semanticsValue: '$progress%',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        action,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.primary200
                              : AppTheme.primary700,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (!showBanner) return content;

            return Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: bannerWidth,
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: isDark
                              ? const [
                                  Colors.transparent,
                                  Color(0x0D000000),
                                  Color(0x8A000000),
                                  Color(0xC8000000),
                                ]
                              : const [
                                  Colors.transparent,
                                  Color(0x14000000),
                                  Color(0xCC000000),
                                  Colors.black,
                                ],
                          stops: const [0.0, 0.30, 0.68, 1.0],
                        ).createShader(bounds),
                        child: ModuleBanner(
                          moduleId: module.id,
                          bannerImage: module.bannerImage,
                          moduleNumber: module.moduleNumber,
                          title: module.title,
                          width: bannerWidth,
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                          useModuleFallback: true,
                          backgroundColor: Colors.transparent,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                content,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.label,
    required this.size,
    required this.trackColor,
    required this.fillColor,
    required this.reduceMotion,
  });

  final double progress;
  final String label;
  final double size;
  final Color trackColor;
  final Color fillColor;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final target = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: reduceMotion ? target : 0, end: target),
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => CustomPaint(
          painter: _ProgressRingPainter(
            value: value,
            trackColor: trackColor,
            fillColor: fillColor,
          ),
          child: child,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.value,
    required this.trackColor,
    required this.fillColor,
  });

  final double value;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 7.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}
