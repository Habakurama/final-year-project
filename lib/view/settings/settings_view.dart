import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/theme_controller.dart';
import 'package:untitled/report/expense_report.dart';
import 'package:untitled/report/income_report.dart';
import 'package:untitled/report/saving_report.dart';
import 'package:untitled/service/AuthenticationService.dart';
import 'package:untitled/view/login/edit_profile.dart';
import 'package:untitled/view/login/sign_in_view.dart';

import '../../common_widget/icon_item_row.dart';
import '../../report/budget_report.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isActive = false;
  final AuthenticationService authService = AuthenticationService();
  late ThemeController themeController;

  String selectedTheme = "";

  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    themeController = Get.find<ThemeController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial theme selection based on current theme
    if (selectedTheme.isEmpty) {
      final currentTheme = Theme.of(context).brightness;
      selectedTheme = currentTheme == Brightness.dark ? 'Dark' : 'Light';
    }
  }

  Future<void> fetchCurrentUser() async {
    final userData = await authService.getCurrentUserData();
    if (userData != null) {
      setState(() {
        userName = userData['name'] ?? 'No Name';
        userEmail = userData['email'] ?? 'No Email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textColor = theme.textTheme.bodyMedium?.color;
    var backgroundColor = theme.scaffoldBackgroundColor;
    var primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.1),
                    backgroundColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile Avatar with shadow
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.3),
                          primaryColor.withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark 
                    ? TColor.gray80 
                    : theme.cardColor,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).brightness == Brightness.dark 
                    ? TColor.white
                    : theme.primaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Info
                  Text(
                    userName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: textColor?.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Enhanced Edit Profile Button
                  InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      Get.to(() => const EditProfileView());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.8),
                            primaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reports Section
                  sectionTitle("Reports", textColor, Icons.assessment),
                  const SizedBox(height: 12),
                  enhancedContainer(
                    theme,
                    Column(
                      children: [
                        enhancedIconItemRow(
                          theme: theme,
                          title: "Expense Report",
                          subtitle: "Generate detailed expense analysis",
                          icon: Icons.trending_down,
                          color: Colors.red,
                          onTap: () async {
                            final generator = ExpensePdfGenerator();
                            await generator.generateAndSaveExpenseReport();
                          },
                        ),
                        const SizedBox(height: 16),
                        enhancedIconItemRow(
                          theme: theme,
                          title: "Income Report",
                          subtitle: "View your income breakdown",
                          icon: Icons.trending_up,
                          color: Colors.green,
                          onTap: () async {
                            final generator = IncomePdfGenerator();
                            await generator.generateAndSaveIncomeReport();
                          },
                        ),
                        const SizedBox(height: 16),
                        enhancedIconItemRow(
                          theme: theme,
                          title: "Budget Report",
                          subtitle: "Track your budget performance",
                          icon: Icons.account_balance_wallet,
                          color: Colors.blue,
                          onTap: () async {
                            final generator = BudgetPdfGenerator();
                            await generator.generateAndSaveBudgetReport();
                          },
                        ),

                         enhancedIconItemRow(
                          theme: theme,
                          title: "Saving report",
                          subtitle: "Track your saving  performance",
                          icon: Icons.savings,
                          color: Colors.blue,
                          onTap: () async {
                            final generator = SavingPdfGenerator();
                            await generator.generateAndSaveSavingReport();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Theme Section
                  sectionTitle("Appearance", textColor, Icons.palette),
                  const SizedBox(height: 12),
                  enhancedContainer(
                    theme,
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedTheme == 'Light'
                                  ? primaryColor
                                  : theme.dividerColor.withOpacity(0.2),
                            ),
                            color: selectedTheme == 'Light'
                                ? primaryColor.withOpacity(0.1)
                                : null,
                          ),
                          child: RadioListTile<String>(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.light_mode,
                                  color: selectedTheme == 'Light'
                                      ? primaryColor
                                      : textColor?.withOpacity(0.6),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Light Mode',
                                  style: TextStyle(
                                    fontWeight: selectedTheme == 'Light'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            value: 'Light',
                            groupValue: selectedTheme,
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                selectedTheme = value!;
                                themeController.setThemeMode(ThemeMode.light);
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedTheme == 'Dark'
                                  ? primaryColor
                                  : theme.dividerColor.withOpacity(0.2),
                            ),
                            color: selectedTheme == 'Dark'
                                ? primaryColor.withOpacity(0.1)
                                : null,
                          ),
                          child: RadioListTile<String>(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.dark_mode,
                                  color: selectedTheme == 'Dark'
                                      ? primaryColor
                                      : textColor?.withOpacity(0.6),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontWeight: selectedTheme == 'Dark'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            value: 'Dark',
                            groupValue: selectedTheme,
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                selectedTheme = value!;
                                themeController.setThemeMode(ThemeMode.dark);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Account Section Title
                  sectionTitle("Account", textColor, Icons.person_outline),
                  const SizedBox(height: 12),

                  // Logout Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                      ),
                      color: Colors.red.withOpacity(0.05),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await AuthenticationService().signOut();
                          Get.to(const SignInView());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.red.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom padding to ensure content is visible
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, Color? color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget enhancedContainer(ThemeData theme, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget enhancedIconItemRow({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.download,
                  size: 16,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}