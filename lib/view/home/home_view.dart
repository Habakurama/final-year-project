import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/theme_controller.dart';

import 'components/home_header.dart';
import 'components/toggle_buttons.dart';
import 'components/expense_section.dart';
import 'components/income_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  bool isIncome = true;
  final SpendingController spendingCtrl = Get.put(SpendingController());
  final ThemeController themeController = Get.find();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBackground = Theme.of(context).cardColor;

    return GetBuilder<HomeController>(builder: (ctrl) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea( // Added SafeArea
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // Changed physics
            child: Column(
              mainAxisSize: MainAxisSize.min, // Added mainAxisSize
              children: [
                // Header Section
                HomeHeader(
                  fadeAnimation: _fadeAnimation,
                  spendingController: spendingCtrl,
                  homeController: ctrl,
                ),

                const SizedBox(height: 24),

                // Toggle Buttons
                HomeToggleButtons(
                  isIncome: isIncome,
                  onToggle: (value) => setState(() => isIncome = value),
                  cardBackground: cardBackground,
                ),

                const SizedBox(height: 24),

                // Content Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Added mainAxisSize
                    children: [
                      if (!isIncome)
                        IncomeSection(homeController: ctrl),
                      if (isIncome)
                        ExpenseSection(spendingController: spendingCtrl),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // Reduced from 100
              ],
            ),
          ),
        ),
      );
    });
  }
}