import 'package:flutter/material.dart';

class BudgetAlertDialog extends StatelessWidget {
  final double percentUsed;
  final VoidCallback onDismiss;

  const BudgetAlertDialog({
    super.key,
    required this.percentUsed,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Budget Alert'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have used ${percentUsed.toStringAsFixed(1)}% of your total budget.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Consider reviewing your spending to stay within budget.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}