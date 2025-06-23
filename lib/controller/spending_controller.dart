import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/expense_controller.dart';

class SpendingController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final ExpenseController expenseController = Get.put(ExpenseController());


  late final CollectionReference spendingCollection =
      firestore.collection("spending");
  late final CollectionReference expenseCollection =
      firestore.collection("expense");

  final TextEditingController subAmountCtrl = TextEditingController();
  final TextEditingController subNameCtrl = TextEditingController();

  String selectedExpenseId = '';
  var totalAmountSpending = 0.0.obs;
  var totalSpendingCount = 0.obs;
  var lowestSpending = 0.0.obs;
  var highestSpending = 0.0.obs;

  var spending = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    fetchSpendingStats();
    fetchUserSpendings();
    super.onInit();
  }

  Future<bool> addSpending({bool useFromSavings = false}) async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar("Error", "User not logged in.",
            colorText: TColor.secondary);
        return false;
      }

      final double subAmount =
          double.tryParse(subAmountCtrl.text.trim()) ?? 0.0;
      final String subName = subNameCtrl.text.trim();

      if (subAmount <= 0 || subName.isEmpty || selectedExpenseId.isEmpty) {
        Get.snackbar("Error", "Please provide valid spending details.",
            colorText: TColor.secondary);
        return false;
      }

      final expenseDoc = await expenseCollection.doc(selectedExpenseId).get();
      if (!expenseDoc.exists || expenseDoc.data() == null) {
        Get.snackbar("Error", "Expense category not found.",
            colorText: TColor.secondary);
        return false;
      }

      final expenseData = expenseDoc.data()! as Map<String, dynamic>;
      final double maxCategoryAmount =
          double.tryParse(expenseData['amount'].toString()) ?? 0.0;

      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .where('expenseId', isEqualTo: selectedExpenseId)
          .get();

      double totalSpentInCategory = 0.0;
      for (var doc in spendingSnapshot.docs) {
        final spend = doc.data() as Map<String, dynamic>;
        totalSpentInCategory +=
            double.tryParse(spend['amount'].toString()) ?? 0.0;
      }

      final double remainingAmount = maxCategoryAmount - totalSpentInCategory;

      if (!useFromSavings && subAmount > remainingAmount) {
        Get.snackbar("Error",
            "Insufficient budget. Remaining: ${remainingAmount.toStringAsFixed(2)}",
            colorText: TColor.secondary);
        return false;
      }

      final doc = spendingCollection.doc();
      final spending = {
        'id': doc.id,
        'name': subName,
        'amount': subAmount,
        'date': Timestamp.fromDate(DateTime.now()),
        'userId': userId,
        'expenseId': selectedExpenseId,
        'useFromSavings': useFromSavings,
      };

      await doc.set(spending);
      await recalculateUsedAndRemaining(selectedExpenseId); // ✅

      await fetchUserSpendings();
      await fetchSpendingStats();
      expenseController.loadExpenseStatus();

      Get.snackbar("Success", "Spending added successfully",
          colorText: TColor.line);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Spending Error: $e");
      return false;
    }
  }

  Future<bool> updateSpending(String spendingId, subAmount, subName) async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) return false;

      final double amountParsed = double.tryParse(subAmount.toString()) ?? 0.0;
      final String nameParsed = subName.toString();

      if (amountParsed <= 0 || nameParsed.isEmpty || selectedExpenseId.isEmpty) {
        return false;
      }

      final expenseDoc = await expenseCollection.doc(selectedExpenseId).get();
      final expenseData = expenseDoc.data()! as Map<String, dynamic>;
      final double maxCategoryAmount =
          double.tryParse(expenseData['amount'].toString()) ?? 0.0;

      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .where('expenseId', isEqualTo: selectedExpenseId)
          .get();

      double totalSpentInCategory = 0.0;
      for (var doc in spendingSnapshot.docs) {
        if (doc.id != spendingId) {
          final spend = doc.data() as Map<String, dynamic>;
          totalSpentInCategory +=
              double.tryParse(spend['amount'].toString()) ?? 0.0;
        }
      }

      final double remainingAmount = maxCategoryAmount - totalSpentInCategory;

      if (amountParsed > remainingAmount) {
        Get.snackbar("Error",
            "Insufficient budget. Remaining: ${remainingAmount.toStringAsFixed(2)}",
            colorText: TColor.secondary);
        return false;
      }

      final updateData = {
        'name': nameParsed,
        'amount': amountParsed,
        'date': Timestamp.fromDate(DateTime.now()),
        'expenseId': selectedExpenseId,
      };

      await spendingCollection.doc(spendingId).update(updateData);
      await recalculateUsedAndRemaining(selectedExpenseId); // ✅

      await fetchUserSpendings();
      await fetchSpendingStats();

      Get.snackbar("Success", "Spending updated successfully",
          colorText: TColor.line);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Update Spending Error: $e");
      return false;
    }
  }

  Future<bool> updateSpending2(
      String spendingId, subAmount, subName, selectedExpenseId) async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) return false;

      final double amountParsed = double.tryParse(subAmount.toString()) ?? 0.0;
      final String nameParsed = subName.toString();

      if (amountParsed <= 0 || nameParsed.isEmpty || selectedExpenseId.isEmpty) {
        return false;
      }

      final expenseDoc = await expenseCollection.doc(selectedExpenseId).get();
      final expenseData = expenseDoc.data()! as Map<String, dynamic>;
      final double maxCategoryAmount =
          double.tryParse(expenseData['amount'].toString()) ?? 0.0;

      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .where('expenseId', isEqualTo: selectedExpenseId)
          .get();

      double totalSpentInCategory = 0.0;
      for (var doc in spendingSnapshot.docs) {
        if (doc.id != spendingId) {
          final spend = doc.data() as Map<String, dynamic>;
          totalSpentInCategory +=
              double.tryParse(spend['amount'].toString()) ?? 0.0;
        }
      }

      final double remainingAmount = maxCategoryAmount - totalSpentInCategory;

      if (amountParsed > remainingAmount) {
        Get.snackbar("Error",
            "Insufficient budget. Remaining: ${remainingAmount.toStringAsFixed(2)}",
            colorText: TColor.secondary);
        return false;
      }

      final updateData = {
        'name': nameParsed,
        'amount': amountParsed,
        'date': Timestamp.fromDate(DateTime.now()),
        'expenseId': selectedExpenseId,
      };

      await spendingCollection.doc(spendingId).update(updateData);
      await recalculateUsedAndRemaining(selectedExpenseId); // ✅

      await fetchUserSpendings();
      await fetchSpendingStats();
      await expenseController.fetchExpenseStatusForCurrentMonth();

      expenseController.currentMonthExpenses();
      Get.snackbar("Success", "Spending updated successfully",
          colorText: TColor.line);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print("Update Spending2 Error: $e");
      return false;
    }
  }

  Future<bool> deleteSpending(String spendingId) async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) return false;

      final doc = await spendingCollection.doc(spendingId).get();
      final data = doc.data() as Map<String, dynamic>;

      if (data['userId'] != userId) return false;

      final String expenseId = data['expenseId'];

      await spendingCollection.doc(spendingId).delete();
      await recalculateUsedAndRemaining(expenseId); // ✅

      await fetchUserSpendings();
      await fetchSpendingStats();

      Get.snackbar("Success", "Spending deleted.", colorText: TColor.line);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      return false;
    }
  }

 Future<void> recalculateUsedAndRemaining(String expenseId) async {
  try {
    final expenseRef = expenseCollection.doc(expenseId);
    final expenseDoc = await expenseRef.get();

    if (!expenseDoc.exists) return;

    final data = expenseDoc.data() as Map<String, dynamic>?;
    final double budget = (data?['amount'] as num?)?.toDouble() ?? 0;

    final userId = FirebaseAuth.instance.currentUser!.uid; // ✅ Add this

    final spendingsSnapshot = await spendingCollection
        .where('expenseId', isEqualTo: expenseId)
        .where('userId', isEqualTo: userId) 
        .get();

    double used = 0;
    for (var doc in spendingsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['amount'] != null) {
        used += (data['amount'] as num?)?.toDouble() ?? 0;
      }
    }

    double remaining = budget - used;
    if (remaining < 0) remaining = 0;

    await expenseRef.update({
      'used': used,
      'remaining': remaining,
    });

    print("✅ Expense updated — Used: $used, Remaining: $remaining");
  } catch (e) {
    print("❌ Error updating used/remaining: $e");
  }
}

  Future<void> fetchUserSpendings() async {
    try {
      final String? userId = auth.currentUser?.uid;
      if (userId == null) return;

      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      spending.value = spendingSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching user spendings: $e");
    }
  }

  Future<void> fetchSpendingStats() async {
    try {
      final String userId = auth.currentUser!.uid;
      final DateTime now = DateTime.now();
      final DateTime startOfMonth = DateTime(now.year, now.month, 1);
      final DateTime endOfMonth =
          DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final spendingSnapshot = await spendingCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (spendingSnapshot.docs.isEmpty) {
        totalAmountSpending.value = 0.0;
        totalSpendingCount.value = 0;
        lowestSpending.value = 0.0;
        highestSpending.value = 0.0;
        return;
      }

      double totalAmount = 0.0;
      double? lowestAmount;
      double? highestAmount;

      for (var doc in spendingSnapshot.docs) {
        final amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
        totalAmount += amount;
        lowestAmount = (lowestAmount == null || amount < lowestAmount)
            ? amount
            : lowestAmount;
        highestAmount = (highestAmount == null || amount > highestAmount)
            ? amount
            : highestAmount;
      }

      totalAmountSpending.value = totalAmount;
      totalSpendingCount.value = spendingSnapshot.docs.length;
      lowestSpending.value = lowestAmount ?? 0.0;
      highestSpending.value = highestAmount ?? 0.0;
    } catch (e) {
      print("Error fetching spending stats: $e");
    }
  }
}
