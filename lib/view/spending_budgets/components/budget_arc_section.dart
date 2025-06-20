import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/home_controller.dart';

class BudgetController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final homeController = Get.find<HomeController>();

  late final CollectionReference budgetCollection = firestore.collection('budget');
  late final CollectionReference incomeCollection = firestore.collection('income');
  late final CollectionReference expenseCollection = firestore.collection('expense');

  final TextEditingController amountCtrl = TextEditingController();
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  bool isBudgetFound = false;

  RxDouble totalBudgetAmount = 0.0.obs;
  RxDouble usedBudgetAmount = 0.0.obs;
  RxDouble remainingBudgetAmount = 0.0.obs;

  RxList<Map<String, dynamic>> budgetList = <Map<String, dynamic>>[].obs;

  // Streams for real-time updates
  StreamSubscription<QuerySnapshot>? _budgetSubscription;
  StreamSubscription<QuerySnapshot>? _expenseSubscription;
  Timer? _refreshTimer;

  @override
  Future<void> onInit() async {
    super.onInit();
    
    // Listen to auth state changes
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print("User logged in, setting up real-time listeners");
        _setupRealTimeListeners();
        _startPeriodicRefresh();
      } else {
        print("User logged out, cleaning up listeners");
        _cleanupListeners();
        resetBudgetData();
      }
    });
    
    // Initial setup if user is already logged in
    if (auth.currentUser != null) {
      _setupRealTimeListeners();
      _startPeriodicRefresh();
    }
  }

  // Set up real-time Firestore listeners
  void _setupRealTimeListeners() {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Listen to budget changes
    _budgetSubscription = budgetCollection
        .where('userId', isEqualTo: currentUser.uid)
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots()
        .listen((snapshot) {
      print("Budget data changed, refreshing...");
      _calculateBudgetStatus();
    });

    // Listen to expense changes
    _expenseSubscription = expenseCollection
        .where('userId', isEqualTo: currentUser.uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .listen((snapshot) {
      print("Expense data changed, refreshing...");
      _calculateBudgetStatus();
    });
  }

  // Start periodic refresh timer (every 30 seconds)
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (auth.currentUser != null) {
        print("Periodic refresh triggered");
        _calculateBudgetStatus();
      }
    });
  }

  // Calculate budget status from current data
  Future<void> _calculateBudgetStatus() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        resetBudgetData();
        return;
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      double totalBudget = 0.0;
      double usedBudget = 0.0;

      // 1. Fetch total budgets
      final budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      for (var doc in budgetSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['amount'] is num) {
          totalBudget += (data['amount'] as num).toDouble();
        }
      }

      // 2. Fetch total expenses
      final expenseSnapshot = await expenseCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      for (var doc in expenseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['amount'] is num) {
          usedBudget += (data['amount'] as num).toDouble();
        }
      }

      // 3. Update state with animation-friendly updates
      if (totalBudgetAmount.value != totalBudget) {
        totalBudgetAmount.value = totalBudget;
      }
      if (usedBudgetAmount.value != usedBudget) {
        usedBudgetAmount.value = usedBudget;
      }
      if (remainingBudgetAmount.value != (totalBudget - usedBudget)) {
        remainingBudgetAmount.value = totalBudget - usedBudget;
      }
      
      isBudgetFound = totalBudget > 0;
      
      print("Budget status updated - Total: $totalBudget, Used: $usedBudget, Remaining: ${totalBudget - usedBudget}");
    } catch (e) {
      print("Error calculating budget status: $e");
    }
  }

  // Clean up listeners
  void _cleanupListeners() {
    _budgetSubscription?.cancel();
    _expenseSubscription?.cancel();
    _refreshTimer?.cancel();
    _budgetSubscription = null;
    _expenseSubscription = null;
    _refreshTimer = null;
  }

  // Method to reset all budget data
  void resetBudgetData() {
    totalBudgetAmount.value = 0.0;
    usedBudgetAmount.value = 0.0;
    remainingBudgetAmount.value = 0.0;
    budgetList.clear();
    isBudgetFound = false;
    update();
  }

  // Force refresh method (can be called manually)
  Future<void> forceRefresh() async {
    print("Force refresh triggered");
    await _calculateBudgetStatus();
  }

  // Modified fetchBudgetStatus to use the new calculation method
  Future<void> fetchBudgetStatus() async {
    await _calculateBudgetStatus();
  }

  // Add budget method with auto-refresh
  Future<bool> addBudget() async {
    try {
      final double enteredAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
      final String userId = auth.currentUser!.uid;

      if (selectedStartDate.value == null || selectedEndDate.value == null) {
        Get.snackbar("Error", "Please select both start and end dates.",
            colorText: TColor.secondary);
        return false;
      }

      // Income validation logic (keeping your existing logic)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

      final incomeSnapshot = await incomeCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThan: startOfNextMonth)
          .get();

      double totalIncome = 0.0;
      for (var doc in incomeSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = data['amount'] ?? 0.0;
          totalIncome += double.tryParse(amount.toString()) ?? 0.0;
        }
      }

      final budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: userId)
          .where('startDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('startDate', isLessThan: startOfNextMonth)
          .get();

      double existingBudgetTotal = 0.0;
      for (var doc in budgetSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final amount = data['amount'] ?? 0.0;
          existingBudgetTotal += double.tryParse(amount.toString()) ?? 0.0;
        }
      }

      if (enteredAmount + existingBudgetTotal > totalIncome) {
        Get.snackbar("Error", "Adding this budget will exceed your total income.",
            colorText: TColor.secondary);
        return false;
      }

      // Save budget
      final doc = budgetCollection.doc();
      final budget = {
        'id': doc.id,
        'amount': enteredAmount,
        'startDate': selectedStartDate.value,
        'endDate': selectedEndDate.value,
        'userId': userId,
      };

      await doc.set(budget);
      
      // The real-time listener will automatically update the UI
      Get.snackbar("Success", "Budget added successfully", colorText: TColor.line);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
      return false;
    }
  }

  // Update budget method with auto-refresh
  Future<void> updateBudget({
    required String id,
    double? newAmount,
    DateTime? newStartDate,
    DateTime? newEndDate,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      Map<String, dynamic> updatedData = {};

      if (newAmount != null) updatedData['amount'] = newAmount;
      if (newStartDate != null) updatedData['startDate'] = newStartDate;
      if (newEndDate != null) updatedData['endDate'] = newEndDate;

      if (updatedData.isEmpty) {
        Get.snackbar("Error", "No data provided to update");
        return;
      }

      await budgetCollection.doc(id).update(updatedData);
      
      // The real-time listener will automatically update the UI
      Get.snackbar("Success", "Budget updated successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Error updating budget: $e");
    }
  }

  // Delete budget method with auto-refresh
  Future<void> deleteBudget(String id) async {
    try {
      await budgetCollection.doc(id).delete();
      // The real-time listener will automatically update the UI
      Get.snackbar("Success", "Budget deleted successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Error deleting budget: $e");
    }
  }

  // Fetch budget method (keeping your existing logic)
  Future<void> fetchBudget() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print("Error: User not logged in");
        return;
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await budgetCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final List<Map<String, dynamic>> budgets = snapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        };
      }).toList();

      budgetList.assignAll(budgets);
      print("Fetched ${budgetList.length} budgets for the current month.");
    } catch (e) {
      print("Error: Failed to fetch budgets - $e");
    } finally {
      update();
    }
  }

  // Your existing fetchExpenseStatusForCurrentMonth method
  Future<List<Map<String, dynamic>>> fetchExpenseStatusForCurrentMonth() async {
    final user = auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return [];
    }

    final userId = user.uid;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final budgetSnapshot = await budgetCollection
        .where('userId', isEqualTo: userId)
        .where('startDate', isGreaterThanOrEqualTo: startOfMonth)
        .where('startDate', isLessThan: endOfMonth)
        .get();

    List<Map<String, dynamic>> result = [];

    for (var doc in budgetSnapshot.docs) {
      final budgetData = doc.data() as Map<String, dynamic>;
      final amount = (budgetData['amount'] ?? 0.0).toDouble();
      final startDate = (budgetData['startDate'] as Timestamp).toDate();
      final endDate = (budgetData['endDate'] as Timestamp).toDate();

      final expenseSnapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThan: endOfMonth)
          .get();

      double used = 0.0;
      List<Map<String, dynamic>> spendings = [];

      for (var expenseDoc in expenseSnapshot.docs) {
        final expenseData = expenseDoc.data() as Map<String, dynamic>;
        final amt = (expenseData['amount'] ?? 0.0).toDouble();
        used += amt;
        spendings.add({
          'name': expenseData['description'] ?? 'Unknown',
          'amount': amt,
        });
      }

      result.add({
        'budget': amount,
        'used': used,
        'remaining': amount - used,
        'spendings': spendings,
        'startDate': startDate,
        'endDate': endDate,
      });
    }

    return result;
  }

  @override
  void onClose() {
    _cleanupListeners();
    amountCtrl.dispose();
    super.onClose();
  }
}