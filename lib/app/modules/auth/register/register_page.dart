import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';
import '../../legal/widgets/legal_links.dart';
import 'register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final headingColor = isDark ? AppTheme.textPrimaryDark : AppTheme.primary900;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final cardBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final cardBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final bannerBg = isDark
        ? AppTheme.softAccentSurfaceDark
        : AppTheme.primary50;
    final bannerBorder = isDark
        ? AppTheme.borderDark
        : AppTheme.strongBorderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Pendaftaran Mahasiswa'),
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offNamed(Routes.LOGIN);
            }
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scaledBase = MediaQuery.textScalerOf(context).scale(16);
            final compact = constraints.maxWidth < 360 || scaledBase > 22;
            final horizontalPad = constraints.maxWidth < 360
                ? 16.0
                : constraints.maxWidth >= 768
                ? 28.0
                : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Obx(() {
                  final loading = controller.isLoading.value;
                  final error = controller.errorMessage.value;
                  final selectedGender = controller.selectedGender.value;
                  final selectedAgama = controller.selectedAgama.value;
                  final selectedPendidikan =
                      controller.selectedPendidikan.value;
                  final passwordHidden = controller.isPasswordHidden.value;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      16,
                      horizontalPad,
                      32,
                    ),
                    child: FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: AutofillGroup(
                        child: LayoutBuilder(
                          builder: (context, inner) {
                            final twoCol =
                                inner.maxWidth >= 480 && scaledBase <= 21;
                            final sideBySideGender =
                                inner.maxWidth >= 360 && scaledBase <= 20;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Context Banner
                                Container(
                                  padding: EdgeInsets.all(compact ? 16 : 20),
                                  decoration: BoxDecoration(
                                    color: bannerBg,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXl,
                                    ),
                                    border: Border.all(
                                      color: bannerBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Buat Akun Mahasiswa SIKERA',
                                        style: TextStyle(
                                          fontSize: compact ? 17 : 19,
                                          fontWeight: FontWeight.w700,
                                          color: headingColor,
                                          height: 1.25,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Data akademik digunakan untuk pendampingan kampus. Kamu dapat mengisi inisial agar privasimu tetap terjaga saat berdiskusi.',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: secondaryColor,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Section 1: Data Pribadi
                                Container(
                                  padding: EdgeInsets.all(compact ? 16 : 24),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXl,
                                    ),
                                    border: Border.all(
                                      color: cardBorder,
                                      width: 1,
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : AppTheme.cardShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildSectionHeader(
                                        step: '1',
                                        title: 'Data Pribadi Mahasiswa',
                                        subtitle:
                                            'Informasi dasar untuk menyesuaikan materi edukasi kesehatan.',
                                        isDark: isDark,
                                        headingColor: headingColor,
                                        secondaryColor: secondaryColor,
                                      ),
                                      const SizedBox(height: 20),
                                      _field(
                                        context,
                                        key: 'register-name',
                                        label: 'Nama Lengkap',
                                        hint: 'Nama sesuai KTM',
                                        controller: controller.nameController,
                                        loading: loading,
                                        autofillHints: const [
                                          AutofillHints.name,
                                        ],
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 16),
                                      _responsivePair(
                                        twoCol: twoCol,
                                        first: _field(
                                          context,
                                          key: 'register-initials',
                                          label: 'Inisial (Opsional)',
                                          hint: 'Contoh: AP',
                                          controller:
                                              controller.initialsController,
                                          loading: loading,
                                          textInputAction: TextInputAction.next,
                                        ),
                                        second: _field(
                                          context,
                                          key: 'register-age',
                                          label: 'Usia (Tahun)',
                                          hint: 'Contoh: 20',
                                          controller: controller.usiaController,
                                          loading: loading,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Jenis Kelamin',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: headingColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      RadioGroup<String>(
                                        groupValue: selectedGender,
                                        onChanged: (val) {
                                          if (val != null && !loading) {
                                            controller.selectedGender.value =
                                                val;
                                          }
                                        },
                                        child: sideBySideGender
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: _genderOptionTile(
                                                      context,
                                                      title: 'Perempuan',
                                                      value: 'P',
                                                      selectedValue:
                                                          selectedGender,
                                                      loading: loading,
                                                      isDark: isDark,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: _genderOptionTile(
                                                      context,
                                                      title: 'Laki-laki',
                                                      value: 'L',
                                                      selectedValue:
                                                          selectedGender,
                                                      loading: loading,
                                                      isDark: isDark,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  _genderOptionTile(
                                                    context,
                                                    title: 'Perempuan',
                                                    value: 'P',
                                                    selectedValue:
                                                        selectedGender,
                                                    loading: loading,
                                                    isDark: isDark,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  _genderOptionTile(
                                                    context,
                                                    title: 'Laki-laki',
                                                    value: 'L',
                                                    selectedValue:
                                                        selectedGender,
                                                    loading: loading,
                                                    isDark: isDark,
                                                  ),
                                                ],
                                              ),
                                      ),
                                      const SizedBox(height: 16),
                                      _responsivePair(
                                        twoCol: twoCol,
                                        first: _dropdownField(
                                          context,
                                          label: 'Agama',
                                          value: selectedAgama,
                                          items: controller.agamaList,
                                          loading: loading,
                                          headingColor: headingColor,
                                          onChanged: (val) {
                                            if (val != null) {
                                              controller.selectedAgama.value =
                                                  val;
                                            }
                                          },
                                        ),
                                        second: _dropdownField(
                                          context,
                                          label: 'Pendidikan Terakhir',
                                          value: selectedPendidikan,
                                          items: controller.pendidikanList,
                                          loading: loading,
                                          headingColor: headingColor,
                                          onChanged: (val) {
                                            if (val != null) {
                                              controller
                                                      .selectedPendidikan
                                                      .value =
                                                  val;
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Section 2: Informasi Akademik & Akun
                                Container(
                                  padding: EdgeInsets.all(compact ? 16 : 24),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXl,
                                    ),
                                    border: Border.all(
                                      color: cardBorder,
                                      width: 1,
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : AppTheme.cardShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildSectionHeader(
                                        step: '2',
                                        title: 'Informasi Akademik & Akun',
                                        subtitle:
                                            'Gunakan NIM dan email aktif yang dapat dihubungi.',
                                        isDark: isDark,
                                        headingColor: headingColor,
                                        secondaryColor: secondaryColor,
                                      ),
                                      const SizedBox(height: 20),
                                      _field(
                                        context,
                                        key: 'register-nim',
                                        label: 'Nomor Induk Mahasiswa (NIM)',
                                        hint: 'Masukkan NIM sesuai KTM',
                                        controller: controller.nimController,
                                        loading: loading,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 16),
                                      _responsivePair(
                                        twoCol: twoCol,
                                        first: _field(
                                          context,
                                          key: 'register-program',
                                          label: 'Program Studi',
                                          hint: 'Contoh: Sistem Informasi',
                                          controller:
                                              controller.prodiController,
                                          loading: loading,
                                          textInputAction: TextInputAction.next,
                                        ),
                                        second: _field(
                                          context,
                                          key: 'register-faculty',
                                          label: 'Fakultas',
                                          hint: 'Contoh: Teknik',
                                          controller:
                                              controller.fakultasController,
                                          loading: loading,
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _field(
                                        context,
                                        key: 'register-email',
                                        label: 'Email Aktif',
                                        hint: 'nama@kampus.ac.id',
                                        controller: controller.emailController,
                                        loading: loading,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 16),
                                      _responsivePair(
                                        twoCol: twoCol,
                                        first: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Kata Sandi',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: headingColor,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Semantics(
                                              label: 'Kata Sandi',
                                              child: TextField(
                                                key: const ValueKey(
                                                  'register-password',
                                                ),
                                                controller: controller
                                                    .passwordController,
                                                obscureText: passwordHidden,
                                                readOnly: loading,
                                                autofillHints: const [
                                                  AutofillHints.newPassword,
                                                ],
                                                autocorrect: false,
                                                enableSuggestions: false,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onChanged: (_) =>
                                                    controller
                                                        .errorMessage
                                                        .value =
                                                        '',
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Minimal 6 karakter',
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppTheme.radiusMd,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: colors.outline,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppTheme.radiusMd,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: colors.primary,
                                                          width: 2,
                                                        ),
                                                      ),
                                                  suffixIcon: IconButton(
                                                    tooltip: passwordHidden
                                                        ? 'Tampilkan kata sandi'
                                                        : 'Sembunyikan kata sandi',
                                                    icon: Icon(
                                                      passwordHidden
                                                          ? Icons
                                                                .visibility_off_outlined
                                                          : Icons
                                                                .visibility_outlined,
                                                    ),
                                                    onPressed: controller
                                                        .togglePasswordVisibility,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        second: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Konfirmasi Kata Sandi',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: headingColor,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Semantics(
                                              label: 'Konfirmasi Kata Sandi',
                                              child: TextField(
                                                key: const ValueKey(
                                                  'register-password-confirm',
                                                ),
                                                controller: controller
                                                    .passwordConfirmController,
                                                obscureText: passwordHidden,
                                                readOnly: loading,
                                                autofillHints: const [
                                                  AutofillHints.newPassword,
                                                ],
                                                autocorrect: false,
                                                enableSuggestions: false,
                                                textInputAction:
                                                    TextInputAction.done,
                                                onChanged: (_) =>
                                                    controller
                                                        .errorMessage
                                                        .value =
                                                        '',
                                                onSubmitted: (_) {
                                                  if (!controller
                                                      .isLoading
                                                      .value) {
                                                    controller.register();
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Ulangi kata sandi',
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppTheme.radiusMd,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: colors.outline,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppTheme.radiusMd,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: colors.primary,
                                                          width: 2,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (error.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colors.errorContainer,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: colors.error,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          size: 20,
                                          color: colors.onErrorContainer,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Semantics(
                                            liveRegion: true,
                                            child: Text(
                                              error,
                                              style: TextStyle(
                                                color: colors.onErrorContainer,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                                height: 1.45,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),
                                Text(
                                  'Pelajari ketentuan layanan dan perlindungan data pribadi mahasiswa:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryColor,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const LegalLinks(),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor:
                                        colors.surfaceContainerHigh,
                                    disabledForegroundColor: colors.onSurface,
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: loading
                                      ? null
                                      : controller.register,
                                  child: loading
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                semanticsLabel:
                                                    'Mendaftarkan akun...',
                                                color: colors.onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: ExcludeSemantics(
                                                child: Text(
                                                  'Mendaftarkan akun...',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Daftar Akun Sekarang',
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      'Sudah punya akun?',
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: loading
                                          ? null
                                          : () {
                                              if (Navigator.of(
                                                context,
                                              ).canPop()) {
                                                Get.back();
                                              } else {
                                                Get.offNamed(Routes.LOGIN);
                                              }
                                            },
                                      child: const Text(
                                        'Masuk ke Akun',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String step,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color headingColor,
    required Color secondaryColor,
  }) {
    final stepBg = isDark
        ? AppTheme.softAccentSurfaceDark
        : AppTheme.primary50;
    final stepBorder = isDark
        ? AppTheme.borderDark
        : AppTheme.strongBorderLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: stepBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: stepBorder, width: 1),
          ),
          child: Text(
            step,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: headingColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: headingColor,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.5,
                  color: secondaryColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _responsivePair({
    required bool twoCol,
    required Widget first,
    required Widget second,
  }) {
    if (twoCol) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        first,
        const SizedBox(height: 16),
        second,
      ],
    );
  }

  Widget _genderOptionTile(
    BuildContext context, {
    required String title,
    required String value,
    required String selectedValue,
    required bool loading,
    required bool isDark,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = value == selectedValue;
    final unselectedBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final selectedBg = isDark
        ? AppTheme.softAccentSurfaceDark
        : AppTheme.primary50;
    final selectedBorder = isDark ? AppTheme.primary500 : AppTheme.primary700;

    return Material(
      color: selected ? selectedBg : unselectedBg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(
          color: selected ? selectedBorder : colors.outline,
          width: selected ? 1.5 : 1.0,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        value: value,
        enabled: !loading,
        activeColor: selectedBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _dropdownField(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required bool loading,
    required Color headingColor,
    required ValueChanged<String?> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          itemHeight: null,
          initialValue: value,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
          items: items
              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
              .toList(),
          onChanged: loading ? null : onChanged,
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context, {
    required String key,
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool loading,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    List<String>? autofillHints,
    TextInputAction? textInputAction,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? AppTheme.textPrimaryDark : AppTheme.primary900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          child: TextField(
            key: ValueKey(key),
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            autofillHints: autofillHints,
            textInputAction: textInputAction,
            autocorrect: false,
            readOnly: loading,
            onChanged: (_) => this.controller.errorMessage.value = '',
            decoration: InputDecoration(
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(color: colors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
