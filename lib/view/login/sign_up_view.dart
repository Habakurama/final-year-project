import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/secondary_button.dart';
import 'package:untitled/common_widget/snack_bar.dart';
import 'package:untitled/service/AuthenticationService.dart';
import 'package:untitled/view/login/sign_in_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final textName = TextEditingController();
  final textPhone = TextEditingController();
  final textEmail = TextEditingController();
  final textPassword = TextEditingController();
  final textConfirmPass = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    textEmail.dispose();
    textPassword.dispose();
    textConfirmPass.dispose();
    textName.dispose();
    textPhone.dispose();
    super.dispose();
  }

  void signUpUser() async {
    if (textName.text.isEmpty ||
        textPhone.text.isEmpty ||
        textEmail.text.isEmpty ||
        textPassword.text.isEmpty ||
        textConfirmPass.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all the fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String res = await AuthenticationService().signUpUser(
      email: textEmail.text,
      name: textName.text,
      password: textPassword.text,
      phone: textPhone.text,
      confirmPassword: textConfirmPass.text,
    );

    setState(() {
      isLoading = false;
    });

    if (res == "success") {
      Get.snackbar(
        "Success",
        "Signup completed successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.to(() => const SignInView());
    } else {
      Get.snackbar(
        "Error",
        res,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final labelColor = theme.textTheme.bodyMedium?.color ?? Colors.black54;
    final hintColor = theme.hintColor;
    final dividerColor = theme.dividerColor;
    final scaffoldBackground = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              "Welcome, please Sign Up",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input Fields
                          _buildTextField(
                              "Username", "Enter your username", textName,
                              TextInputType.text, labelColor, hintColor, dividerColor),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "Phone Number", "Enter your phone", textPhone,
                              TextInputType.phone, labelColor, hintColor, dividerColor),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "Email", "Enter your email", textEmail,
                              TextInputType.emailAddress, labelColor, hintColor, dividerColor),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "Password", "eg:Hello@2024", textPassword,
                              TextInputType.visiblePassword,
                              labelColor, hintColor, dividerColor,
                              obscureText: true),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "Confirm Password",
                              "Re-enter your password",
                              textConfirmPass,
                              TextInputType.visiblePassword,
                              labelColor,
                              hintColor,
                              dividerColor,
                              obscureText: true),

                          const SizedBox(height: 20),

                          PrimaryButton(
                            title: "Sign Up",
                            onPress: signUpUser,
                            color: theme.primaryColor,
                          ),

                          const SizedBox(height: 30),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: labelColor,
                                  ),
                                ),
                                SecondaryButton(
                                  title: "Sign In",
                                  onPress: () {
                                    Get.to(() => const SignInView());
                                  },
                                  color: theme.primaryColor,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller,
    TextInputType keyboardType,
    Color labelColor,
    Color hintColor,
    Color dividerColor, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: TextStyle(fontSize: 15, color: labelColor),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(color: hintColor),
                  contentPadding: const EdgeInsets.only(bottom: 5),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 1,
          color: dividerColor,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
