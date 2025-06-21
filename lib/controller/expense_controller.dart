import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';


class ExpenseController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


  late final CollectionReference expenseCollection =
      firestore.collection("expense");
  late final CollectionReference budgetCollection =
      firestore.collection("budget");
  late final CollectionReference spendingCollection =
      firestore.collection("spending");

  RxList<Map<String, String>> currentMonthCategories =
      <Map<String, String>>[].obs;
  RxList<Map<String, dynamic>> currentMonthExpenses =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> expenseStatusList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("onInit triggered category");
    fetchCategories();
    fetchCurrentMonthExpenses();
    fetchCurrentMonthExpenseCategories();
    loadExpenseStatus();
  }

  Future<void> fetchCategories() async {
    final fetchedCategories = await fetchCurrentMonthExpenseCategories();
    currentMonthCategories.assignAll(fetchedCategories);

    update();

    final topCategory = getHighestSpendingCategory();
  }

  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();

  Future<void> loadExpenseStatus() async {
    final data = await fetchExpenseStatusForCurrentMonth();
    expenseStatusList.assignAll(data);
  }

  Future<bool> addExpense() async {
    try {
      final String userId = auth.currentUser!.uid;
      final DateTime now = DateTime.now();

      final double amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
      final String category = categoryCtrl.text.trim();

      if (amount <= 0 || category.isEmpty) {
        Get.snackbar("Error", "Please enter valid category and amount.",
            colorText: TColor.secondary);
        return false;
      }

      // Fetch current month's budget
      final budgetSnapshot = await budgetCollection
          .where('userId', isEqualTo: userId)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now)
          .get();

      if (budgetSnapshot.docs.isEmpty) {
        Get.snackbar("Error", "No budget set for the current month.",
            colorText: TColor.secondary);
        return false;
      }

      final budgetRawData = budgetSnapshot.docs.first.data();
      if (budgetRawData == null) {
        Get.snackbar("Error", "Failed to load budget data.",
            colorText: TColor.secondary);
        return false;
      }

      final Map<String, dynamic> budgetData =
          budgetRawData as Map<String, dynamic>;
      final double totalBudget =
          double.tryParse(budgetData['amount'].toString()) ?? 0.0;
      final DateTime startDate =
          (budgetData['startDate'] as Timestamp).toDate();
      final DateTime endDate = (budgetData['endDate'] as Timestamp).toDate();

      // Fetch total spent in the same period
      final expensesSnapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      double totalSpent = 0.0;
      for (var doc in expensesSnapshot.docs) {
        final data = doc.data();
        if (data != null) {
          final expenseData = data as Map<String, dynamic>;
          final expAmount =
              double.tryParse(expenseData['amount'].toString()) ?? 0.0;
          totalSpent += expAmount;
        }
      }

      final double remainingBudget = totalBudget - totalSpent;

      // Check if expense fits in the remaining budget
      if (amount > remainingBudget) {
        Get.snackbar("Error",
            "Not enough budget left. Remaining: ${remainingBudget.toStringAsFixed(2)}",
            colorText: TColor.secondary);
        return false;
      }

      // Add the expense with remaining and used fields
      final doc = expenseCollection.doc();
      final expense = {
        'id': doc.id,
        'category': category,
        'amount': amount,
        'remaining': amount, // Default: remaining = amount
        'used': 0.00,
        'date': Timestamp.now(),
      'shared': false,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
      };

      await doc.set(expense);

      Get.snackbar("Success", "Expense category added successfully",
          colorText: TColor.line);

      await fetchCurrentMonthExpenses();
      await fetchCategories();
      await loadExpenseStatus();
      await fetchCurrentMonthExpenseCategories();

      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("❌ Error adding expense: $e");
      return false;
    }
  }

  // fetch category name of current month expense for logged in user
