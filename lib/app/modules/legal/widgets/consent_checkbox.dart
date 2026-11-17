import 'package:flutter/material.dart';
import '../data/legal_content.dart';

class ConsentCheckbox extends StatelessWidget {
  const ConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool?>? onChanged;
  @override
  Widget build(BuildContext context) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    value: value,
    onChanged: onChanged,
    activeColor: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.primary,
    checkColor: Theme.of(context).colorScheme.surface,
    title: const Text(
      consentLabel,
      style: TextStyle(fontSize: 16, height: 1.5),
    ),
  );
}
