import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodlettemobile/components/my_textfield.dart';
import 'package:foodlettemobile/components/log_holder.dart';
import 'package:lottie/lottie.dart';

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

  Future passwordReset() async {
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
      body: Stack(
        children: [
          // Background animation
          Positioned(
            bottom: 98,
            top: 0,
            child: Lottie.asset(
              'lib/images/Background.json',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const LogoHolder(imagePath: 'lib/images/foodLetteLogo.png'),
                  // Center the container
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(
                              0xFF975102), // Customize the border color
                          width: 2.0, // Customize the border thickness
                        ),
                        borderRadius: BorderRadius.circular(
                            8.0), // Optional: Add rounded corners
                      ),
                      padding:
                          const EdgeInsets.all(16.0), // Optional: Add padding
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Welcome Back user!
                          Text(
                            'Enter your email to get reset link',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Email Textfield
                          MyTextField(
                            controller: emailController,
                            hintText: 'Email',
                            obscureText: false,
                            onChanged: (value) {
                              emailController.text =
                                  value.replaceAll(RegExp(r'[^\w@.]'), '');
                              emailController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: emailController.text.length),
                              );
                            },
                            Function: (value) {},
                          ),

                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              passwordReset();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 10,
            top: 35,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
