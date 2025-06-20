import 'package:flutter/material.dart';

class SavingsToggle extends StatelessWidget {
  final bool useFromSavings;
  final Function(bool?) onChanged;

  const SavingsToggle({
    super.key,
    required this.useFromSavings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Checkbox(
            value: useFromSavings,
            onChanged: onChanged,
          ),
          Expanded(
            child: Text(
              "Use money from savings (allows spending more than category budget)",
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}