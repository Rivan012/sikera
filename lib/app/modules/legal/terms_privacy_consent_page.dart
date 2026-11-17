import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_pages.dart';
import 'data/legal_content.dart';
import 'widgets/consent_checkbox.dart';

class TermsPrivacyConsentPage extends StatefulWidget {
  const TermsPrivacyConsentPage({super.key});
  @override
  State<TermsPrivacyConsentPage> createState() =>
      _TermsPrivacyConsentPageState();
}

class _TermsPrivacyConsentPageState extends State<TermsPrivacyConsentPage> {
  bool _accepted = false;
  bool _saving = false;
  String? _error;

  Future<void> _continue() async {
    if (!_accepted || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await StorageService.acceptTermsPrivacy();
      if (mounted) Get.offAllNamed(Routes.HOME);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = StorageService.currentAccountId == null
              ? 'Informasi akun tidak tersedia. Keluar lalu masuk kembali.'
              : 'Persetujuan belum tersimpan. Silakan coba lagi.';
        });
      }
    }
  }

  Future<void> _leave() async {
    if (_saving) return;
    await StorageService.clearAuth();
    if (mounted) Get.offAllNamed(Routes.LOGIN);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Persetujuan'),
      automaticallyImplyLeading: false,
      actions: [
        TextButton(
          onPressed: _saving ? null : _leave,
          child: const Text('Keluar'),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sebelum melanjutkan',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        consentSummary,
                        style: TextStyle(fontSize: 16, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () => Get.toNamed(Routes.TERMS_OF_SERVICE),
                        child: const Text(
                          'Syarat & Ketentuan',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Get.toNamed(Routes.PRIVACY_POLICY),
                        child: const Text(
                          'Kebijakan Privasi',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        legalReviewNotice,
                        style: TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      ConsentCheckbox(
                        value: _accepted,
                        onChanged: _saving
                            ? null
                            : (value) =>
                                  setState(() => _accepted = value ?? false),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: !_accepted || _saving ? null : _continue,
                    child: Text(_saving ? 'Menyimpan…' : 'Lanjutkan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
