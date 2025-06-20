// lib/view/home/components/toggle_buttons.dart
import 'package:flutter/material.dart';
import '../../../common_widget/segment_button.dart';

class HomeToggleButtons extends StatelessWidget {
  final bool isIncome;
  final ValueChanged<bool> onToggle;
  final Color cardBackground;

  const HomeToggleButtons({
    super.key,
    required this.isIncome,
    required this.onToggle,
    required this.cardBackground,
  });

  @override
  Widget build(BuildContext context) {
    final grayColor = Theme.of(context).disabledColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: grayColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentButton(
              title: 'Expenses',
              onPress: () => onToggle(true),
              isActive: isIncome,
            ),
          ),
          Expanded(
            child: SegmentButton(
              title: 'Income',
              onPress: () => onToggle(false),
              isActive: !isIncome,
            ),
          ),
        ],
      ),
    );
  }
}