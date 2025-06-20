// lib/view/spending_budgets/components/budget_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/view/budget/add_budget_screen.dart';
import 'package:untitled/view/budget/update_budget_screen.dart';

class BudgetCard extends StatelessWidget {
  final BudgetController controller;
  final Animation<double>? scaleAnimation;

  const BudgetCard({
    super.key,
    required this.controller,
    this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBudget = controller.budgetList.isNotEmpty;
    final bObj = hasBudget ? controller.budgetList.first : null;

    Widget cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: _buildCardContent(context, bObj),
    );

    if (scaleAnimation == null) {
      return cardContent;
    }

    return AnimatedBuilder(
      animation: scaleAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation!.value,
          child: cardContent,
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context, dynamic bObj) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Budget Management",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your spending limits and progress",
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
            ),
            if (bObj != null) _buildPopupMenu(context, bObj),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddBudgetScreen()),
            icon: const Icon(Icons.add),
            label: const Text("Manage Budget"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context, dynamic bObj) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.more_vert,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
      ),
      onSelected: (value) {
        if (value == 'update') {
          _handleUpdate(bObj);
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'update',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Update Budget'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleUpdate(dynamic bObj) {
    DateTime toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    Get.to(() => UpdateBudgetScreen(
          budgetId: bObj['id'] ?? '',
          initialAmount: bObj['amount'] ?? 0.0,
          initialStartDate: toDate(bObj['startDate']),
          initialEndDate: toDate(bObj['endDate']),
        ));
  }
}