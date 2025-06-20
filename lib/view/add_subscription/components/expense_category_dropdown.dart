import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/expense_controller.dart';

class ExpenseCategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final double selectedCategoryBudget;
  final Function(String?) onChanged;
  final ExpenseController expenseCtrl;

  const ExpenseCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.selectedCategoryBudget,
    required this.onChanged,
    required this.expenseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Obx(() {
        final List<Map<String, String>> categories =
            expenseCtrl.currentMonthCategories;

        if (categories.isEmpty) {
          return const Center(
            child: Text(
              "No categories available, please add expense first",
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select expense category",
                labelStyle: TextStyle(color: theme.disabledColor),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
              value: selectedCategory,
              items: categories.map((categoryMap) {
                return DropdownMenuItem<String>(
                  value: categoryMap['categoryId'],
                  child: Text(categoryMap['category'] ?? ''),
                );
              }).toList(),
              onChanged: onChanged,
            ),
            if (selectedCategoryBudget > 0) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Category Budget: ${selectedCategoryBudget.toStringAsFixed(0)} RWF",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}