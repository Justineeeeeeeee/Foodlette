import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signOutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              // Top Row: Username, Notifications, and Sign-Out
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellowAccent),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: Colors.purple),
                          SizedBox(width: 8),
                          Text('USERNAME',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellowAccent),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications, color: Colors.black),
                          SizedBox(width: 8),
                          Text('NOTIFICATIONS',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellowAccent),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: signOutUser,
                            icon: Icon(Icons.logout, color: Colors.red),
                          ),
                          Text(
                            'SIGN-OUT',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Humidity, Photo, Weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfoBox(
                      label: 'HUMIDITY',
                      value: '29°C',
                      color: Colors.orange,
                      width: 110),
                  InfoBox(
                    label: 'ACTUAL PHOTO OF MACHINE',
                    value: 'PHOTO',
                    isPhoto: true,
                    width: 110,
                  ),
                  InfoBox(
                      label: 'WEIGHT',
                      value: '1.45 Kg',
                      color: Colors.orange,
                      width: 110),
                ],
              ),
              SizedBox(height: 16),

              // Storage, Temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfoBox(
                      label: 'STORAGE',
                      value: '70%',
                      color: Colors.green,
                      width: 150),
                  InfoBox(
                      label: 'TEMPERATURE',
                      value: '45°C',
                      color: Colors.red,
                      width: 150),
                ],
              ),
              SizedBox(height: 16),

              // PM-1, PM-2, PM-3 Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ImageBox(
                      label: 'PM-1', imagePath: 'assets/pm1.png', width: 100),
                  ImageBox(
                      label: 'PM-2', imagePath: 'assets/pm2.png', width: 100),
                  ImageBox(
                      label: 'PM-3', imagePath: 'assets/pm3.png', width: 100),
                ],
              ),
              SizedBox(height: 20),

              // Start and Stop Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButton(label: 'START', color: Colors.green),
                  ActionButton(label: 'STOP', color: Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Widget for Info Box
class InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isPhoto;
  final double width;

  InfoBox({
    required this.label,
    required this.value,
    this.color,
    this.isPhoto = false,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellowAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          if (isPhoto)
            Container(
              height: 50,
              color: Colors.grey,
              child: Center(child: Text('PHOTO')),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

// Custom Widget for Image Box
class ImageBox extends StatelessWidget {
  final String label;
  final String imagePath;
  final double width;

  ImageBox({required this.label, required this.imagePath, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellowAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 60, fit: BoxFit.cover),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Custom Widget for Action Button
class ActionButton extends StatelessWidget {
  final String label;
  final Color color;

  ActionButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
