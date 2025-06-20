import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPress;
  final Color color;

  const SecondaryButton(
      {super.key,
      required this.title,
      this.fontSize = 14,
      this.fontWeight = FontWeight.w600,
      required this.onPress,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/img/secondary.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: fontWeight),
        ),
      ),
    );
  }
}
