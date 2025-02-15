import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../login_page/login_page_view.dart';

class SignupController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void toggleObscureText() {
    obscureText = !obscureText;
    notifyListeners();
  }

  String? emailError;
  String? nameError;
  String? passwordError;

  void signUpEmail(String email) {
    if (email.contains('@') && email.contains('.')) {
      emailError = null;
    } else {
      emailError = 'Enter a valid email';
    }
    notifyListeners();
  }

  void signUpName(String name) {
    if (name.isNotEmpty) {
      emailError = null;
    } else {
      emailError = 'Enter your name';
    }
    notifyListeners();
  }

  void signUpPassword(String password) {
    if (password.length >= 6) {
      passwordError = null;
    } else {
      passwordError = 'Password must be at least 6 characters';
    }
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      _showSnackbar(
          context, "Please insert your details to sign up.", Colors.red);
    } else {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await userCredential.user?.updateDisplayName(nameController.text);

        _showSnackbar(context, "User successfully created", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        _showSnackbar(context, "${e.message}", Colors.red);
      }
    }
  }
}

void _showSnackbar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}
