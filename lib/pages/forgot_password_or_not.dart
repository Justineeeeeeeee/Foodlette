import 'package:flutter/material.dart';
import 'package:foodlettemobile/pages/login_page.dart';
import 'forgot_password.dart';

class ForgotPasswordOrNot extends StatefulWidget {
  const ForgotPasswordOrNot({super.key});

  @override
  State<ForgotPasswordOrNot> createState() => _ForgotPasswordOrNot();
}

class _ForgotPasswordOrNot extends State<ForgotPasswordOrNot> {
  //Initially Login page
  bool showLoginPage = true;

  //toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return ForgotPassword(
        onTap: togglePages,
      );
    }
  }
}
