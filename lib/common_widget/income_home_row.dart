import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../common/color_extension.dart';

class IncomeHomeRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const IncomeHomeRow({
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
        ? DateTime.tryParse(sObj["date"]) ?? DateTime.now()
        : sObj["date"] ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? TColor.gray80 : TColor.back,

            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthFormat.format(date),
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? TColor.white : TColor.gray60,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dayFormat.format(date),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? TColor.white : TColor.gray60,
                        fontSize: 14,
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
                    color: Theme.of(context).brightness == Brightness.dark ? TColor.white : TColor.gray60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
              const SizedBox(width: 8),

              /// Dropdown Menu Button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: TColor.gray80),
                onSelected: (value) {
                  if (value == 'update') {
                    onUpdate();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'update',
                    child: Text('Update'),
                  ),
                  const PopupMenuItem<String>(
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