Future<List<Map<String, String>>> fetchCurrentMonthExpenseCategories() async {
  try {
    final user = auth.currentUser;
    if (user == null) {
      print('User not logged in');
      return [];
    }

    final userId = user.uid;
    final now = DateTime.now();

    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    print("🔍 Fetching expenses for user: $userId");
    print("🔍 Date range: $startOfMonth to $endOfMonth");

    final snapshot = await expenseCollection
        .where('userId', isEqualTo: userId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    print("🔍 Found ${snapshot.docs.length} documents");

    final List<Map<String, String>> categories = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final categoryId = doc.id;
      
      print("🔍 Processing document: $categoryId");
      print("🔍 Raw data: $data");
      
      final category = data['category'] as String?;
      final amount = data['amount'];
      final remaining = data['remaining'];
      final used = data['used'];
      
      print("🔍 Extracted values:");
      print("   - category: $category (${category.runtimeType})");
      print("   - amount: $amount (${amount.runtimeType})");
      print("   - remaining: $remaining (${remaining.runtimeType})");
      print("   - used: $used (${used.runtimeType})");

      // Convert to double first, then to string
      double amountDouble = _convertToDouble(amount);
      double remainingDouble = _convertToDouble(remaining);
      double usedDouble = _convertToDouble(used);
      
      print("🔍 Converted values:");
      print("   - amountDouble: $amountDouble");
      print("   - remainingDouble: $remainingDouble");
      print("   - usedDouble: $usedDouble");

      if (category != null && category.trim().isNotEmpty && amountDouble > 0) {
        final categoryMap = {
          'category': category.trim(),
          'categoryId': categoryId,
          'amount': amountDouble.toString(),
          'remaining': remainingDouble.toString(),
          'used': usedDouble.toString(),
        };
        
        print("🔍 Adding to categories: $categoryMap");
        categories.add(categoryMap);
      } else {
        print("⚠️ Skipping document due to validation failure");
      }
    }

    print("📋 Final categories list: $categories");
    return categories;
  } catch (e) {
    print('❌ Error fetching categories: $e');
    return [];
  }
}

