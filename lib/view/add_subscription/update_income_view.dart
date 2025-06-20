import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/view/home/home_view.dart';

import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../controller/app_initialization_controller.dart';
import '../../controller/home_controller.dart';

class UpdateIncomeView extends StatefulWidget {
  final String? id;
  const UpdateIncomeView({super.key, this.id});

  @override
  State<UpdateIncomeView> createState() => _UpdateIncomeViewState();
}

class _UpdateIncomeViewState extends State<UpdateIncomeView> {
  final HomeController homeCtrl = Get.put(HomeController());

  double amountVal = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIncomeData();
  }

  void fetchIncomeData() async {
    if (widget.id == null) return;

    final data = await homeCtrl.getIncomeById(widget.id!);
    if (data != null) {
      homeCtrl.descriptionCtrl.text = data['name'] ?? '';
      homeCtrl.amountCtrl.text = (data['amount']?.toString() ?? '0.0');
    } else {
      Get.snackbar("Error", "Income not found", colorText: TColor.secondary);
    }

    setState(() {
      isLoading = false;
    });
  }

  void handleUpdate() async {
    double? amount = double.tryParse(homeCtrl.amountCtrl.text.trim());
    if (amount == null) {
      Get.snackbar("Error", "Invalid amount entered",
          colorText: TColor.secondary);
      return;
    }

    await homeCtrl.updateIncome(
      incomeId: widget.id!,
      newName: homeCtrl.descriptionCtrl.text.trim(),
      newAmount: amount,
    );

    Get.snackbar("Success", "Income updated successfully",
        colorText: TColor.line);
         Get.to(
          () => const HomeView(),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 300),
        );

    setState(() {
      amountVal = 0.0;
      homeCtrl.descriptionCtrl.clear();
      homeCtrl.amountCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appInitController = Get.put(AppInitializationController());
    appInitController.initialize();

    return Scaffold(
      backgroundColor: TColor.back,
      appBar: AppBar(
        title: const Text("Update Income"),
        backgroundColor: TColor.white,
        foregroundColor: TColor.gray80,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: homeCtrl.descriptionCtrl,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: TColor.gray60),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
                    borderSide:
                    BorderSide(color: TColor.gray10, width: 1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: homeCtrl.amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  labelStyle: TextStyle(color: TColor.gray60),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
                    borderSide:
                    BorderSide(color: TColor.gray10, width: 1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Update Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                title: "Update Income",
                onPress: handleUpdate,
                color: TColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
