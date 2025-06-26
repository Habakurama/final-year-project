import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/model/expense/expense.dart';
import 'package:untitled/model/income/income.dart';
import 'package:untitled/model/static-saving/static-saving.dart';

import '../common/color_extension.dart';

class HomeController extends GetxController{

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late final CollectionReference expenseCollection = firestore.collection("expense");
  late final CollectionReference incomeCollection = firestore.collection("income");

  final TextEditingController amountCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  double amountVal = 0.0;
  var monthlyExpense = 0.0.obs;
  var monthlyIncome = 0.0.obs;

  var totalIncome = 0.0.obs;
  
  // Move totalSavings INSIDE the class
  var totalSavings = 0.0.obs;

  List<Expense> expense = [];

  RxList<Income> income = <Income>[].obs;
  final RxDouble totalStaticSavings = 0.0.obs;
  final RxList<StaticSaving> staticSavingsList = <StaticSaving>[].obs;

  void updateAmount(double newVal) {
    amountVal = newVal;
    update(); // notify widgets
  }

  @override
 Future<void> onInit() async {

  super.onInit();

  await calculateMonthlyIncome();

  await fetchIncome();

  await fetchTotalSavings();

}

  Future<bool> addIncome() async {
    try {
      final double parsedAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

      DocumentReference doc = incomeCollection.doc();
      Income income = Income(
        id: doc.id,
        name: descriptionCtrl.text,
        amount: parsedAmount,
        date: DateTime.now(),
        userId: auth.currentUser!.uid,
        shared: false,
      );

      final incomeJson = income.toJson();

      await doc.set(incomeJson);

      Get.snackbar("Success", "Income added successfully", colorText: TColor.line);

      setValueDefault();
      await fetchIncome();
      await calculateMonthlyIncome();

      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
      return false;
    }
  }

  //update income
  Future<void> updateIncome({
    required String incomeId,
    required String newName,
    required double newAmount,
  }) async {
    try {
      DocumentReference doc = incomeCollection.doc(incomeId);

      Income updatedIncome = Income(
        id: incomeId,
        name: newName,
        amount: newAmount,
        date: DateTime.now(),

        userId: auth.currentUser!.uid,
      );

      final incomeJson = updatedIncome.toJson();

      await doc.update(incomeJson); // update instead of set

      Get.snackbar("Success", "Income updated successfully", colorText: TColor.line);
      setValueDefault(); // Optional: Reset form values
      await fetchIncome(); // Refresh income list
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }

  Future<void> updateIncomeAmountByUserId({
    required String userId,
    required double newAmount,
  }) async {
    try {

      QuerySnapshot snapshot = await incomeCollection
          .where('userId', isEqualTo: userId)
          .get();


      if (snapshot.docs.isEmpty) {
        Get.snackbar("Not Found", "No income found for this user", colorText: TColor.secondary);
        return;
      }

      double staticSavingsAmount = newAmount * 0.05; // 5% of income
      double remainingAmount = newAmount - staticSavingsAmount; // 95% remaining

      // Create StaticSaving object
      StaticSaving newStaticSaving = StaticSaving(
        userId: userId,
        amount: staticSavingsAmount,
        date: DateTime.now(),
        originalIncomeAmount: newAmount,
        createdAt: DateTime.now(),
      );

      // Save to static savings collection using the model
      await _addStaticSaving(newStaticSaving);

      // Loop through and update each income document with remaining amount
      for (var doc in snapshot.docs) {
        await incomeCollection.doc(doc.id).update({
          'amount': remainingAmount,
          'date': DateTime.now(),
          'originalAmount': newAmount,
          'staticSavingsDeducted': staticSavingsAmount,
        });
      }

      Get.snackbar(
          "Success",
          "Income updated! Static savings: ${newStaticSaving.formattedAmount} (${newStaticSaving.formattedPercentage}), Available: ${remainingAmount.toStringAsFixed(2)} Frw",
          colorText: TColor.line,
          duration: const Duration(seconds: 4)
      );

      await fetchIncome(); // Refresh income list
      await fetchStaticSavings(); // Refresh static savings

    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }

// Helper method to add StaticSaving to Firestore
  Future<void> _addStaticSaving(StaticSaving staticSaving) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('static_savings')
          .add(staticSaving.toMap());

      // Update the staticSaving with the generated ID
      staticSaving = staticSaving.copyWith(id: docRef.id);

      // Add to local list
      staticSavingsList.add(staticSaving);

      // Update total
      totalStaticSavings.value += staticSaving.amount;

    } catch (e) {
      print('Error adding static saving: $e');
      rethrow;
    }
  }

// Method to fetch all static savings
  Future<void> fetchStaticSavings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        staticSavingsList.clear();
        totalStaticSavings.value = 0.0;
        return;
      }

      String userId = currentUser.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('static_savings')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      List<StaticSaving> savings = [];
      double total = 0.0;

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        try {
          StaticSaving staticSaving = StaticSaving.fromFirestore(doc);
          savings.add(staticSaving);
          total += staticSaving.amount;
        } catch (e) {
          print('Error parsing static saving: $e');
          continue;
        }
      }

      staticSavingsList.value = savings;
      totalStaticSavings.value = total;

    } catch (e) {
      print('Error fetching static savings: $e');
      staticSavingsList.clear();
      totalStaticSavings.value = 0.0;
    }
  }

