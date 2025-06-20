import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/rounded_textfield.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/view/main_tab/main_tab_view.dart';

class AddIncomeView extends StatefulWidget {
  const AddIncomeView({super.key});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {
  final HomeController homeCtrl = Get.put(HomeController());

  List subArr = [
    {"name": "Salary", "icon": "assets/img/money.jpg"},
    {"name": "House rent", "icon": "assets/img/house.jpeg"},
    {"name": "Clothes", "icon": "assets/img/clothes.jpg"},
    {"name": "Food", "icon": "assets/img/food.jpeg"},
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png"}
  ];

  bool _isLoading = false;

  void handleSubmit() async {
    if (homeCtrl.descriptionCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a name",
          colorText: Theme.of(context).colorScheme.error);
      return;
    }

    if (homeCtrl.amountCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter an amount",
          colorText: Theme.of(context).colorScheme.error);
      return;
    }

    setState(() => _isLoading = true);
    final addIncome = await homeCtrl.addIncome();
    setState(() => _isLoading = false);

    if (addIncome) {
      Get.snackbar("Success", "Transaction added successfully",
          colorText: Theme.of(context).colorScheme.primary);
      Get.to(() => const MainTabView());
    }

    homeCtrl.descriptionCtrl.clear();
    homeCtrl.amountCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GetBuilder<HomeController>(builder: (_) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header with theme background and text
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back,
                                  color: theme.iconTheme.color),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "Add new income",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: media.width,
                        height: media.width * 0.5,
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            autoPlay: false,
                            aspectRatio: 1,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.65,
                            enlargeFactor: 0.4,
                            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                          ),
                          itemCount: subArr.length,
                          itemBuilder: (context, index, _) {
                            var sObj = subArr[index];
                            return Container(
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      sObj["icon"],
                                      width: media.width * 0.4,
                                      height: media.width * 0.4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    sObj["name"],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: RoundedTextField(
                  title: "name",
                  titleAlign: TextAlign.center,
                  controller: homeCtrl.descriptionCtrl,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: RoundedTextField(
                  title: "Amount",
                  titleAlign: TextAlign.center,
                  controller: homeCtrl.amountCtrl,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  title: _isLoading ? "Adding..." : "Add new income",
                  onPress: _isLoading ? () {} : handleSubmit,
                  color: colorScheme.primary,
                  isLoading: _isLoading,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
