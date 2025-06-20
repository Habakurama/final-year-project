import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/budgetController.dart';


import '../../controller/app_initialization_controller.dart';

class UpdateBudgetScreen extends StatefulWidget {
  final String budgetId;
  final double initialAmount;
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  const UpdateBudgetScreen({
    super.key,
    required this.budgetId,
    required this.initialAmount,
    required this.initialStartDate,
    required this.initialEndDate,
  });

  @override
  State<UpdateBudgetScreen> createState() => _UpdateBudgetScreenState();
}

class _UpdateBudgetScreenState extends State<UpdateBudgetScreen> {
  final BudgetController budgetCtrl = Get.put(BudgetController());
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Prefill form with initial data
    budgetCtrl.amountCtrl.text = widget.initialAmount.toString();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  void handleSubmit() async {
    if (startDate == null || endDate == null) {
      Get.snackbar("Error", "Start and end dates are required", colorText: TColor.secondary);
      return;
    }

    if (budgetCtrl.amountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter an amount", colorText: TColor.secondary);
      return;
    }

    double? amount = double.tryParse(budgetCtrl.amountCtrl.text.trim());
    if (amount == null) {
      Get.snackbar("Error", "Invalid amount", colorText: TColor.secondary);
      return;
    }

    setState(() => _isLoading = true);

    await budgetCtrl.updateBudget(
      id: widget.budgetId,
      newAmount: amount,
      newStartDate: startDate,
      newEndDate: endDate,
    );

    setState(() => _isLoading = false);

    Get.snackbar("Success", "Budget updated successfully", colorText: TColor.line);
    Navigator.pop(context);
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BudgetController>(builder: (_) {
      return Scaffold(
        backgroundColor: TColor.back,
        appBar: AppBar(
          backgroundColor: TColor.back,
          elevation: 0,
          title: Text("Update Budget", style: TextStyle(color: TColor.gray80, fontWeight: FontWeight.w600)),
          iconTheme: IconThemeData(color: TColor.gray80),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 15),
              TextField(
                controller: budgetCtrl.amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (Rwf)",
                  labelStyle: TextStyle(color: TColor.gray60),
                  filled: true,
                  fillColor: Colors.white,


                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: TColor.gray10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: TColor.gray10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: TColor.gray10, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                title: Text(
                  startDate != null ? "Start Date: ${formatDate(startDate)}" : "Select Start Date",
                  style: TextStyle(color: TColor.gray80),
                ),
                trailing: Icon(Icons.calendar_today, color: TColor.gray60),
                onTap: pickStartDate,
              ),
              ListTile(
                title: Text(
                  endDate != null ? "End Date: ${formatDate(endDate)}" : "Select End Date",
                  style: TextStyle(color: TColor.gray80),
                ),
                trailing: Icon(Icons.calendar_today, color: TColor.gray60),
                onTap: pickEndDate,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : handleSubmit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.line,
                    minimumSize: const Size.fromHeight(50)),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text("Update Budget"),
              ),
            ],
          ),
        ),
      );
    });
  }
}