// Method to get static savings for current month
  List<StaticSaving> get currentMonthStaticSavings {
    return staticSavingsList.where((saving) => saving.isThisMonth).toList();
  }

// Method to get total static savings for current month
  double get currentMonthStaticSavingsTotal {
    return currentMonthStaticSavings.fold(0.0, (sum, saving) => sum + saving.amount);
  }

// Method to get static savings history
  List<StaticSaving> getStaticSavingsHistory({int? limitDays}) {
    if (limitDays == null) return staticSavingsList.toList();

    DateTime cutoffDate = DateTime.now().subtract(Duration(days: limitDays));
    return staticSavingsList
        .where((saving) => saving.date.isAfter(cutoffDate))
        .toList();
  }


  // Add this method to your Home Controller

  Future<void> updateAllIncomeShared(bool shared) async {
    try {
      final String userId = auth.currentUser!.uid;

      // Get all income records for the current user
      final incomeSnapshot = await incomeCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (incomeSnapshot.docs.isEmpty) {
        print("No income records found for user");
        return;
      }

      // Create a batch to update all income records at once
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in incomeSnapshot.docs) {
        batch.update(doc.reference, {'shared': shared});
      }

      // Commit the batch
      await batch.commit();

      print("✅ Successfully updated ${incomeSnapshot.docs.length} income records shared field to $shared");

      // Refresh the income data (replace with your actual refresh methods)
      await fetchIncome();

    } catch (e) {
      print("❌ Error updating income shared field: $e");
      rethrow;
    }
  }

  // total income in month
  Future<void> calculateMonthlyIncome() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));

      QuerySnapshot querySnapshot = await incomeCollection
          .where("userId", isEqualTo: auth.currentUser!.uid)
          .where("date", isGreaterThanOrEqualTo: startOfMonth)
          .where("date", isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalIncomeAmount = 0;
      for (var doc in querySnapshot.docs) {
        totalIncomeAmount += (doc['amount'] ?? 0).toDouble();
      }

      totalIncome.value = totalIncomeAmount; // update the reactive variable
      print("print total income amount, $totalIncomeAmount");
    } catch (e) {
      print("Error calculating monthly income: $e");
      totalIncome.value = 0.0; // fallback to 0 if there's an error
    }
  }

  Future<Map<String, dynamic>?> getIncomeById(String id) async {
    final doc = await incomeCollection.doc(id).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void>fetchIncome() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print("User not logged in");
        return;
      }

      final uid = currentUser.uid;
      final DateTime now = DateTime.now();

      // Define start and end of the current month
      final DateTime startOfMonth = DateTime(now.year, now.month, 1);
      final DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot incomeSnapshot = await incomeCollection
          .where("userId", isEqualTo: uid)
          .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final List<Income> retrievedIncome = incomeSnapshot.docs.map(
              (doc) => Income.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();

      income.clear();
      income.assignAll(retrievedIncome);

      for (var inc in income) {
        print("Fetched income => ID: ${inc.id}, Name: ${inc.name}, Amount: ${inc.amount}, Date: ${inc.date}");
      }

    } catch (e) {
      print("Error fetching income: $e");
    } finally {
      update();
    }
  }

  //delete income
  deleteIncome(String id) async{
    try {
      await incomeCollection.doc(id).delete();
      fetchIncome();
      calculateMonthlyIncome();
      Get.snackbar("Success", "income deleted successfully", colorText: TColor.line);
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary);
      print(e);
    }
  }

  setValueDefault(){
    amountVal = 0.0;
    descriptionCtrl.clear();
    update();
  }
  
  // Move fetchTotalSavings method INSIDE the class

