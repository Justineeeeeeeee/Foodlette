import 'package:flutter/material.dart';

class LogoHolder extends StatelessWidget {
  final String imagePath;
  const LogoHolder({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20), // BoxDecoration
      child: Image.asset(
        imagePath,
        height: 120,
      ),
    ); // Image.asset ); // Container
  }
}
