import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/spending_controller.dart';
import '../common/color_extension.dart';

class BudgetsRow extends StatefulWidget {
  final Map bObj;
  final VoidCallback onPressed;

  const BudgetsRow({
    super.key,
    required this.bObj,
    required this.onPressed,
  });

  @override
  State<BudgetsRow> createState() => _BudgetsRowState();
}

class _BudgetsRowState extends State<BudgetsRow> {
  double? _lastRemainingAmount;
  String? _currentCategoryId;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void didUpdateWidget(BudgetsRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    _checkForRemainingAmountChange();
  }

  void _initializeTracking() {
    String categoryId = widget.bObj["expenseId"]?.toString() ?? "";
    double remainingAmount =
        double.tryParse(widget.bObj["remaining"]?.toString() ?? "0") ?? 0;

    _currentCategoryId = categoryId;
    _lastRemainingAmount = remainingAmount;
  }

  void _checkForRemainingAmountChange() {
    String categoryId = widget.bObj["expenseId"]?.toString() ?? "";
    double currentRemainingAmount =
        double.tryParse(widget.bObj["remaining"]?.toString() ?? "0") ?? 0;

    if (categoryId.isNotEmpty &&
        categoryId == _currentCategoryId &&
        _lastRemainingAmount != null &&
        _lastRemainingAmount != currentRemainingAmount) {
     
      _lastRemainingAmount = currentRemainingAmount;
    } else {}
  }

  

