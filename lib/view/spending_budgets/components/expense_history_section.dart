import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/common_widget/budgets_row.dart';

class ExpenseHistorySection extends StatelessWidget {
  final ExpenseController expenseController;

  const ExpenseHistorySection({
    super.key,
    required this.expenseController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 15),
        _buildExpenseList(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Expense Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context) {
    return Obx(() {
      if (expenseController.expenseStatusList.isEmpty) {
        return _buildEmptyState(context);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: expenseController.expenseStatusList.map((bObj) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BudgetsRow(
                bObj: bObj,
                onPressed: () {},
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No Categories Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first expense category to start tracking",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}