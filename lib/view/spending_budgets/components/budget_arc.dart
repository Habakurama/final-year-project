// lib/view/spending_budgets/components/budget_arc_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/common_widget/custom_arc_180_painter.dart';
import '../widgets/stat_card.dart';

class BudgetArcSection extends StatelessWidget {
  final BudgetController controller;
  final AnimationController? arcController;

  const BudgetArcSection({
    super.key,
    required this.controller,
    this.arcController,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildArcDisplay(context, media),
          const SizedBox(height: 20),
          _buildBudgetStats(context),
        ],
      ),
    );
  }

  Widget _buildArcDisplay(BuildContext context, Size media) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        arcController == null
            ? SizedBox(
                width: media.width * 0.6,
                height: media.width * 0.25,
              )
            : AnimatedBuilder(
                animation: arcController!,
                builder: (context, child) {
                  return SizedBox(
                    width: media.width * 0.6,
                    height: media.width * 0.25,
                    child: CustomPaint(
                      painter: CustomArcPainter(
                        totalBudget: controller.totalBudgetAmount.value,
                        usedBudget: controller.usedBudgetAmount.value,
                        end: (controller.totalBudgetAmount.value == 0)
                            ? 0
                            : ((controller.usedBudgetAmount.value /
                                        controller.totalBudgetAmount.value)
                                    .clamp(0.0, 1.0) *
                                arcController!.value),
                      ),
                    ),
                  );
                },
              ),
        Column(
          children: [
            const SizedBox(height: 10),
            Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    "${controller.totalBudgetAmount.value.toStringAsFixed(0)} Rwf",
                    key: ValueKey(controller.totalBudgetAmount.value),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 4),
            Text(
              "Total Budget",
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => StatCard(
                title: "Used",
                value: "${controller.usedBudgetAmount.value.toStringAsFixed(0)} Rwf",
                icon: Icons.trending_up,
                color: Colors.red,
              )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => StatCard(
                title: "Remaining",
                value: "${controller.remainingBudgetAmount.value.toStringAsFixed(0)} Rwf",
                icon: Icons.account_balance,
                color: Colors.green,
              )),
        ),
      ],
    );
  }
}