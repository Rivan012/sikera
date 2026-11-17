import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 8,
    children: [
      TextButton(
        onPressed: () => Get.toNamed(Routes.TERMS_OF_SERVICE),
        child: const Text('Syarat & Ketentuan'),
      ),
      TextButton(
        onPressed: () => Get.toNamed(Routes.PRIVACY_POLICY),
        child: const Text('Kebijakan Privasi'),
      ),
    ],
  );
}
