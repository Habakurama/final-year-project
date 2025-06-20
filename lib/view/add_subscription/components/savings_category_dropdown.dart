import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/saving_contoller.dart';
import 'package:untitled/model/Saving/saving.dart';

class SavingsCategoryDropdown extends StatelessWidget {
  final String? selectedSavingCategoryId;
  final double availableSavingAmount;
  final TextEditingController regularAmountCtrl;
  final TextEditingController savingAmountCtrl;
  final Function(String?) onSavingCategoryChanged;
  final SavingController savingCtrl;
  final List<String> excludedCategoryIds;

  const SavingsCategoryDropdown({
    super.key,
    required this.selectedSavingCategoryId,
    required this.availableSavingAmount,
    required this.regularAmountCtrl,
    required this.savingAmountCtrl,
    required this.onSavingCategoryChanged,
    required this.savingCtrl,
    this.excludedCategoryIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Obx(() {
        final List<SavingModel> allSavings = savingCtrl.saving;

        // Debugging: Print values
        print("Excluded Category IDs: $excludedCategoryIds");
        print("All Savings Category IDs: ${allSavings.map((s) => s.categoryId)}");
        print("Currently Selected Category ID: $selectedSavingCategoryId");

        // Filter out excluded categoryIds and ensure categoryId is not null
        final List<SavingModel> availableSavings = allSavings.where((saving) {
          final categoryId = saving.categoryId?.trim();
          return categoryId != null && 
                 categoryId.isNotEmpty && 
                 !excludedCategoryIds.contains(categoryId);
        }).toList();

        print("Available Savings after filtering: ${availableSavings.map((s) => s.categoryId)}");

        // More robust validation of current selection
        String? dropdownValue;
        if (selectedSavingCategoryId != null && selectedSavingCategoryId!.isNotEmpty) {
          final selectedExists = availableSavings.any(
            (s) => s.categoryId?.trim() == selectedSavingCategoryId?.trim(),
          );
          dropdownValue = selectedExists ? selectedSavingCategoryId : null;
        }

        print("Final dropdown value: $dropdownValue");

        if (availableSavings.isEmpty) {
          return const Center(
            child: Text(
              "No savings categories available",
              textAlign: TextAlign.center,
            ),
          );
        }

        // Create dropdown items with null safety
        final List<DropdownMenuItem<String>> dropdownItems = availableSavings
            .where((saving) => saving.categoryId != null && saving.categoryId!.isNotEmpty)
            .map((saving) {
          return DropdownMenuItem<String>(
            value: saving.categoryId!,
            child: Text(
              "${saving.categoryName ?? 'Unnamed'} - ${saving.amount.toStringAsFixed(0)} RWF",
            ),
          );
        }).toList();

        // Additional safety check - ensure dropdown value exists in items
        if (dropdownValue != null) {
          final valueExistsInItems = dropdownItems.any((item) => item.value == dropdownValue);
          if (!valueExistsInItems) {
            dropdownValue = null;
            print("Warning: Selected value not found in dropdown items, resetting to null");
          }
        }

        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select saving category",
                labelStyle: TextStyle(color: theme.disabledColor),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
              value: dropdownValue,
              items: dropdownItems,
              onChanged: (String? newValue) {
                print("Dropdown selection changed to: $newValue");
                onSavingCategoryChanged(newValue);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a saving category';
                }
                return null;
              },
            ),
            if (dropdownValue != null) ...[
              const Padding(
                padding: EdgeInsets.only(top: 8),
              
              ),
              const SizedBox(height: 10),
              RoundedTextField(
                title: "Amount from regular budget (RWF)",
                titleAlign: TextAlign.center,
                controller: regularAmountCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              RoundedTextField(
                title: "Amount to use from savings (RWF)",
                titleAlign: TextAlign.center,
                controller: savingAmountCtrl,
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        );
      }),
    );
  }
}