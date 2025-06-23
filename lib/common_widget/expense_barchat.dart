
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';

import '../controller/expense_controller.dart';

class ExpenseBarChart extends StatelessWidget {
  final ExpenseController expenseCtrl = Get.find<ExpenseController>();

  ExpenseBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: expenseCtrl.fetchExpenseStatusForCurrentMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No expense data found'));
        }

        final data = snapshot.data!;
        final maxBudget = data.map((e) => e['budget'] as double).reduce((a, b) => a > b ? a : b);
        final double safeInterval = maxBudget > 0 ? maxBudget / 5 : 1.0;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: SizedBox(
                    width: data.length * 60,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < data.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Transform.rotate(
                                      angle: 35 * 3.1415927 / 180, // Convert degrees to radians
                                      child: Text(
                                        data[index]['category'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                  
                                  );
                                }
                                return const SizedBox();
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: safeInterval,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    'RWF ${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              },
                              reservedSize: 60,
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: safeInterval,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                            left: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            if (response != null &&
                                response.spot != null &&
                                event.isInterestedForInteractions) {
                              final tappedIndex = response.spot!.touchedBarGroupIndex;
                              if (tappedIndex >= 0 && tappedIndex < data.length) {
                                final tappedCategory = data[tappedIndex];
                                Get.dialog(
                                    AlertDialog(
                                      backgroundColor: Colors.transparent,  // Transparent background
                                      elevation: 0,  // Remove shadow
                                      contentPadding: EdgeInsets.zero,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  // Remove default padding
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: (tappedCategory['spendings'] as List<dynamic>).map((spending) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                  
                                              children: [
                                                Text(
                                                  spending['name'],
                                                  style: TextStyle(color: TColor.gray80),
                                                ),
                                                const SizedBox(width: 8,),
                                                Text(
                                                  "RWF ${spending['amount']}",
                                                  style: TextStyle(color: TColor.gray80),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                  
                                );
                              }
                            }
                          },
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.black.withOpacity(0.7),
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                'RWF ${rod.toY.round()}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        barGroups: data.asMap().entries.map((entry) {
                          int index = entry.key;
                          final item = entry.value;
                          final double budget = item['budget'];
                  
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: budget,
                                width: 18,
                                color: TColor.line,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        maxY: maxBudget * 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