// Helper method to safely convert to double
double _convertToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

  // fetch current month expense for current logged in user category and amount,
  Future<void> fetchCurrentMonthExpenses() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print("Error User not logged in");
        return;
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await expenseCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      List<Map<String, dynamic>> expenses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'category': data['category'],
          'amount': data['amount'],
        };
      }).toList();

      print("Current month expenses:");
      for (var exp in expenses) {
        print("Category: ${exp['category']}, Amount: ${exp['amount']}");
      }

      currentMonthExpenses.assignAll(expenses);
      await fetchCurrentMonthExpenseCategories();
    } catch (e) {
      print("Error Failed to fetch expenses: $e");
    }
  }

  // fetch current month expense status for showing remaining amount on category after removing spending subcategory on that category Id
  Future<List<Map<String, dynamic>>> fetchExpenseStatusForCurrentMonth() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return [];
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final expenseSnapshot = await expenseCollection
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      final List<Map<String, dynamic>> result = [];

      for (var expenseDoc in expenseSnapshot.docs) {
        final expenseData = expenseDoc.data() as Map<String, dynamic>?;

        if (expenseData == null) continue;

        final expenseId = expenseDoc.id;
        final expenseAmount = (expenseData['amount'] ?? 0).toDouble();
        final category = expenseData['category'] ?? '';

        final spendingSnapshot = await spendingCollection
            .where('userId', isEqualTo: user.uid)
            .where('expenseId', isEqualTo: expenseId)
            .where('date', isGreaterThanOrEqualTo: startOfMonth)
            .where('date', isLessThanOrEqualTo: endOfMonth)
            .get();

        double usedAmount = 0;
        List<Map<String, dynamic>> spendings = [];

        for (var spendingDoc in spendingSnapshot.docs) {
          final spendingData = spendingDoc.data() as Map<String, dynamic>?;

          if (spendingData != null) {
            final amount = (spendingData['amount'] ?? 0).toDouble();
            usedAmount += amount;

            spendings.add({
              'name': spendingData['name'] ?? '',
              'amount': amount,
              'spendingId': spendingData['id'] ?? '',
            });
          }
        }

        double remaining = expenseAmount - usedAmount;

        result.add({
          'name': expenseData['category'] ?? 'Uncategorized',
          'expenseId': expenseId,
          'category': category,
          'budget': expenseAmount,
          'used': usedAmount,
          'remaining': remaining,
          'spendings': spendings,
        });
      }

      final Set<String> processedIds = {};

      for (var item in result) {
        double remaining = item['remaining'] ?? 0.0;
        String categoryId = item['expenseId'] ?? '';
        String category = item['category'] ?? '';

        if (remaining > 0 &&
            categoryId.isNotEmpty &&
            !processedIds.contains(categoryId)) {
          await addSaving(
              categoryId: categoryId, category: category, amount: remaining);
          processedIds.add(categoryId);
        }
      }

      return result;
    } catch (e) {
      print("Error in fetchExpenseStatusForCurrentMonth: $e");
      return [];
    }
  }

  // delete expense
  deleteExpense(String id) async {
    try {
      await expenseCollection.doc(id).delete();

      Get.snackbar("Success", "expense deleted successfully",
          colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }

  String getHighestSpendingCategory() {
    print("Current Month Categories: $currentMonthCategories");

    if (currentMonthCategories.isEmpty) return "No expenses";

    currentMonthCategories.sort((a, b) {
      double aAmount = double.tryParse(a['amount'] ?? '0') ?? 0;
      double bAmount = double.tryParse(b['amount'] ?? '0') ?? 0;
      return bAmount.compareTo(aAmount); // sort descending
    });

    return currentMonthCategories.first['category'] ?? "Unknown";
  }

  Future<void> updateExpense({
    required String expenseId,
    required String newCategory,
    required double newAmount,
  }) async {
    try {
      if (newCategory.trim().isEmpty) {
        Get.snackbar("Error", "Category cannot be empty.",
            colorText: TColor.secondary);
        return;
      }
      if (newAmount <= 0) {
        Get.snackbar("Error", "Amount must be greater than zero.",
            colorText: TColor.secondary);
        return;
      }

      await expenseCollection.doc(expenseId).update({
        'category': newCategory.trim(),
        'amount': newAmount,
        'date':
            DateTime.now(),

      });

      Get.snackbar("Success", "Expense updated successfully.",
          colorText: TColor.line);

      await fetchCurrentMonthExpenses();
      await fetchCategories();
      await loadExpenseStatus();
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Error updating expense: $e");
    }
  }



  Future<void> updateAllExpensesShared(bool shared) async {
    try {
      final String userId = auth.currentUser!.uid;

      // Get all expenses for the current user
      final expensesSnapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (expensesSnapshot.docs.isEmpty) {
        print("No expenses found for user");
        return;
      }


      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in expensesSnapshot.docs) {
        batch.update(doc.reference, {'shared': shared});
      }

      // Commit the batch
      await batch.commit();

      print("✅ Successfully updated ${expensesSnapshot.docs.length} expenses shared field to $shared");

      // Refresh the expense data
      await fetchCurrentMonthExpenses();
      await fetchCategories();
      await loadExpenseStatus();
      await fetchCurrentMonthExpenseCategories();

    } catch (e) {
      print("❌ Error updating expenses shared field: $e");
      throw e;
    }
  }

  Future<bool> updateExpenseRemaining(
      String categoryId, double regularAmountFromBudget) async {
    try {
      final categories = currentMonthCategories;

      Map<String, String>? targetCategory;
      int targetIndex = -1;
      for (int i = 0; i < categories.length; i++) {
        var category = categories[i];
        if (category['categoryId'] == categoryId) {
          targetCategory = category;
          targetIndex = i;
          break;
        }
      }

      if (targetCategory == null) {
        return false;
      }

      // STEP 2: Get the current document from Firebase
      final docSnapshot = await FirebaseFirestore.instance
          .collection('expense')
          .doc(categoryId)
          .get();

      if (!docSnapshot.exists) {
        return false;
      }

      final firebaseData = docSnapshot.data();
      if (firebaseData == null) {
        return false;
      }

      // STEP 3: Safely convert Firebase data to doubles
      double safeToDouble(dynamic value) {
        if (value is double) {
          return value;
        }
        if (value is int) {
          return value.toDouble();
        }
        if (value is String) {
          double? parsed = double.tryParse(value);
          return parsed ?? 0.0;
        }
        if (value is num) {
          return value.toDouble();
        }
        return 0.0;
      }

      // Use Firebase data (source of truth)
      double currentRemaining = safeToDouble(firebaseData['remaining']);
      double currentUsed = safeToDouble(firebaseData['used']);

      // Additional null safety check
      if (currentRemaining < 0 && currentUsed < 0) {
        // Both values defaulted to 0, might indicate missing data
        return false;
      }

      // STEP 4: Check if remaining amount is sufficient before proceeding
      if (currentRemaining <= 0) {
        // Cannot spend when remaining is zero or negative
        return false;
      }

      // Optional: Check if the spending amount exceeds remaining balance
      if (regularAmountFromBudget > currentRemaining) {
        // Cannot spend more than what's remaining
        return false;
      }

      // STEP 5: Calculate new values
      double newRemaining = currentRemaining - regularAmountFromBudget;
      double newUsed = currentUsed + regularAmountFromBudget;

      // STEP 6: Validate the new values
      if (newRemaining.isNaN ||
          newUsed.isNaN ||
          newRemaining.isInfinite ||
          newUsed.isInfinite) {
        return false;
      }

      // STEP 6.1: Check if new remaining would be negative
      if (newRemaining < 0) {
        return false;
      }

      // STEP 7: Update Firebase with explicit double values
      await FirebaseFirestore.instance
          .collection('expense')
          .doc(categoryId)
          .update({
        'remaining': newRemaining,
        'used': newUsed,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // STEP 8: Update local state - Create new category map with String values
      Map<String, String> updatedCategory = {};

      // Copy all existing fields, converting everything to String
      targetCategory.forEach((key, value) {
        if (value != null) {
          updatedCategory[key] = value.toString();
        }
      });

      // Update the specific fields with new calculated values (as Strings)
      updatedCategory['remaining'] = newRemaining.toString();
      updatedCategory['used'] = newUsed.toString();

      // Safety check before replacing
      if (targetIndex >= 0 && targetIndex < currentMonthCategories.length) {
        currentMonthCategories[targetIndex] = updatedCategory;
        update(); // Refresh GetX state
      } else {
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      if (e is FirebaseException) {
        // Handle Firebase-specific errors if needed
      }
      return false;
    }
  }
}

Future<void> addSaving({
  required String categoryId,
  required String category,
  required double amount,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    final savingCollection = FirebaseFirestore.instance.collection('saving');

    final now = DateTime.now().toUtc(); // Convert to UTC
    final startOfMonth = DateTime.utc(now.year, now.month, 1);
    final endOfMonth = DateTime.utc(now.year, now.month + 1, 0, 23, 59, 59);

    final existing = await savingCollection
        .where('userId', isEqualTo: user.uid)
        .where('categoryId', isEqualTo: categoryId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    if (existing.docs.isNotEmpty) {
      print("Saving already exists for this category this month");
      return;
    }

    await savingCollection.add({
      'userId': user.uid,
      'categoryId': categoryId,
      'categoryName': category,
      'amount': amount,
      'date': Timestamp.now(),
    });

    print("Saving added for category: $categoryId");
  } catch (e) {
    print("Error adding saving: $e");
  }
}
