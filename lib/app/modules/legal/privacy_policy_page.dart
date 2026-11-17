import 'package:flutter/material.dart';
import 'data/legal_content.dart';
import 'widgets/legal_document_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) => const LegalDocumentPage(
    title: 'Kebijakan Privasi',
    sections: privacySections,
  );
}
