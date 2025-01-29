import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodlettemobile/components/my_button.dart';
import 'package:foodlettemobile/components/log_holder.dart';
import 'package:lottie/lottie.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child:
              Lottie.asset('lib/images/Progress.json', width: 250, height: 250),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Invalid credentials",
                style: const TextStyle(color: Color.fromARGB(255, 17, 17, 17)),
              ),
            ),
          ); // AlertDialog
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background animation
          Positioned(
            child: Lottie.asset(
              'lib/images/Background.json',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            bottom: 98,
            top: 0,
          ),
          Positioned(
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees in radians
              child: Lottie.asset(
                'lib/images/Background.json',
                fit: BoxFit.cover,
                width: 500,
                height: 100,
              ),
            ),
            bottom: 1,
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const LogoHolder(imagePath: 'lib/images/foodLetteLogo.png'),
                  // Logo
                  const SizedBox(height: 15),
                  // Container with a border
                  Container(
                    margin: const EdgeInsets.all(15.0),

                    padding:
                        const EdgeInsets.all(12.0), // Optional: Add padding
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF975102),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        // Welcome Back user!
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Email Textfield with Show Email button
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Password Textfield with Show Password button
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: togglePasswordVisibility,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Forgot Password
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ForgotPassword();
                                },
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Login Button
                        MyButton(onTap: signUserIn),
                        const SizedBox(height: 15),

                        // Not a member? Register now
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Not a member?',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                'Register now',
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
        ],
      ),
    );
  }
}
