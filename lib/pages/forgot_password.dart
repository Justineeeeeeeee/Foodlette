import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodlettemobile/components/my_textfield.dart';
import 'package:foodlettemobile/components/log_holder.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPassword> {
  // text editing controllers
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordRest() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Password reset link sent!"),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFECB),
      ),
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const LogoHolder(imagePath: 'lib/images/foodLetteLogo.png'),
              // Container with a border
              Container(
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        const Color(0xFF975102), // Customize the border color
                    width: 2.0, // Customize the border thickness
                  ),
                  borderRadius: BorderRadius.circular(
                      8.0), // Optional: Add rounded corners
                ),
                padding: const EdgeInsets.all(16.0), // Optional: Add padding
                child: Column(
                  children: [
                    // Welcome Back user!
                    Text(
                      'Enter your email to get reset link',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Username Textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        passwordRest();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8B144),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                                0xFF975102), // Customize the border color
                            width: 2.0, // Customize the border thickness
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Send Verification",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
