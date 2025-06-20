// lib/view/home/components/expense_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/spending_controller.dart';
import '../../../common_widget/expense_barchat.dart';
import '../../../common_widget/up_coming_bill_row.dart';
import '../../add_subscription/update_expense.dart';
import 'shared_widgets.dart';

class ExpenseSection extends StatefulWidget {
  final SpendingController spendingController;
  
  const ExpenseSection({
    super.key,
    required this.spendingController,
  });

  @override
  State<ExpenseSection> createState() => _ExpenseSectionState();
}

class _ExpenseSectionState extends State<ExpenseSection> {
  bool showAll = false;
  final int initialDisplayCount = 2;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = Theme.of(context).disabledColor;
    final cardBackground = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).primaryColor;

    return Obx(() {
      if (widget.spendingController.spending.isEmpty) {
        return SharedWidgets.buildEmptyState(
          "No Expenses This Month",
          "Start tracking your expenses to see insights here.",
          Icons.receipt_outlined,
          textColor,
          grayColor,
        );
      }

      final totalExpenses = widget.spendingController.spending.length;
      final displayCount = showAll ? totalExpenses : 
          (totalExpenses > initialDisplayCount ? initialDisplayCount : totalExpenses);
      final hasMoreItems = totalExpenses > initialDisplayCount;

      return SharedWidgets.buildContentSection(
        title: "Expense Overview",
        child: Column(
          children: [
            // Chart Container
            Container(
              height: 300,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExpenseBarChart(),
              ),
            ),
            
            // Expenses List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: displayCount,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final spent = widget.spendingController.spending[index];
                return SharedWidgets.buildEnhancedListItem(
                  context: context,
                  child: UpcomingBillRow(
                    sObj: {
                      "id": spent['id'],
                      "name": spent['name'],
                      "date": (spent['date'] as Timestamp).toDate(),
                      "price": spent['amount'].toString()
                    },
                    onUpdate: () {
                      Get.to(() => UpdateExpenseView(spent['id']));
                    },
                    onDelete: () => SharedWidgets.showDeleteDialog(
                      context,
                      "expense",
                      () => widget.spendingController.deleteSpending(spent['id']),
                    ),
                    onPressed: () {},
                  ),
                );
              },
            ),
            
            // View All / View Less Button
            if (hasMoreItems)
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showAll = !showAll;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 7
                    ),
                    // decoration: BoxDecoration(
                    //   color: cardBackground,
                    //   borderRadius: BorderRadius.circular(8),
                    //   border: Border.all(
                    //     color: primaryColor.withOpacity(0.3),
                    //     width: 1,
                    //   ),
                    // ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showAll ? 'View Less' : 'View All (${totalExpenses})',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          showAll ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: primaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Summary text when collapsed
            if (!showAll && hasMoreItems)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Showing ${displayCount} of ${totalExpenses} expenses',
                  style: TextStyle(
                    color: grayColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        textColor: textColor,
        cardBackground: cardBackground,
      );
    });
  }
}