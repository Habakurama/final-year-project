
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class IconItemRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const IconItemRow({
    Key? key,
    required this.title,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
color: Theme.of(context).brightness == Brightness.dark ? TColor.white : TColor.gray70,

                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: TColor.white,
                backgroundColor: TColor.line,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}
