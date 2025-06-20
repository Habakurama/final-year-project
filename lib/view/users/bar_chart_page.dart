import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/view/users/ChatPage.dart';

class IncomeModel {
  final String name;
  final double amount;

  IncomeModel({required this.name, required this.amount});
}

class ExpenseModel {
  final String category;
  final double amount;

  ExpenseModel({required this.category, required this.amount});
}

class BarChartPage extends StatefulWidget {
  final String userId;

  const BarChartPage({super.key, required this.userId});

  @override
  State<BarChartPage> createState() => _BarChartPageState();
}

class _BarChartPageState extends State<BarChartPage> {
  List<IncomeModel> incomeData = [];
  List<ExpenseModel> expenseData = [];
  String userName = "User";

  @override
  void initState() {
    super.initState();
    loadChartData();
    loadUserName();
  }

  Future<void> loadUserName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['name'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  Future<void> loadChartData() async {
    final incomeSnap = await FirebaseFirestore.instance
        .collection('income')
        .where('userId', isEqualTo: widget.userId)
        .get();

    final expenseSnap = await FirebaseFirestore.instance
        .collection('expense')
        .where('userId', isEqualTo: widget.userId)
        .get();

    List<IncomeModel> incomes = incomeSnap.docs.map((doc) {
      final data = doc.data();
      return IncomeModel(
        name: data['name'] ?? 'Unknown',
        amount: double.tryParse(data['amount'].toString()) ?? 0,
      );
    }).toList();

    List<ExpenseModel> expenses = expenseSnap.docs.map((doc) {
      final data = doc.data();
      return ExpenseModel(
        category: data['category'] ?? 'Unknown',
        amount: double.tryParse(data['amount'].toString()) ?? 0,
      );
    }).toList();

    setState(() {
      incomeData = incomes;
      expenseData = expenses;
    });
  }

  Widget buildCombinedChart() {
    // Combine all unique categories/names
    Set<String> allCategories = {};
    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

    // Process income data
    for (var income in incomeData) {
      allCategories.add(income.name);
      incomeMap[income.name] = (incomeMap[income.name] ?? 0) + income.amount;
    }

    // Process expense data
    for (var expense in expenseData) {
      allCategories.add(expense.category);
      expenseMap[expense.category] = (expenseMap[expense.category] ?? 0) + expense.amount;
    }

    List<String> categories = allCategories.toList();

    return BarChart(
      BarChartData(
        barGroups: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final incomeAmount = incomeMap[category] ?? 0;
          final expenseAmount = expenseMap[category] ?? 0;

          List<BarChartRodData> rods = [];
          
          if (incomeAmount > 0) {
            rods.add(BarChartRodData(
              toY: incomeAmount,
              color: Colors.green,
              width: 15,
            ));
          }
          
          if (expenseAmount > 0) {
            rods.add(BarChartRodData(
              toY: expenseAmount,
              color: Colors.red,
              width: 15,
            ));
          }

          return BarChartGroupData(x: index, barRods: rods);
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, _) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K RWF',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= categories.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    categories[index],
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget buildIncomeChart() {
    return BarChart(
      BarChartData(
        barGroups: incomeData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: item.amount, color: Colors.green, width: 15),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, _) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K RWF',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= incomeData.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    incomeData[index].name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget buildExpenseChart() {
    return BarChart(
      BarChartData(
        barGroups: expenseData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: item.amount, color: Colors.red, width: 15),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, _) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K RWF',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= expenseData.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    expenseData[index].category,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget buildSummaryCard() {
    double totalIncome = incomeData.fold(0, (sum, item) => sum + item.amount);
    double totalExpenses = expenseData.fold(0, (sum, item) => sum + item.amount);
    double netBalance = totalIncome - totalExpenses;

  return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: TColor.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "$userName's Financial Summary",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.trending_up, color: Colors.green),
                        const SizedBox(height: 4),
                        const Text("Total Income", 
                             style: TextStyle(color: Colors.green, fontSize: 12)),
                        Text("${totalIncome.toStringAsFixed(0)} RWF", 
                             style: const TextStyle(
                               fontSize: 16, 
                               fontWeight: FontWeight.bold, 
                               color: Colors.green
                             )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.trending_down, color: Colors.red),
                        const SizedBox(height: 4),
                        const Text("Total Expenses", 
                             style: TextStyle(color: Colors.red, fontSize: 12)),
                        Text("${totalExpenses.toStringAsFixed(0)} RWF", 
                             style: const TextStyle(
                               fontSize: 16, 
                               fontWeight: FontWeight.bold, 
                               color: Colors.red
                             )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: netBalance >= 0 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: netBalance >= 0 ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    netBalance >= 0 ? Icons.savings : Icons.warning,
                    color: netBalance >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Net Balance",
                    style: TextStyle(
                      color: netBalance >= 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "${netBalance.toStringAsFixed(0)} RWF",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: netBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = incomeData.isEmpty && expenseData.isEmpty;

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Theme.of(context).brightness == Brightness.dark
      ? TColor.gray60
      : TColor.back,
  title: Text(
    "$userName's Financial Chart",
    style: TextStyle(
      color: Theme.of(context).brightness == Brightness.dark
          ? TColor.white
          : TColor.gray60,
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(
        Icons.message,
        color: Theme.of(context).primaryColor
      ),
      onPressed: () {
       Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatPage(widget.userId),
  ),
);

      },
    ),
  ],
),


      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  buildSummaryCard(),
                  
                  // Combined Chart
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("Combined Overview", 
                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Row(
                              children: [
                                Container(width: 12, height: 12, color: Colors.green),
                                const Text(" Income", style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 10),
                                Container(width: 12, height: 12, color: Colors.red),
                                const Text(" Expenses", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 300, child: buildCombinedChart()),
                      ],
                    ),
                  ),

                  // Individual Charts
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Income Breakdown", 
                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 250, child: buildIncomeChart()),

                        const SizedBox(height: 24),
                        const Text("Expense Breakdown", 
                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 250, child: buildExpenseChart()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}