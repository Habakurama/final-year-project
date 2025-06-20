// lib/view/home/components/shared_widgets.dart
import 'package:flutter/material.dart';

class SharedWidgets {
  static Widget buildContentSection({
    required String title,
    required Widget child,
    required Color textColor,
    required Color cardBackground,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        child,
      ],
    );
  }

  static Widget buildEnhancedListItem({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  static Widget buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    Color textColor,
    Color grayColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: grayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 48,
              color: grayColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: grayColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static void showDeleteDialog(
    BuildContext context,
    String type,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Deletion",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Are you sure you want to delete this $type?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }
}