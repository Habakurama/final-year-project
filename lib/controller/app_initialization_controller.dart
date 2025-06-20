import 'package:get/get.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/spending_controller.dart';

import 'budgetController.dart';

import 'home_controller.dart';

class AppInitializationController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();

  final BudgetController budgetController = Get.find<BudgetController>();
  final SpendingController spendingController = Get.find<SpendingController>();
  final ExpenseController expenseController = Get.find<ExpenseController>();

  // Method to initialize all the controllers
  Future<void> initialize() async {

    spendingController.fetchSpendingStats();
    spendingController.fetchUserSpendings();
    homeController.fetchIncome();
    homeController.calculateMonthlyIncome();
    expenseController.fetchCategories();
    budgetController.fetchBudgetStatus();
    budgetController.fetchBudget();
    expenseController.loadExpenseStatus();



  }
}
