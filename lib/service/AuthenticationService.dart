import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled/common/color_extension.dart';


class AuthenticationService {

  //for storing data in cloud firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for authentication
  final FirebaseAuth auth = FirebaseAuth.instance;


  final box = GetStorage();

//for signup

  Future<String> signUpUser({
    required String email,
    required String name,
    required String password,
    required String phone,
    required String confirmPassword,
  }) async {
    String res = "Some error occurred";

    // Perform all validations before Firebase operations
    if (email.isEmpty || name.isEmpty || password.isEmpty || phone.isEmpty || confirmPassword.isEmpty) {
      return "Please fill in all the fields.";
    }

    if (!isValidEmail(email)) {
      return "Invalid email address format.";
    }

    if (!isValidPassword(password)) {
      return "Password must be at least 8 characters long and include a mix of letters, numbers, and special characters.";
    }

    if (password != confirmPassword) {
      return "Passwords do not match.";
    }

    try {
      await box.erase(); // Clear local box
      await FirebaseAuth.instance.signOut(); // Ensure no user is logged in

      // Proceed to create the user after validations pass
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("User created successfully with UID: ${credential.user!.uid}");

      // Save user data to Firestore
      await firestore.collection("users").doc(credential.user!.uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "uid": credential.user!.uid,
        
      });

      Get.snackbar("Success", "Signup successful", colorText: TColor.line);
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = 'Email is already in use';
      } else if (e.code == 'invalid-email') {
        res = 'Invalid email address';
      } else if (e.code == 'weak-password') {
        res = 'Password is too weak';
      } else {
        res = e.message ?? 'An unknown error occurred';
      }
    } catch (e) {
      res = e.toString();
    }

    print("The response is: $res");
    return res;
  }


  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return null; // Not logged in
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print("Error getting current user data: $e");
    }

    return null;
  }


  Future<bool> updateCurrentUserData({
    String? name,
    String? phone,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final Map<String, dynamic> updatedData = {};

      // Update name and phone if provided
      if (name != null) updatedData['name'] = name;
      if (phone != null) updatedData['phone'] = phone;

      // Update Firestore user profile if there is any change
      if (updatedData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(updatedData);
      }

      await getCurrentUserData();

      return true;
    } on FirebaseAuthException catch (e) {
      print("get FirebaseAuthException: Code=${e.code}, Message=${e.message}");
      if (e.code == 'requires-recent-login') {
        Get.snackbar("Auth Error", "Please log in again to update your email or password.");
      } else if (e.code == 'wrong-password') {
        Get.snackbar("Auth Error", "Incorrect password. Please try again.");
      } else {
        print("auth error : message=${e.message}");
        Get.snackbar("Auth Error", e.message ?? "An unknown error occurred.");
      }
      return false;
    } catch (e, stackTrace) {
      print("Unexpected error updating user data: $e");
      print("StackTrace: $stackTrace");
      Get.snackbar("Error", e.toString(), colorText: TColor.secondary0);
      return false;
    }
  }






  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> res = {
      'status': 'error',
      'message': 'Some error occurred',
    };

    await box.erase();
    // Log out the user to ensure no user is logged in when the app starts
    await FirebaseAuth.instance.signOut();


    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      final userEmail = userCredential.user?.email;




      //  return user info on success
      res = {
        'status': 'success',
        'uid': uid,
        'email': userEmail,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res['message'] = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        res['message'] = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        res['message'] = "Invalid email address.";
      } else {
        res['message'] = e.message ?? "An unknown error occurred";
      }
    } catch (e) {
      print("error was occurred is:, ${e.toString()}");
      res['message'] = e.toString();
    }

    return res; // Now returning a Map with user data or error
  }


  //for logout
  Future<void> signOut() async {
    await auth.signOut(); // Sign out from Fire

    // Clear saved user info from GetStorage
    box.remove('uid');
    box.remove('email');
    box.remove('isLoggedIn');
 // Replace LoginPage with your actual login screen
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }
  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
        '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#\$%\\^&\\*\\(\\)_\\+\\-=\\[\\]\\{\\};:\\\'",<>\\./?\\\\|`~]).{8,}\$'
    );
    return passwordRegex.hasMatch(password);
  }




}