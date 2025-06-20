import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/budgetController.dart';
import 'package:untitled/controller/expense_controller.dart';
import 'package:untitled/controller/home_controller.dart';
import 'package:untitled/controller/saving_contoller.dart';
import 'package:untitled/controller/spending_controller.dart';
import 'package:untitled/controller/theme_controller.dart';
import 'package:untitled/firebase_option.dart';
import 'package:untitled/view/login/welcome_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);

  await GetStorage.init();

  Get.put(ThemeController());

  final box = GetStorage();
  await box.erase();
  await FirebaseAuth.instance.signOut();

  Get.put(HomeController());
  Get.put(SpendingController());
  Get.put(ExpenseController());
  Get.put(BudgetController());
    Get.put(SavingController()); // very important
 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: "Inter",
            colorScheme: ColorScheme.fromSeed(
              seedColor: TColor.primary,
              surface: TColor.gray80,
              primary: TColor.primary,
              primaryContainer: TColor.gray60,
              secondary: TColor.secondary,
            ),
            useMaterial3: false,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.themeMode.value,
          home: const WelcomeView(),
        ));
  }
}
