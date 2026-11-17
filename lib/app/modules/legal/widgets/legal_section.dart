import 'package:flutter/material.dart';
import '../data/legal_content.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key, required this.section});
  final LegalContentSection section;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            section.heading,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Text(section.body, style: const TextStyle(fontSize: 16, height: 1.65)),
      ],
    ),
  );
}
