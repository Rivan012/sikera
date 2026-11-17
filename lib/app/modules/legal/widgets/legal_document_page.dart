import 'package:flutter/material.dart';
import '../data/legal_content.dart';
import 'legal_section.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.sections,
  });
  final String title;
  final List<LegalContentSection> sections;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                const LegalSection(
                  section: LegalContentSection(
                    'Status Dokumen',
                    legalReviewNotice,
                  ),
                ),
                ...sections.map((section) => LegalSection(section: section)),
                const LegalSection(
                  section: LegalContentSection('Pengelola', legalDeveloper),
                ),
                const Text(
                  'Kontak resmi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...legalContacts.map(
                  (email) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SelectableText(email),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
