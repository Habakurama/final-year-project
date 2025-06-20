import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback? onPress; // Made nullable
  final Color color;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.title,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.onPress, // Removed required
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.line, // White background
          foregroundColor: Colors.black, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Border radius updated here
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shadowColor: TColor.gray.withOpacity(0.5),
          elevation: 5,
        ),
        onPressed: isLoading ? null : onPress, // Disable when loading
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: color,
                ),
              ),
      ),
    );
  }
}