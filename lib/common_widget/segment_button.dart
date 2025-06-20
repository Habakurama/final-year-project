import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class SegmentButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final bool isActive;

  const SegmentButton(
      {super.key,
      required this.title,
      required this.onPress,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      hoverColor: TColor.line,
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                color: isActive
                    ? TColor.line
                    : Colors.transparent, // green background if activ

                borderRadius: BorderRadius.circular(12),
              )
            : null,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white :Theme.of(context).brightness == Brightness.dark ? TColor.white : TColor.gray60,

            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
