import 'package:flutter/material.dart';
import 'package:tuukatuu/presentation/screens/main_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../utils/double_back_exit.dart';

class AppNavigation {
  static void goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  static void goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Navigate to a screen with double back exit functionality
  static void goToWithDoubleBackExit(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoubleBackExit.wrapWithDoubleBackExit(
          context: context,
          child: screen,
        ),
      ),
    );
  }

  /// Reset the double back exit timer (useful when navigating between screens)
  static void resetDoubleBackTimer() {
    DoubleBackExit.resetTimer();
  }
} 