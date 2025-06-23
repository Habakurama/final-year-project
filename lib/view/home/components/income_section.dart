// lib/view/home/components/income_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/home_controller.dart';
import '../../../common_widget/income_barchat.dart';
import '../../../common_widget/income_home_row.dart';
import '../../add_subscription/update_income_view.dart';
import 'shared_widgets.dart';

class IncomeSection extends StatelessWidget {
  final HomeController homeController;

  const IncomeSection({
    super.key,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = Theme.of(context).disabledColor;
    final cardBackground = Theme.of(context).cardColor;

    return Obx(() {
      if (homeController.income.isEmpty) {
        return SharedWidgets.buildEmptyState(
          "No Income This Month",
          "Start tracking your income to see insights here.",
          Icons.attach_money_outlined,
          textColor,
          grayColor,
        );
      }

      return SharedWidgets.buildContentSection(
        title: "Income Overview",
        child: Column(
          children: [
            Container(
              height: 350,
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
                child: IncomeBarChart(),
              ),
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: homeController.income.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final income = homeController.income[index];
                return SharedWidgets.buildEnhancedListItem(
                  context: context,
                  child: IncomeHomeRow(
                    sObj: {
                      "id": income.id,
                      "name": income.name,
                      "date": income.date,
                      "price": income.amount.toString()
                    },
                    onPressed: () {},
                    onUpdate: () {
                      Get.to(() => UpdateIncomeView(id: income.id!));
                    },
                    onDelete: () => SharedWidgets.showDeleteDialog(
                      context,
                      "income",
                      () => homeController.deleteIncome(income.id!),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        textColor: textColor,
        cardBackground: cardBackground,
      );
    });
  }
}