import 'package:flutter/material.dart';
import 'data/legal_content.dart';
import 'widgets/legal_document_page.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});
  @override
  Widget build(BuildContext context) => const LegalDocumentPage(
    title: 'Syarat & Ketentuan',
    sections: termsSections,
  );
}
