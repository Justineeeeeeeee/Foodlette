import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodlettemobile/components/log_holder.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final usernameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();

  // Password visibility states
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Terms and conditions checkbox state
  bool _isTermsAccepted = false;

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      showErrorMessage("Passwords don't match!");
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );

      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'email': usernameController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showErrorMessage("An account already exists for that email.");
      } else {
        showErrorMessage("An error occurred. Please try again.");
      }
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  void showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: const SingleChildScrollView(
            child: Text(
              '''Effective Date: February 12, 2025

  Welcome to Foodlette! By accessing or using our platform, you agree to comply with these Terms and Conditions. Please read them carefully.

  1. Acceptance of Terms

  By using Foodlette, you agree to abide by these Terms and Conditions. If you do not agree, please do not use our platform.

  2. Description of Service

  Foodlette provides a platform for users to explore and share food-related content, including recipes, meal ideas, and restaurant recommendations.

  3. User Responsibilities

  You must provide accurate and honest information when using our platform.

  You are responsible for ensuring your interactions on the platform comply with all applicable laws.

  You may not use Foodlette for any unlawful activities.

  4. Limitation of Liability

  Foodlette is not responsible for any inaccuracies in user-submitted content.

  We do not guarantee the accuracy, safety, or quality of any recipes or food recommendations shared on the platform.

  Foodlette shall not be liable for any direct or indirect damages resulting from your use of the platform.

  5. Privacy Policy

  Your privacy is important to us. Please refer to our Privacy Policy for details on how we collect, use, and protect your information.

  6. Modifications to Terms

  We may update these Terms from time to time. Continued use of Foodlette after updates signifies your acceptance of the changes.

  7. Termination

  We reserve the right to suspend or terminate your access to Foodlette if you violate these Terms.

  8. Contact Information

  If you have any questions about these Terms, please contact us at Foodlette@gmail.com.

  By using Foodlette, you acknowledge that you have read and agreed to these Terms and Conditions.

  ''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const LogoHolder(imagePath: 'lib/images/foodLetteLogo.png'),

                    // Container with border
                    Container(
                      margin: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF975102),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Please fill out the details below!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Email Textfield without Eye Icon
                          TextField(
                            controller: usernameController,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              // Remove special characters
                              usernameController.text =
                                  value.replaceAll(RegExp(r'[^\w@.]'), '');
                              usernameController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: usernameController.text.length),
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // Password Textfield with Eye Icon
                          TextField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Confirm Password Textfield with Eye Icon
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Terms and Conditions Checkbox
                          Row(
                            children: [
                              Checkbox(
                                activeColor: Colors.white,
                                checkColor: Colors.black,
                                side: const BorderSide(
                                  color: Colors.black,
                                ),
                                value: _isTermsAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    _isTermsAccepted = value!;
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: showTermsAndConditions,
                                child: const Text(
                                  'I accept the Terms and Conditions',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Sign-up Button
                          GestureDetector(
                            onTap: _isTermsAccepted ? register : null,
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.all(10),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              decoration: BoxDecoration(
                                color: _isTermsAccepted
                                    ? const Color(0xFFD8B144)
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF975102),
                                  width: 2.0,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Already have an account?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an Account?',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: const Text(
                                  'Login Now',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