// Replace your fetchTotalSavings method with this enhanced debug version
Future<void> testBasicFirestoreConnection() async {
  print("🔥 Testing Firestore connection...");
  try {
    // Test basic Firestore connection
    DocumentSnapshot testDoc = await firestore.collection('test').doc('test').get();
    print("✅ Firestore connection working");
    
    // Test user authentication
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      print("✅ User is logged in: ${currentUser.uid}");
    } else {
      print("❌ No user logged in");
    }
    
  } catch (e) {
    print("❌ Firestore connection error: $e");
  }
}

Future<void> fetchTotalSavings() async {
  try {
    String? userId = auth.currentUser?.uid;
    print("🔍 Debug - Current User ID: $userId");
    
    if (userId != null) {
      // First, let's check if the collection exists and has any documents
      QuerySnapshot allSavingsSnapshot = await firestore
          .collection('saving')
          .get();
      
      print("🔍 Debug - Total documents in 'saving' collection: ${allSavingsSnapshot.docs.length}");
      
      // Print all documents to see the structure
      for (var doc in allSavingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("🔍 Debug - Document ID: ${doc.id}");
        print("🔍 Debug - Document Data: $data");
        print("🔍 Debug - UserId in doc: ${data['userId']}");
        print("🔍 Debug - Amount in doc: ${data['amount']}");
        print("---");
      }
      
      // Now query for current user's savings
      QuerySnapshot savingsSnapshot = await firestore
          .collection('saving')
          .where('userId', isEqualTo: userId)
          .get();
      
      print("🔍 Debug - Documents for current user: ${savingsSnapshot.docs.length}");
      
      double totalSavingsAmount = 0.0;
      
      for (var doc in savingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("🔍 Debug - Processing doc: ${doc.id}");
        print("🔍 Debug - Raw amount value: ${data['amount']} (${data['amount'].runtimeType})");
        
        double amount = 0.0;
        
        // Handle different data types for amount
        if (data['amount'] is int) {
          amount = (data['amount'] as int).toDouble();
        } else if (data['amount'] is double) {
          amount = data['amount'] as double;
        } else if (data['amount'] is String) {
          amount = double.tryParse(data['amount']) ?? 0.0;
        } else {
          amount = (data['amount'] ?? 0.0).toDouble();
        }
        
        print("🔍 Debug - Converted amount: $amount");
        totalSavingsAmount += amount;
        print("🔍 Debug - Running total: $totalSavingsAmount");
      }
      
      totalSavings.value = totalSavingsAmount;
      print("🔍 Debug - Final total savings: $totalSavingsAmount");
      print("🔍 Debug - totalSavings.value set to: ${totalSavings.value}");
      
    } else {
      print("❌ Debug - No user logged in");
      totalSavings.value = 0.0;
    }
  } catch (e) {
    print('❌ Error fetching savings: $e');
    print('❌ Error type: ${e.runtimeType}');
    totalSavings.value = 0.0;
  }
}
}