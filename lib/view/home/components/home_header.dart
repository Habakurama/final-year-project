// lib/view/home/components/home_header.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/view/settings/settings_view.dart';
import 'stat_card.dart';

class HomeHeader extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final SpendingController spendingController;
  final HomeController homeController;

  const HomeHeader({
    super.key,
    required this.fadeAnimation,
    required this.spendingController,
    required this.homeController,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Reactive variable for total savings
  final RxDouble totalSavings = 0.0.obs;

  @override
  void initState() {
    super.initState();
    fetchTotalSavings();
  }

  // Fetch total savings directly in this file
  Future<void> fetchTotalSavings() async {
    try {
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        ;
        totalSavings.value = 0.0;
        return;
      }

      String userId = currentUser.uid;

      // Query savings for current user
      QuerySnapshot savingsSnapshot = await firestore
          .collection('saving')
          .where('userId', isEqualTo: userId)
          .get();

      double totalSavingsAmount = 0.0;

      // Process each saving document
      for (QueryDocumentSnapshot doc in savingsSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          double amount = 0.0;
          var rawAmount = data['amount'];

          if (rawAmount != null) {
            if (rawAmount is num) {
              amount = rawAmount.toDouble();
            } else if (rawAmount is String) {
              amount = double.tryParse(rawAmount) ?? 0.0;
            }
          }

          totalSavingsAmount += amount;
        } catch (e) {
          continue; // Skip this document and continue with others
        }
      }

      // Update the reactive variable
      totalSavings.value = totalSavingsAmount;
    } catch (e) {
      totalSavings.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = Theme.of(context).disabledColor;
    final cardBackground = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            TColor.gray60.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header with Welcome Text
              _buildWelcomeHeader(
                  context, textColor, grayColor, cardBackground),

              const SizedBox(height: 30),

              // Central Content - Monthly Stats
              _buildMonthlyStats(
                  context, textColor, grayColor, cardBackground, primaryColor),

              const SizedBox(height: 24),

              // Statistics Cards
              _buildStatisticsCards(
                  context, cardBackground, textColor, grayColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, Color textColor,
      Color grayColor, Color cardBackground) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: widget.fadeAnimation,
              child: Text(
                "Welcome back!",
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FadeTransition(
              opacity: widget.fadeAnimation,
              child: Text(
                "Financial Overview",
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsView(),
                ),
              );
            },
            icon: Icon(
              Icons.settings_outlined,
              size: 24,
              color: grayColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats(BuildContext context, Color textColor,
      Color grayColor, Color cardBackground, Color primaryColor) {
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        children: [
          // Monthly Expense
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cardBackground.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: grayColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Obx(() => Text(
                      "${widget.spendingController.totalAmountSpending.value.toStringAsFixed(2)} Frw",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    )),
                const SizedBox(height: 4),
                Text(
                  "Monthly Expenses",
                  style: TextStyle(
                    color: grayColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Monthly Income
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cardBackground.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: grayColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Obx(() => Text(
                      "${widget.homeController.totalIncome.value.toStringAsFixed(0)} Frw",
                      style: TextStyle(
                        color:textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    )),
                const SizedBox(height: 4),
                Text(
                  "Monthly Income",
                  style: TextStyle(
                    color: grayColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Total Savings - Now using local totalSavings variable
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cardBackground.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          "${totalSavings.value.toStringAsFixed(2)} Frw",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        )),
                    IconButton(
                      onPressed: fetchTotalSavings,
                      icon: const Icon(
                        Icons.refresh,
                        size: 20,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Total Savings",
                  style: TextStyle(
                    color: grayColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, Color cardBackground,
      Color textColor, Color grayColor) {
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Row(
        children: [
          Obx(() => StatCard(
                title: "Total expenses",
                value: widget.spendingController.totalSpendingCount.value
                    .toString(),
                icon: Icons.receipt_long_outlined,
                cardBackground: cardBackground,
                textColor: textColor,
                grayColor: grayColor,
                accentColor: Colors.orange,
              )),
          const SizedBox(width: 8),
          Obx(() => StatCard(
                title: "Lowest expense",
                value:
                    "${widget.spendingController.lowestSpending.value.toStringAsFixed(0)}",
                icon: Icons.trending_down_outlined,
                cardBackground: cardBackground,
                textColor: textColor,
                grayColor: grayColor,
                accentColor: Colors.green,
              )),
          const SizedBox(width: 8),
          Obx(() => StatCard(
                title: "Highest expense",
                value:
                    "${widget.spendingController.highestSpending.value.toStringAsFixed(0)}",
                icon: Icons.trending_up_outlined,
                cardBackground: cardBackground,
                textColor: textColor,
                grayColor: grayColor,
                accentColor: Colors.red,
              )),
        ],
      ),
    );
  }
}
