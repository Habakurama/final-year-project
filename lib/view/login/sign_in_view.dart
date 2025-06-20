import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/primary_button.dart';
import 'package:untitled/common_widget/secondary_button.dart';
import 'package:untitled/service/AuthenticationService.dart';
import 'package:untitled/view/main_tab/main_tab_view.dart';
import '../../controller/app_initialization_controller.dart';
import 'sign_up_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final textEmail = TextEditingController();
  final textPassword = TextEditingController();
  bool isLoading = false;
  final box = GetStorage();

  final auth = FirebaseAuth.instance;

  @override
  void dispose() {
    textEmail.dispose();
    textPassword.dispose();
    super.dispose();
  }

  void signInUser() async {
    if (textEmail.text.isEmpty || textPassword.text.isEmpty) {
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

    Map<String, dynamic> res = await AuthenticationService().loginUser(
      email: textEmail.text,
      password: textPassword.text,
    );

    setState(() {
      isLoading = false;
    });

    if (res['status'] == "success") {
      String uid = res['uid'];
      String? email = res['email'];

      box.write('uid', uid);
      box.write('email', email ?? '');
      box.write('isLoggedIn', true);

      final appInitController = Get.put(AppInitializationController());
      await appInitController.initialize();

      Get.snackbar(
        "Success",
        "Sign in completed successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.to(() => const MainTabView());
    } else {
      print("Error during sign in: ${res['message']}");
      // Show error message
      Get.snackbar(
        "Error",
        res['message'],
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final grayColor = Theme.of(context).disabledColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBackground = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              "Welcome! Please Sign In",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: grayColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildTextField(
                            "Email",
                            "Enter your email",
                            textEmail,
                            TextInputType.emailAddress,
                            textColor: textColor,
                            grayColor: grayColor,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField("Password", "Enter your password", textPassword,
                              TextInputType.visiblePassword,
                              obscureText: true, textColor: textColor, grayColor: grayColor),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  myDialogBox(context, grayColor, cardBackground, textColor);
                                },
                                child: Text(
                                  "Forgot password",
                                  style: TextStyle(
                                    color: grayColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            title: "Sign In",
                            onPress: signInUser,
                            color: TColor.white,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grayColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SecondaryButton(
                                title: "Signup",
                                onPress: () {
                                  Get.to(() => const SignUpView());
                                },
                                color: Colors.green,
                              ),
                            ],
                          ),
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
    TextInputType keyboardType, {
    bool obscureText = false,
    required Color textColor,
    required Color grayColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(fontSize: 15, color: textColor),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: grayColor.withOpacity(0.6)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: grayColor.withOpacity(0.3)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: grayColor),
            ),
            contentPadding: const EdgeInsets.only(bottom: 5),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  void myDialogBox(BuildContext context, Color grayColor, Color background, Color textColor) {
    final TextEditingController dialogEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Forget Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close, color: grayColor),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dialogEmailController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: "Enter the email to reset password",
                    labelStyle: TextStyle(color: grayColor),
                    hintText: "eg my@gmail.com",
                    hintStyle: TextStyle(color: grayColor.withOpacity(0.6)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final email = dialogEmailController.text.trim();
                    if (email.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please enter your email",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }

                    try {
                      await auth.sendPasswordResetEmail(email: email);
                      Get.snackbar(
                        "Success",
                        "We have sent you the reset password link to your email, please check it",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                      Navigator.pop(context);
                    } catch (error) {
                      Get.snackbar(
                        "Error",
                        error.toString(),
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grayColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Send",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
