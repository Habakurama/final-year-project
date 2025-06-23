import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/income_segment_button.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/view/add_subscription/add_income.dart';
import 'package:untitled/view/add_subscription/add_spending.dart';
import 'package:untitled/view/spending_budgets/spending_budgets_view.dart';

class AddSubScriptionView extends StatefulWidget {
  const AddSubScriptionView({super.key});

  @override
  State<AddSubScriptionView> createState() => _AddSubScriptionViewState();
}

class _AddSubScriptionViewState extends State<AddSubScriptionView> {
  bool isIncome = true;
  int selectedCategoryIndex = -1;

  final ExpenseController expenseCtrl = Get.put(ExpenseController());
  final CarouselSliderController _carouselController = CarouselSliderController();
  
  final List<Map<String, String>> subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];

  bool _isLoading = false;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize with first category if available
    if (subArr.isNotEmpty) {
      selectedCategory = subArr[0]["name"];
      expenseCtrl.categoryCtrl.text = selectedCategory!;
    }
  }

  void _onCategorySelected(int index, String categoryName) {
    setState(() {
      selectedCategoryIndex = index;
      selectedCategory = categoryName;
      expenseCtrl.categoryCtrl.text = categoryName;
    });
  }

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subArr.length,
              itemBuilder: (context, index) {
                final category = subArr[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      category["icon"]!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(category["name"]!),
                  selected: selectedCategoryIndex == index,
                  onTap: () {
                    _onCategorySelected(index, category["name"]!);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Enhanced validation with more comprehensive checks
  bool _validateInputs() {
    if (expenseCtrl.categoryCtrl.text.trim().isEmpty) {
      _showErrorSnackbar("Please select or enter a category");
      return false;
    }
    
    if (expenseCtrl.amountCtrl.text.trim().isEmpty) {
      _showErrorSnackbar("Please enter an amount");
      return false;
    }

    final amount = double.tryParse(expenseCtrl.amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showErrorSnackbar("Please enter a valid positive amount");
      return false;
    }

    if (amount > 1000000) {
      _showErrorSnackbar("Amount seems too large. Please verify.");
      return false;
    }

    return true;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error", 
      message,
      colorText: Theme.of(context).colorScheme.error,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      "Success", 
      message,
      colorText: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void handleSubmit() async {
    if (!_validateInputs()) return;

   
    final amount = double.parse(expenseCtrl.amountCtrl.text.trim());
    if (amount > 10000) {
      final confirmed = await _showConfirmationDialog(
        "Large Amount", 
        "You're about to add an expense of ${amount.toStringAsFixed(2)} Frw. Are you sure?"
      );
      if (!confirmed) return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final addExpense = await expenseCtrl.addExpense();

      if (addExpense) {
        _showSuccessSnackbar("Transaction added successfully");
        
        // Clear form
        expenseCtrl.categoryCtrl.clear();
        expenseCtrl.amountCtrl.clear();
        setState(() {
          selectedCategoryIndex = -1;
          selectedCategory = null;
        });

        // Navigate with animation
        Get.to(
          () => const SpendingBudgetsView(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        _showErrorSnackbar("Failed to add transaction. Please try again.");
      }
    } catch (e) {
      _showErrorSnackbar("An error occurred: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel',style: TextStyle( color: Theme.of(context).colorScheme.primary),),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final borderColor = theme.dividerColor;

    return GetBuilder<HomeController>(builder: (_) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Enhanced header with better styling
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).brightness == Brightness.dark
                          ? TColor.gray80
                          : TColor.back,
                      Theme.of(context).brightness == Brightness.dark
                          ? TColor.gray80.withOpacity(0.8)
                          : TColor.back.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Enhanced header with better spacing
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: theme.iconTheme.color,
                                size: 24,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Set your expense category",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              onPressed: _showCategorySelectionDialog,
                              icon: Icon(
                                Icons.list,
                                color: theme.iconTheme.color,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Enhanced carousel with selection indicator
                      SizedBox(
                        width: media.width,
                        height: media.width * 0.55,
                        child: CarouselSlider.builder(
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            autoPlay: false,
                            aspectRatio: 1,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: subArr.length > 2,
                            viewportFraction: 0.65,
                            enlargeFactor: 0.4,
                            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                            onPageChanged: (index, reason) {
                              _onCategorySelected(index, subArr[index]["name"]!);
                            },
                          ),
                          itemCount: subArr.length,
                          itemBuilder: (context, index, _) {
                            var sObj = subArr[index];
                            bool isSelected = selectedCategoryIndex == index;
                            
                            return GestureDetector(
                              onTap: () => _onCategorySelected(index, sObj["name"]!),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSelected 
                                    ? Border.all(
                                        color: theme.primaryColor, 
                                        width: 3
                                      )
                                    : null,
                                  boxShadow: isSelected 
                                    ? [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        sObj["icon"]!,
                                        width: media.width * 0.35,
                                        height: media.width * 0.35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      sObj["name"]!,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected 
                                          ? theme.primaryColor 
                                          : theme.hintColor,
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        height: 2,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              /// Enhanced Segment Button with better styling
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? TColor.gray80 
                    : TColor.back,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: IncomeSegmentButton(
                        title: 'Add subCategory',
                        onPress: () => Get.to(
                          () => const AddSpendingView(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IncomeSegmentButton(
                        title: 'Add Income',
                        onPress: () => Get.to(
                          () => const AddIncomeView(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// Enhanced Category input with selection indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RoundedTextField(
                            title: "Category",
                            titleAlign: TextAlign.center,
                            controller: expenseCtrl.categoryCtrl,
                          ),
                        ),
                        if (selectedCategory != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedCategory = null;
                                selectedCategoryIndex = -1;
                                expenseCtrl.categoryCtrl.clear();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: theme.hintColor,
                            ),
                          ),
                      ],
                    ),
                    if (selectedCategory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: Text(
                          "Selected from carousel",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              /// Enhanced Amount input with currency formatting
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: RoundedTextField(
                  title: "Amount (Rwf)",
                  titleAlign: TextAlign.center,
                  controller: expenseCtrl.amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),

              /// Enhanced Add Button with loading state
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: _isLoading ? "Adding..." : "Add New Expense",
                  onPress: _isLoading ? () {} : handleSubmit,
                  color: TColor.white,
                  isLoading: _isLoading,
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    // Clean up controllers if needed
    super.dispose();
  }
}