  void _showEditCategoryDialog(
      String categoryId, String currentName, String expenseId) {
    TextEditingController nameCtrl = TextEditingController(text: currentName);
    TextEditingController amountCtrl = TextEditingController(
      text: widget.bObj["budget"]?.toString() ?? "0",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newCategory = nameCtrl.text.trim();
              final newAmount = double.tryParse(amountCtrl.text.trim()) ??
                  (double.tryParse(widget.bObj["budget"]?.toString() ?? "0") ??
                      0);

              if (newCategory.isNotEmpty) {
                Get.find<ExpenseController>().updateExpense(
                  expenseId: categoryId,
                  newCategory: newCategory,
                  newAmount: newAmount,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // void _showDeleteCategoryConfirm(String categoryId) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Delete Category"),
  //       content: const Text("Are you sure you want to delete this category?"),
  //       actions: [
  //         TextButton(
  //             onPressed: () {
  //               Get.find<ExpenseController>().deleteExpense(categoryId);
  //               Navigator.pop(context);
  //             },
  //             child: const Text("Delete")),
  //         TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Cancel")),
  //       ],
  //     ),
  //   );
  // }

  void _showEditSpendingDialog(String spendingId, String currentName,
      double currentAmount, String expenseId) {
    TextEditingController nameCtrl = TextEditingController(text: currentName);
    TextEditingController amountCtrl =
        TextEditingController(text: currentAmount.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Spending"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              final newAmount =
                  double.tryParse(amountCtrl.text.trim()) ?? currentAmount;

              if (newName.isNotEmpty) {
                final spendingController = Get.find<SpendingController>();
                spendingController
                    .updateSpending2(
                  spendingId,
                  newAmount,
                  newName,
                  expenseId,
                )
                    .then((_) {
                  // Recalculate used and remaining
                  return spendingController
                      .recalculateUsedAndRemaining(expenseId);
                }).then((_) {
                  // Force refresh of expense controller data
                  final expenseController = Get.find<ExpenseController>();
                  return expenseController.currentMonthExpenses;
                }).then((_) {
                  // Force a check for remaining amount change after update
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {}); // This will trigger didUpdateWidget
                    }
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
        ],
      ),
    );
  }

  void _showDeleteSpendingConfirm(String spendingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Spending"),
        content: const Text("Are you sure you want to delete this spending?"),
        actions: [
          TextButton(
              onPressed: () {
                final spendingController = Get.find<SpendingController>();
                spendingController.deleteSpending(spendingId).then((_) {
                  return spendingController.recalculateUsedAndRemaining(
                      widget.bObj["expenseId"]?.toString() ?? "");
                }).then((_) {
                  // Force refresh of expense controller data
                  final expenseController = Get.find<ExpenseController>();
                  return expenseController.currentMonthExpenses;
                }).then((_) {
                  // Force a check for remaining amount change after deletion
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {}); // This will trigger didUpdateWidget
                    }
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Delete")),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
        ],
      ),
    );
  }

  // ADDED: Missing _showAllSpendingsDialog method
  void _showAllSpendingsDialog() {
    final spendings = (widget.bObj["spendings"] as List?) ?? [];
    String categoryId = widget.bObj["expenseId"]?.toString() ?? "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("All Spendings - ${widget.bObj["category"]}"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: spendings.length,
            itemBuilder: (context, index) {
              final spending = spendings[index];
              String spendingName = spending["name"] ?? "";
              String spendingId = spending["spendingId"] ?? "";
              double amount = (spending["amount"] as num?)?.toDouble() ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          spendingName,
                          style: TextStyle(
                            color: TColor.gray80,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "${amount.toStringAsFixed(0)} Rwf",
                            style: TextStyle(
                              color: TColor.gray60,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.pop(context); // Close dialog first
                                _showEditSpendingDialog(spendingId,
                                    spendingName, amount, categoryId);
                              } else if (value == 'delete') {
                                Navigator.pop(context); // Close dialog first
                                _showDeleteSpendingConfirm(spendingId);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              // const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var usedAmount =
        double.tryParse(widget.bObj["used"]?.toString() ?? "0") ?? 0;
    var remainingAmount =
        double.tryParse(widget.bObj["remaining"]?.toString() ?? "0") ?? 0;
    var totalBudget =
        double.tryParse(widget.bObj["budget"]?.toString() ?? "1") ?? 1;
    var proVal = usedAmount / totalBudget;
    var category = widget.bObj["category"] ?? "";
    String categoryId = widget.bObj["expenseId"]?.toString() ?? "";

    // Debug logging for build method
    print("🏗️ Building BudgetsRow for category: $category");
    print(
        "   Used: $usedAmount, Remaining: $remainingAmount, Budget: $totalBudget");
    print(
        "   Spendings count: ${(widget.bObj["spendings"] as List?)?.length ?? 0}");
    print(
        "🔍 About to build ${(widget.bObj["spendings"] as List?)?.length ?? 0} spending items");

    return GetBuilder<ExpenseController>(builder: (ctrl) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: TColor.border.withOpacity(0.05),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? TColor.gray80
                  : TColor.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side: category name
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TColor.white
                              : TColor.gray60,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Right side: amount + menu
                    Row(
                      children: [
                        Text(
                          "${widget.bObj["budget"]} Rwf",
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? TColor.white.withOpacity(0.9)
                                    : TColor.gray60.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditCategoryDialog(
                                  categoryId, category, categoryId);
                            } 
                            // else if (value == 'delete') {
                            //   _showDeleteCategoryConfirm(categoryId);
                            // }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            // const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Used: ${usedAmount.toStringAsFixed(0)} Rwf",
                        style: TextStyle(
                            color: TColor.gray60,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    Text("Remaining: ${remainingAmount.toStringAsFixed(0)} Rwf",
                        style: TextStyle(
                            color: TColor.gray60,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),

                // SHOW ONLY FIRST 2 SPENDINGS
                ...(() {
                  final spendings = (widget.bObj["spendings"] as List?) ?? [];
                  final displaySpendings = spendings.take(2).toList();

                  return displaySpendings.map<Widget>((spending) {
                    String spendingName = spending["name"] ?? "";
                    String spendingId = spending["spendingId"] ?? "";
                    double amount =
                        (spending["amount"] as num?)?.toDouble() ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              spendingName,
                              style:
                                  TextStyle(color: TColor.gray80, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text("${amount.toStringAsFixed(0)} Rwf",
                                  style: TextStyle(
                                      color: TColor.gray60, fontSize: 12)),
                              const SizedBox(width: 4),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditSpendingDialog(spendingId,
                                        spendingName, amount, categoryId);
                                  } else if (value == 'delete') {
                                    _showDeleteSpendingConfirm(spendingId);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                  // const PopupMenuItem(
                                  //     value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList();
                })(),

                // VIEW MORE BUTTON - FIXED: Now uses TColor.primary
                if (((widget.bObj["spendings"] as List?)?.length ?? 0) > 2) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      _showAllSpendingsDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "View ${((widget.bObj["spendings"] as List?)?.length ?? 0) - 2} more",
                            style: TextStyle(
                              color:
                                  TColor.primary, // FIXED: Using TColor.primary
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color:
                                TColor.primary, // FIXED: Using TColor.primary
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: TColor.gray60,
                  valueColor: AlwaysStoppedAnimation(
                      widget.bObj["color"] ?? TColor.line),
                  minHeight: 1,
                  value: proVal > 1.0 ? 1.0 : proVal,
                ),
                if (remainingAmount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule,
                            size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                            "Auto-save: ${remainingAmount.toStringAsFixed(0)} Rwf",
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
