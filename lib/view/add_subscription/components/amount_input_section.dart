import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/spending_controller.dart';

class AmountInputSection extends StatelessWidget {
  final bool useFromSavings;
  final SpendingController spendingCtrl;
  final TextEditingController regularAmountCtrl;
  final TextEditingController savingAmountCtrl;

  const AmountInputSection({
    super.key,
    required this.useFromSavings,
    required this.spendingCtrl,
    required this.regularAmountCtrl,
    required this.savingAmountCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          if (useFromSavings) ...[
            // Show auto-calculated total with breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Amount (Auto-calculated)",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${spendingCtrl.subAmountCtrl.text} RWF",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: TColor.line,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (spendingCtrl.subAmountCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Regular: ${regularAmountCtrl.text} RWF + Savings: ${savingAmountCtrl.text} RWF",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Regular amount input when not using savings
            RoundedTextField(
              title: "Total Amount (RWF)",
              titleAlign: TextAlign.center,
              controller: spendingCtrl.subAmountCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }
}
