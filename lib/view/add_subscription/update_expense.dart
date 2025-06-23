import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/view/home/home_view.dart';
import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../controller/app_initialization_controller.dart';

class UpdateExpenseView extends StatefulWidget {
  final String? id;

  const UpdateExpenseView(this.id, {super.key});

  @override
  State<UpdateExpenseView> createState() => _UpdateExpenseState();
}

class _UpdateExpenseState extends State<UpdateExpenseView> {
  final SpendingController spendingCtrl = Get.put(SpendingController());
  final ExpenseController expenseCtrl = Get.put(ExpenseController());

  String? selectedCategory;
  bool isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    fetchAndSetSpendingData();
  }

  Future<void> fetchAndSetSpendingData() async {
    if (widget.id == null) {
      print("DEBUG: Widget ID is null");
      return;
    }

    print("DEBUG: Fetching spending data for ID: ${widget.id}");
    await spendingCtrl.fetchUserSpendings();
    
    final spendingToEdit = spendingCtrl.spending
        .firstWhereOrNull((item) => item['id'] == widget.id);

    print("DEBUG: Found spending to edit: $spendingToEdit");

    if (spendingToEdit != null) {
      spendingCtrl.subNameCtrl.text = spendingToEdit['name'] ?? '';
      spendingCtrl.subAmountCtrl.text =
          spendingToEdit['amount']?.toString() ?? '';
      
      // Fix: Handle null categoryId properly
      final categoryId = spendingToEdit['categoryId']?.toString();
      selectedCategory = categoryId;
      spendingCtrl.selectedExpenseId = categoryId ?? '';
      
      print("DEBUG: Set values - Name: ${spendingCtrl.subNameCtrl.text}, Amount: ${spendingCtrl.subAmountCtrl.text}, CategoryId: $categoryId");
      
      setState(() {});
    } else {
      print("DEBUG: No spending found with ID: ${widget.id}");
    }
  }

  void handleSubmit() async {
    print("DEBUG: Handle submit called");
    print("DEBUG: Name: '${spendingCtrl.subNameCtrl.text.trim()}'");
    print("DEBUG: Amount: '${spendingCtrl.subAmountCtrl.text.trim()}'");
    print("DEBUG: Selected Category ID: '${spendingCtrl.selectedExpenseId}'");

    // Simplified validation - check for empty strings
    if (spendingCtrl.subNameCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a name", colorText: TColor.secondary);
      return;
    }

    if (spendingCtrl.subAmountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter an amount", colorText: TColor.secondary);
      return;
    }

    if (spendingCtrl.selectedExpenseId.trim().isEmpty) {
      Get.snackbar("Error", "Please select a category", colorText: TColor.secondary);
      return;
    }

    double? parsedAmount = double.tryParse(spendingCtrl.subAmountCtrl.text.trim());
    if (parsedAmount == null) {
      Get.snackbar("Error", "Enter a valid number for amount", colorText: TColor.secondary);
      return;
    }

    print("DEBUG: All validations passed");
    print("DEBUG: About to call updateSpending with:");
    print("  - ID: ${widget.id}");
    print("  - Name: ${spendingCtrl.subNameCtrl.text.trim()}");
    print("  - Amount: $parsedAmount");
    print("  - CategoryId: ${spendingCtrl.selectedExpenseId}");

    try {
      // Call updateSpending with correct parameter order
      final success = await spendingCtrl.updateSpending(
        widget.id ?? '',                           // spendingId
        parsedAmount,                              // subAmount  
        spendingCtrl.subNameCtrl.text.trim(),     // subName
      );
      
      print("DEBUG: Update result: $success");
      
      if (success) {
        Get.snackbar("Success", "Spending updated successfully", 
            colorText: TColor.secondary,
            backgroundColor: Colors.green.withOpacity(0.8));
        
        // Refresh the spending list
        await spendingCtrl.fetchUserSpendings();
        
         Get.to(
          () => const HomeView(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        Get.snackbar("Error", "Failed to update spending - check your updateSpending method",
            colorText: TColor.secondary);
      }
    } catch (e) {
      print("DEBUG: Exception during update: $e");
      Get.snackbar("Error", "An error occurred: ${e.toString()}",
          colorText: TColor.secondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appInitController = Get.put(AppInitializationController());
    appInitController.initialize();

    return Scaffold(
      backgroundColor: TColor.back,
      appBar: AppBar(
        title: const Text("Update Your Spending"),
        backgroundColor: TColor.white,
        foregroundColor: TColor.gray70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Debug info (remove in production)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "DEBUG: ID=${widget.id}, SelectedCategory=$selectedCategory, SelectedExpenseId=${spendingCtrl.selectedExpenseId}",
                style: const TextStyle(fontSize: 12),
              ),
            ),

            // Category Dropdown
            Obx(() {
              final categories = expenseCtrl.currentMonthCategories;
              print("DEBUG: Available categories: $categories");

              if (categories.isEmpty) {
                return const Text(
                    "No categories available. Please add an expense first.");
              }

              return DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Select Category",
                  labelStyle: TextStyle(color: TColor.gray60),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: TColor.gray10),
                  ),
                ),
                items: categories.map((cat) {
                  final categoryId = cat['categoryId']?.toString();
                  final categoryName = cat['category'] ?? '';
                  print("DEBUG: Category item - ID: $categoryId, Name: $categoryName");
                  
                  return DropdownMenuItem<String>(
                    value: categoryId,
                    child: Text(categoryName),
                  );
                }).toList(),
                onChanged: (value) {
                  print("DEBUG: Dropdown changed to: $value");
                  setState(() {
                    selectedCategory = value;
                    spendingCtrl.selectedExpenseId = value ?? '';
                  });
                },
              );
            }),

            const SizedBox(height: 20),

            // Name Field
            TextFormField(
              controller: spendingCtrl.subNameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: TColor.gray60),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: TColor.gray10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Amount Field
            TextFormField(
              controller: spendingCtrl.subAmountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: TextStyle(color: TColor.gray60),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: TColor.gray10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            PrimaryButton(
              title: isLoading ? "Updating..." : "Update Spending",
              onPress: isLoading ? null : handleSubmit, // Disable when loading
              color: TColor.white,
            ),
          ],
        ),
      ),
    );
  }
}