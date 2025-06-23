import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/view/users/ChatPage.dart';

class IncomeModel {
  final String name;
  final double amount;
  final bool shared;

  IncomeModel({required this.name, required this.amount, required this.shared});
}

class ExpenseModel {
  final String category;
  final double amount;
  final bool shared;

  ExpenseModel({required this.category, required this.amount, required this.shared});
}

class BarChartPage extends StatefulWidget {
  final String userId;
  final String? currentUserId;

  const BarChartPage({super.key, required this.userId, this.currentUserId});

  @override
  State<BarChartPage> createState() => _BarChartPageState();
}

class _BarChartPageState extends State<BarChartPage> {
  List<IncomeModel> incomeData = [];
  List<ExpenseModel> expenseData = [];
  String userName = "User";
  bool isLoading = true;
  String? actualCurrentUserId;

  // Track the actual data state
  bool hasAnyData = false;
  bool hasAnySharedData = false;

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
    loadUserData();
  }

  // Initialize current user ID properly
  void _initializeCurrentUser() {
    actualCurrentUserId = widget.currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
  }

  // Check if current user is viewing their own data
  bool get isCurrentUser => actualCurrentUserId == widget.userId;

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });

    await Future.wait([
      loadUserName(),
      loadChartData(),
    ]);

    setState(() {
      isLoading = false;
    });
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
    try {
      final incomeSnap = await FirebaseFirestore.instance
          .collection('income')
          .where('userId', isEqualTo: widget.userId)
          .get();

      final expenseSnap = await FirebaseFirestore.instance
          .collection('expense')
          .where('userId', isEqualTo: widget.userId)
          .get();

      // Debug: Print raw data
      print('=== DEBUG: Raw Income Data ===');
      for (var doc in incomeSnap.docs) {
        print('Income Doc: ${doc.data()}');
      }

      print('=== DEBUG: Raw Expense Data ===');
      for (var doc in expenseSnap.docs) {
        print('Expense Doc: ${doc.data()}');
      }

      List<IncomeModel> allIncomes = incomeSnap.docs.map((doc) {
        final data = doc.data();
        final sharedValue = data['shared'];
        print('Income shared field: $sharedValue (type: ${sharedValue.runtimeType})');

        return IncomeModel(
          name: data['name'] ?? 'Unknown',
          amount: double.tryParse(data['amount'].toString()) ?? 0,
          shared: _parseSharedField(sharedValue),
        );
      }).toList();

      List<ExpenseModel> allExpenses = expenseSnap.docs.map((doc) {
        final data = doc.data();
        final sharedValue = data['shared'];
        print('Expense shared field: $sharedValue (type: ${sharedValue.runtimeType})');

        return ExpenseModel(
          category: data['category'] ?? 'Unknown',
          amount: double.tryParse(data['amount'].toString()) ?? 0,
          shared: _parseSharedField(sharedValue),
        );
      }).toList();

      // Debug: Print parsed data
      print('=== DEBUG: Parsed Income Data ===');
      for (var income in allIncomes) {
        print('Income: ${income.name}, Amount: ${income.amount}, Shared: ${income.shared}');
      }

      print('=== DEBUG: Parsed Expense Data ===');
      for (var expense in allExpenses) {
        print('Expense: ${expense.category}, Amount: ${expense.amount}, Shared: ${expense.shared}');
      }

      // Check if there's any data at all
      hasAnyData = allIncomes.isNotEmpty || allExpenses.isNotEmpty;

      // Check if there's any shared data BEFORE filtering
      hasAnySharedData = allIncomes.any((income) => income.shared) ||
          allExpenses.any((expense) => expense.shared);

      print('=== DEBUG: Data Status ===');
      print('hasAnyData: $hasAnyData');
      print('hasAnySharedData: $hasAnySharedData');
      print('isCurrentUser: $isCurrentUser');

      setState(() {
        if (isCurrentUser) {
          // Current user sees ALL their data (both shared and private)
          incomeData = allIncomes;
          expenseData = allExpenses;
          print('Current user - showing all data. Income: ${incomeData.length}, Expense: ${expenseData.length}');
        } else {
          // Other users see only shared data
          incomeData = allIncomes.where((income) => income.shared).toList();
          expenseData = allExpenses.where((expense) => expense.shared).toList();

          print('Other user - showing shared data only. Income: ${incomeData.length}, Expense: ${expenseData.length}');
          print('Filtered Income Data:');
          for (var income in incomeData) {
            print('  - ${income.name}: ${income.amount} (shared: ${income.shared})');
          }
          print('Filtered Expense Data:');
          for (var expense in expenseData) {
            print('  - ${expense.category}: ${expense.amount} (shared: ${expense.shared})');
          }
        }
      });
    } catch (e) {
      print('Error loading chart data: $e');
    }
  }

  // Helper method to properly parse the shared field
  bool _parseSharedField(dynamic sharedValue) {
    if (sharedValue == null) return false;
    if (sharedValue is bool) return sharedValue;
    if (sharedValue is String) {
      return sharedValue.toLowerCase() == 'true';
    }
    if (sharedValue is int) return sharedValue == 1;
    return false;
  }

  Widget buildPrivacyMessage() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: TColor.gray30,
              ),
              const SizedBox(height: 16),
              Text(
                "Financial Data is Private",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.gray60,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$userName has chosen to keep their financial information private.",
                style: TextStyle(
                  fontSize: 14,
                  color: TColor.gray40,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(widget.userId),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text("Send Message"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.line,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNoDataMessage() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: TColor.gray30,
              ),
              const SizedBox(height: 16),
              Text(
                isCurrentUser ? "No Financial Data" : "No Shared Financial Data",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.gray60,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCurrentUser
                    ? "You haven't added any financial data yet."
                    : "$userName hasn't shared any financial data yet.",
                style: TextStyle(
                  fontSize: 14,
                  color: TColor.gray40,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCombinedChart() {
    Set<String> allCategories = {};
    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

    for (var income in incomeData) {
      allCategories.add(income.name);
      incomeMap[income.name] = (incomeMap[income.name] ?? 0) + income.amount;
    }

    for (var expense in expenseData) {
      allCategories.add(expense.category);
      expenseMap[expense.category] = (expenseMap[expense.category] ?? 0) + expense.amount;
    }

    List<String> categories = allCategories.toList();

    if (categories.isEmpty) {
      return Center(
        child: Text(
          "No data available for combined chart",
          style: TextStyle(color: TColor.gray40),
        ),
      );
    }

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

          // If no data for this category, add a minimal rod to show the category
          if (rods.isEmpty) {
            rods.add(BarChartRodData(
              toY: 0.1,
              color: Colors.transparent,
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

                String displayText = categories[index];
                if (displayText.length > 8) {
                  displayText = '${displayText.substring(0, 8)}...';
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    displayText,
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
        maxY: _getMaxY([...incomeData.map((e) => e.amount), ...expenseData.map((e) => e.amount)]),
      ),
    );
  }

  Widget buildIncomeChart() {
    Map<String, double> incomeMap = {};

    for (var income in incomeData) {
      incomeMap[income.name] = (incomeMap[income.name] ?? 0) + income.amount;
    }

    List<String> categories = incomeMap.keys.toList();

    if (categories.isEmpty) {
      return Center(
        child: Text(
          "No income data available",
          style: TextStyle(color: TColor.gray40),
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final amount = incomeMap[category] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: Colors.green,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
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
                if (index < 0 || index >= categories.length) return const SizedBox.shrink();

                String displayText = categories[index];
                if (displayText.length > 8) {
                  displayText = '${displayText.substring(0, 8)}...';
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    displayText,
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
        maxY: _getMaxY(incomeData.map((e) => e.amount).toList()),
      ),
    );
  }

  Widget buildExpenseChart() {
    Map<String, double> expenseMap = {};

    for (var expense in expenseData) {
      expenseMap[expense.category] = (expenseMap[expense.category] ?? 0) + expense.amount;
    }

    List<String> categories = expenseMap.keys.toList();

    if (categories.isEmpty) {
      return Center(
        child: Text(
          "No expense data available",
          style: TextStyle(color: TColor.gray40),
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final amount = expenseMap[category] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: Colors.red,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
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
                if (index < 0 || index >= categories.length) return const SizedBox.shrink();

                String displayText = categories[index];
                if (displayText.length > 8) {
                  displayText = '${displayText.substring(0, 8)}...';
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    displayText,
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
        maxY: _getMaxY(expenseData.map((e) => e.amount).toList()),
      ),
    );
  }

  // Helper method to calculate appropriate max Y value
  double _getMaxY(List<double> values) {
    if (values.isEmpty) return 100;
    double maxValue = values.reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Add 20% padding
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
                  isCurrentUser
                      ? "Your Financial Summary"
                      : "$userName's Shared Financial",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                        Text(
                          isCurrentUser ? "Total Income" : "Shared Income",
                          style: const TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        Text(
                          "${totalIncome.toStringAsFixed(0)} RWF",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
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
                        Text(
                          isCurrentUser ? "Total Expenses" : "Shared Expenses",
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        Text(
                          "${totalExpenses.toStringAsFixed(0)} RWF",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
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

  Widget buildChartSection(String title, Widget chart, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    title == "Combined Overview"
                        ? Icons.analytics
                        : title == "Income Analysis"
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (title == "Combined Overview") ...[
                    const Spacer(),
                    Row(
                      children: [
                        Container(width: 12, height: 12, color: Colors.green),
                        const Text(" Income", style: TextStyle(fontSize: 8)),
                        const SizedBox(width: 8),
                        Container(width: 12, height: 12, color: Colors.red),
                        const Text(" Expenses", style: TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: chart),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? TColor.gray80
            : TColor.back,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? TColor.white
              : TColor.gray60,
        ),
        title: Text(
          isCurrentUser
              ? "Your Financial Charts"
              : "$userName's Financial Charts",
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
              color: Theme.of(context).primaryColor,
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
          : _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    print('=== DEBUG: _buildBodyContent ===');
    print('isCurrentUser: $isCurrentUser');
    print('hasAnyData: $hasAnyData');
    print('hasAnySharedData: $hasAnySharedData');
    print('incomeData.length: ${incomeData.length}');
    print('expenseData.length: ${expenseData.length}');

    // For current user viewing their own data
    if (isCurrentUser) {
      if (!hasAnyData) {
        return buildNoDataMessage(); // Show no data message
      } else {
        return _buildChartsView(); // Show charts with all their data
      }
    }

    // For viewing someone else's data
    else {
      // If they have no data at all
      if (!hasAnyData) {
        return buildNoDataMessage();
      }
      // If they have data but none is shared
      else if (!hasAnySharedData) {
        return buildPrivacyMessage();
      }
      // If they have shared data to display
      else {
        return _buildChartsView();
      }
    }
  }

  Widget _buildChartsView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSummaryCard(),
          buildChartSection("Combined Overview", buildCombinedChart(), TColor.primary),
          buildChartSection("Income Analysis", buildIncomeChart(), Colors.green),
          buildChartSection("Expense Analysis", buildExpenseChart(), Colors.red),
        ],
      ),
    );
  }
}