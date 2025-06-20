import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class IncomeSegmentButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;

  const IncomeSegmentButton({
    super.key,
    required this.title,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      hoverColor: TColor.line,
      child: Container(
        alignment: Alignment.center,
        height: 40,
        decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? TColor.gray80 : TColor.white,

          borderRadius: BorderRadius.circular(12),
          border: Border.all( color: Theme.of(context).brightness == Brightness.dark ? TColor.gray80:Colors.grey.shade300
),
        ),
        child: Text(
          title,
          style:  TextStyle(
                     color: Theme.of(context).brightness == Brightness.dark ? TColor.white : TColor.gray80,

            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
