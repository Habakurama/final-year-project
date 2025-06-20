import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../common/color_extension.dart';

class UpcomingBillRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const UpcomingBillRow({
    super.key,
    required this.sObj,
    required this.onPressed,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat monthFormat = DateFormat('MMM');
    final DateFormat dayFormat = DateFormat('dd');

    final date = sObj["date"] is String
        ? DateTime.parse(sObj["date"])
        : sObj["date"] ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 66,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? TColor.gray80
                : TColor.back,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                height: 42, // Increased from 37 to 42
                width: 42,  // Increased from 37 to 42 for better proportions
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                  children: [
                    Text(
                      monthFormat.format(date),
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 9, // Reduced from 10 to 9
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1), // Added small spacing
                    Text(
                      dayFormat.format(date),
                      style: TextStyle(
                        color: TColor.gray80,
                        fontSize: 13, // Reduced from 14 to 13
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sObj["name"] ?? "",
                  style: TextStyle(
                    color: TColor.gray60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${sObj["price"]} Frw',
                style: TextStyle(
                  color: TColor.gray80,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'update') {
                    onUpdate();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'update',
                    child: Text('Update'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}