import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:foodlettemobile/models/user_model.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

String _getMonthName(int month) {
  const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return monthNames[month - 1];
}

class _HomePageState extends State<HomePage> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String realTimeValue = '0';
  String realtimeTemp = '0';
  String realTimeStorage = '0';
  String realTimeMoisture = '0';
  String realTimeVegetables = '0';
  String realTimeWeight = '0';
  final user = FirebaseAuth.instance.currentUser!;
  int _page = 0;
  File? _image; // Holds the user's image
  final TextEditingController _nameController = TextEditingController();
  Color? _startButtonColor; // Define the _startButtonColor variable
  String? _startButtonText;
  String? _stopButtonText;
  Color? _stopButtonColor;
  bool? machineStatus;
  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _checkTemperatureAndNotify();
  }

  Future<void> _fetchUserName() async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      setState(() {
        _nameController.text = docSnapshot.data()?['name'] ?? 'Set your name';
        _emailController.text =
            docSnapshot.data()?['email'] ?? 'Set your email';
        _birthdayController.text =
            docSnapshot.data()?['birthday'] ?? 'Set your birthday';
      });
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Add these variables to control password visibility
  bool _isPasswordVisible = false; // To control password visibility
  bool _isNewPasswordVisible = false; // For new password visibility
  bool _isConfirmPasswordVisible = false; // For confirm password visibility
  bool _isEditing = false;
  final firestoreService = DatabaseService();

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = null;
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _checkTemperatureAndNotify() {
    DatabaseReference currentTemp =
        FirebaseDatabase.instance.ref().child('currentTemp');

    currentTemp.onValue.listen((event) {
      double temp = double.parse(event.snapshot.value.toString());
      if (temp >= 75) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('userNotifications')
            .add({
          'notificationHead': 'High Temperature Alert',
          'notificationContent': 'The temperature has reached $temp℃.',
          'notificationStatus': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Toggle Edit Mode

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (!_isEditing) {
      firestoreService.update(_nameController.text, _emailController.text,
          _birthdayController.text, context);
    }
  }

  final List<Widget> _navigationItem = [
    Icon(Icons.dashboard),
    Icon(Icons.person),
    Icon(Icons.notifications),
  ];
  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Show Dialog message after sign out
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Signed Out"),
          content: Text("You have successfully signed out."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error signing out: $e"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

// Build User Profile Page
  Widget _buildUserProfilePage(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFD8B144),
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.person,
                          size: 50, color: const Color.fromARGB(255, 0, 0, 0))
                      : null,
                ),
                if (_isEditing) // Show only when editing
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon:
                          Icon(Icons.camera_alt, size: 16, color: Colors.black),
                      onPressed: _pickImage, // Pick a new image
                    ),
                  ),
              ],
            ),
            _buildEditableProfileField("Name", _nameController, Icons.person),
            SizedBox(height: 20),
            _buildEditableProfileField("Email", _emailController, Icons.email),
            SizedBox(height: 20),
            _buildEditableProfileField(
                "Birthday", _birthdayController, Icons.calendar_today),
            if (_isEditing) // Show only when editing
              ElevatedButton.icon(
                icon: Icon(Icons.calendar_today),
                label: Text("Pick Birthday"),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _birthdayController.text =
                          "${pickedDate.day} ${_getMonthName(pickedDate.month)} ${pickedDate.year}";
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8B144),
                  foregroundColor: Colors.black,
                ),
              ),

            // Password Fields (shown only when editing)
            if (_isEditing) ...[
              SizedBox(height: 20),
              _buildEditableProfileField(
                  "Password", _passwordController, Icons.lock,
                  isPassword: true, isPasswordVisible: _isPasswordVisible),
              SizedBox(height: 10),
              _buildEditableProfileField(
                  "New Password", _newPasswordController, Icons.lock,
                  isPassword: true, isPasswordVisible: _isNewPasswordVisible),
              SizedBox(height: 10),
              _buildEditableProfileField(
                  "Confirm Password", _confirmPasswordController, Icons.lock,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible),
            ],

            // Edit Button
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  label: Text(_isEditing ? "Save Changes" : "Edit Profile"),
                  onPressed: _toggleEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8B144),
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text("Sign out"),
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableProfileField(
      String label, TextEditingController controller, IconData icon,
      {bool isPassword = false, bool isPasswordVisible = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFFD8B144),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'RobotoSlab',
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: controller,
                enabled: _isEditing, // Enable editing when in edit mode
                obscureText: isPassword &&
                    !isPasswordVisible, // Show password if the checkbox is toggled
                decoration: InputDecoration(
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFFD8B144),
                          ),
                          onPressed: () {
                            setState(() {
                              if (label == "Password") {
                                _isPasswordVisible = !_isPasswordVisible;
                              } else if (label == "New Password") {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              } else if (label == "Confirm Password") {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              }
                            });
                          },
                        )
                      : null, // Only show the eye icon if it's a password field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.4;
    final containerHeight = containerWidth * 0.3;

    DatabaseReference producedToday =
        FirebaseDatabase.instance.ref().child('producedToday');

    DatabaseReference currentTemp =
        FirebaseDatabase.instance.ref().child('currentTemp');

    DatabaseReference currentStorage =
        FirebaseDatabase.instance.ref().child('storage');

    DatabaseReference currentmoisture =
        FirebaseDatabase.instance.ref().child('moisture');

    DatabaseReference currentVegetable =
        FirebaseDatabase.instance.ref().child('vegetable');
    DatabaseReference currentWeight =
        FirebaseDatabase.instance.ref().child('weight');

    producedToday.onValue.listen(
      (event) {
        setState(() {
          realTimeValue = event.snapshot.value.toString();
        });
      },
    );

    currentTemp.onValue.listen(
      (event) {
        setState(() {
          realtimeTemp = event.snapshot.value.toString();
        });
      },
    );

    currentStorage.onValue.listen(
      (event) {
        setState(() {
          realTimeStorage = event.snapshot.value.toString();
        });
      },
    );

    currentmoisture.onValue.listen(
      (event) {
        setState(() {
          realTimeMoisture = event.snapshot.value.toString();
        });
      },
    );
    currentVegetable.onValue.listen(
      (event) {
        setState(() {
          realTimeVegetables = event.snapshot.value.toString();
        });
      },
    );
    currentWeight.onValue.listen(
      (event) {
        setState(() {
          realTimeWeight = event.snapshot.value.toString();
        });
      },
    );

    return SingleChildScrollView(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Image.asset(
              'lib/images/Prototype.png',
              width: 200,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Weight Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: screenWidth * 0.31,
                    height: screenWidth * 0.31,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD8B144),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text(
                          "Produced Today",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${realTimeValue}Kg",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFFD8B144),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Storage Box with Semi-Circle
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: screenWidth * 0.31,
                    height: screenWidth * 0.31,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD8B144),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text(
                          "STORAGE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CircularPercentIndicator(
                          radius: 30.0,
                          lineWidth: 8.0,
                          percent: (double.parse(realTimeStorage) / 100),
                          center: Text(
                            " $realTimeStorage%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: double.parse(realTimeStorage) > 75
                                  ? Colors.green
                                  : (double.parse(realTimeStorage) > 60
                                      ? Colors.orange
                                      : (double.parse(realTimeStorage) >= 30
                                          ? Colors.yellow
                                          : Colors.red)),
                              fontSize: 20,
                            ),
                          ),
                          progressColor: double.parse(realTimeStorage) > 75
                              ? Colors.green
                              : (double.parse(realTimeStorage) > 60
                                  ? Colors.orange
                                  : (double.parse(realTimeStorage) >= 30
                                      ? Colors.yellow
                                      : Colors.red)),
                          backgroundColor: Colors.transparent,
                          circularStrokeCap: CircularStrokeCap.round,
                          startAngle: 180,
                        ),
                      ],
                    ),
                  ),
                  // Temperature Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: screenWidth * 0.31,
                    height: screenWidth * 0.31,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD8B144),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text(
                          "TEMPERATURE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "$realtimeTemp℃",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFFD8B144),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Third Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Weight Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: screenWidth * 0.31,
                    height: screenWidth * 0.31,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD8B144),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text(
                          "WEIGHT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${realTimeWeight}Kg",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFFD8B144),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Storage Box with Semi-Circle

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: screenWidth * 0.31,
                    height: screenWidth * 0.31,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD8B144),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text(
                          "Vegetable",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CircularPercentIndicator(
                          radius: 30.0,
                          lineWidth: 8.0,
                          percent: (double.parse(realTimeVegetables) / 100),
                          center: Text(
                            "$realTimeVegetables%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 20,
                            ),
                          ),
                          progressColor: Colors.green,
                          backgroundColor: Colors.transparent,
                          circularStrokeCap: CircularStrokeCap.round,
                          startAngle: 180,
                        ),
                      ],
                    ),
                  ),
                  // Temperature Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: screenWidth * 0.31,
                    height: screenWidth * 0.31,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD8B144),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text(
                          "MOISTURE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "$realTimeMoisture Cm³",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFFD8B144),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Spacing between the rows and the buttons
            const SizedBox(height: 10.0),
            // Bottom Full-Width Container
            Container(
              margin: const EdgeInsets.all(10.0),
              width: screenWidth * 0.95,
              height: screenWidth * 0.31,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFDF5E6),
                border: Border.all(
                  color: const Color(0xFFD8B144),
                  width: 2.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _startButtonText == "START" ||
                            _startButtonText == null
                        ? () {
                            setState(() {
                              // Change the start button text to "STARTING"
                              _startButtonText = "STARTING";
                              _startButtonColor = Colors.white;
                              // Update the machine status to true
                              firestoreService.updateOnOff(machineStatus: true);
                            });
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() {
                                // Change the background color to white and text to "OPERATING" after delay
                                _startButtonColor = Colors.white;
                                _startButtonText = "OPERATING";
                              });
                            });
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color: _startButtonColor ??
                            const Color.fromARGB(255, 67, 238, 72),
                        border: Border.all(
                          color: const Color.fromARGB(255, 67, 238, 72),
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _startButtonText ?? "START",
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _startButtonText == "OPERATING"
                        ? () {
                            setState(() {
                              // Change the stop button text to "STOPPING"
                              _stopButtonText = "STOPPING";
                              _stopButtonColor = Colors.white;
                              // Update the machine status to false
                              firestoreService.updateOnOff(
                                  machineStatus: false);
                            });
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() {
                                // Reset the stop button text and color after delay
                                _stopButtonText = "STOP";
                                _startButtonText = "START";
                                _startButtonColor =
                                    const Color.fromARGB(255, 67, 238, 72);
                                _stopButtonColor = const Color(0xFFF44336);
                              });
                            });
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color: _stopButtonColor ?? const Color(0xFFF44336),
                        border: Border.all(
                          color: const Color(0xFFF44336),
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _stopButtonText ?? "STOP",
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 22,
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
    );
  }

  Widget _buildNotificationsPage(BuildContext context) {
    // Stream notifications from Firestore
    Stream<List<Map<String, dynamic>>> streamNotifications() {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final notificationsCollection = userDoc.collection('userNotifications');
      return notificationsCollection.snapshots().map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              "NOTIFICATIONS",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: streamNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No notifications found.');
                  } else {
                    final notifications = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        if (notification['notificationStatus'] == true) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Icon(Icons.notifications,
                                  color: Colors.amber),
                              title: Text(notification['notificationHead']),
                              subtitle:
                                  Text(notification['notificationContent']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    child: Text(
                                      'Dismiss',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .collection('userNotifications')
                                          .doc(notification['id'])
                                          .update(
                                              {'notificationStatus': false});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'No notifications found.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<CurvedNavigationBarState> _curvednavigationkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _fApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Someting went wrong with firebase");
            } else if (snapshot.hasData) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 100.0,
                    floating: true,
                    snap: true,
                    pinned: false,
                    flexibleSpace: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(130),
                        bottomRight: Radius.circular(130),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(top: 30.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 212, 106),
                        ),
                        child: FlexibleSpaceBar(
                          titlePadding: EdgeInsets.only(top: 20.0),
                          centerTitle: true,
                          title: Image.asset(
                            'lib/images/bradingLogo.png',
                            width: 120,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _page == 0
                        ? _buildHomePage(context)
                        : _page == 1
                            ? _buildUserProfilePage(context)
                            : _page == 2
                                ? _buildNotificationsPage(context)
                                : Center(
                                    child: Text(
                                      'Page ${_page + 1}',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                  ),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
      bottomNavigationBar: CurvedNavigationBar(
        key: _curvednavigationkey,
        items: _navigationItem,
        color: const Color(0xFFD8B144),
        backgroundColor: Colors.transparent,
        animationDuration: Duration(milliseconds: 500),
        height: 50,
        index: _page,
        onTap: (index) {
          setState(() {
            _page = index; // Update the current page
          });
        },
      ),
    );
  }
}
