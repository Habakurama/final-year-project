import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:untitled/model/Saving/saving.dart';

class SavingController extends GetxController {
  var saving = <SavingModel>[].obs;
  var isLoading = false.obs;

  // Add reactive variable for total savings
  var totalSavings = 0.0.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String _collectionName = 'saving';

  @override
  void onInit() {
    super.onInit();
    loadsavingFromFirebase();
    fetchTotalSavings(); // Also fetch total savings on init
  }

  // In your SavingController
  Future<void> loadsavingFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user logged in');
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('saving')
          .where('userId', isEqualTo: user.uid) // Changed from user to user.uid
          .get();

      List<SavingModel> loadedSavings = querySnapshot.docs
          .map((doc) => SavingModel.fromFirestore(doc))
          .toList();

      saving.value = loadedSavings;
      print('Loaded ${loadedSavings.length} savings'); // Add this for debugging

      // Also update total savings when loading individual savings
      await fetchTotalSavings();
    } catch (e) {
      print('Error loading savings: $e');
    }
  }

  // ✅ Fetch Total Savings Method
  Future<void> fetchTotalSavings() async {
    try {
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        print("❌ No user logged in");
        totalSavings.value = 0.0;
        return;
      }

      String userId = currentUser.uid;
      print("🔍 Fetching savings for user: $userId");

      // Query savings for current user
      QuerySnapshot savingsSnapshot = await _firestore
          .collection('saving')
          .where('userId', isEqualTo: userId)
          .get();

      print("📊 Found ${savingsSnapshot.docs.length} saving records");

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
          print("❌ Error processing document ${doc.id}: $e");
          continue; // Skip this document and continue with others
        }
      }

      // Update the reactive variable
      totalSavings.value = totalSavingsAmount;

      print(
          "💰 Total savings calculated: ${totalSavingsAmount.toStringAsFixed(2)} RWF");
    } catch (e) {
      print("❌ Error fetching total savings: $e");
      totalSavings.value = 0.0;
    }
  }

Future<bool> updateSaving(String categoryId, double amountToSubtract) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Error: User not logged in");
      return false;
    }

    if (categoryId.isEmpty) {
      print("Error: Category ID cannot be empty");
      return false;
    }

    if (amountToSubtract < 0) {
      print("Error: Amount to subtract cannot be negative");
      return false;
    }

    final savingCollection = _firestore.collection(_collectionName);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final querySnapshot = await savingCollection
        .where('userId', isEqualTo: user.uid)
        .where('categoryId', isEqualTo: categoryId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final docId = doc.id;
      final currentAmount = (doc.data()['amount'] ?? 0).toDouble();

      final updatedAmount = currentAmount - amountToSubtract;

      if (updatedAmount < 0) {
        print("Error: Cannot subtract more than current savings amount");
        return false;
      }

      await savingCollection.doc(docId).update({
        'amount': updatedAmount,
        'updatedAt': Timestamp.now(),
        'date': Timestamp.now(),
      });

      print("✅ Saving updated. New amount: $updatedAmount");
    } else {
      print("❌ No saving document found for this category in the current month.");
      return false;
    }

    await loadsavingFromFirebase();
    await fetchTotalSavings();
    return true;

  } on FirebaseException catch (e) {
    print("🔥 Firebase error: ${e.code} - ${e.message}");
    return false;
  } catch (e) {
    print("🚨 Unexpected error: $e");
    return false;
  }
}


 


  // Method to get available savings for current month
  List<Map<String, dynamic>> get currentMonthSavings {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return saving.where((savingModel) {
      final savedDate = savingModel.date;
      return savedDate.isAfter(startOfMonth) && savedDate.isBefore(endOfMonth);
    }).map((savingModel) {
      return {
        'id': savingModel.id,
        'categoryId': savingModel.categoryId,
        'categoryName': savingModel.categoryName,
        'amount': savingModel.amount,
        'savedDate': savingModel.date,
      };
    }).toList();
  }

  // Method to get specific saving by categoryId
  SavingModel? getSavingByCategoryId(String categoryId) {
    try {
      return saving
          .firstWhere((savingModel) => savingModel.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Method to check if sufficient amount is available in savings
  bool hasSufficientSavings(String categoryId, double requiredAmount) {
    final savingModel = getSavingByCategoryId(categoryId);
    if (savingModel != null) {
      return savingModel.amount >= requiredAmount;
    }
    return false;
  }

  // Method to check if sufficient total savings are available
  bool hasSufficientTotalSavings(double requiredAmount) {
    return totalSavings.value >= requiredAmount;
  }

  // Getter for total savings amount (non-reactive)
  double get totalSavingsAmount => totalSavings.value;

  // Method to refresh all savings data
  Future<void> refreshSavingsData() async {
    await loadsavingFromFirebase();
    await fetchTotalSavings();
  }
}
