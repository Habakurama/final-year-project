import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/home_controller.dart';

class IncomeBarChart extends StatelessWidget {
  IncomeBarChart({super.key});

  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final incomeList = homeController.income;

      if (incomeList.isEmpty) {
        return const Center(child: Text("No income data found"));
      }

      
      final maxIncome = incomeList.map((e) => e.amount ?? 0.0).fold(0.0, (a, b) => a > b ? a : b);
      final safeInterval = maxIncome > 0 ? maxIncome / 5 : 1.0;

      return SizedBox(
        height: 300, 
        
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Income by Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 30),
              Expanded( 
                child: SizedBox(
                  width: incomeList.length * 60.0, 
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxIncome * 1.2,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < incomeList.length) {
                                return Transform.rotate(
                                  angle: 0.5,
                                  child: Text(
                                    incomeList[index].name ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: safeInterval,
                            reservedSize: 50,
                            getTitlesWidget: (value, _) => Text(
                              'RWF ${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: safeInterval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade400),
                          left: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      barGroups: incomeList.asMap().entries.map((entry) {
                        int index = entry.key;
                        final income = entry.value;
                        final double amount = income.amount ?? 0.0;
                
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: amount,
                              width: 20,
                              color: Colors.green.shade600,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
