import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:foodlettemobile/api/firebase_notifications.dart';
import 'package:foodlettemobile/models/user_model.dart';
import 'package:foodlettemobile/pages/temperature_graph.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:model_viewer_plus/model_viewer_plus.dart';

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

@override
bool shouldReclip(CustomClipper<Path> oldClipper) => false;

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
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    FirebaseApi().getFirebaseToken();
    _startButtonText = "START";
    _startButtonColor = const Color.fromARGB(255, 67, 238, 72);
    _stopButtonText = "STOP";
    _stopButtonColor = const Color(0xFFF44336);
    _fetchUserName();
    _initializePermissions();
    _checkTemperatureAndNotify();
    Timer.periodic(Duration(seconds: 5), (timer) {
      _checkTemperatureAndNotify();
    });

    currentWeight.onValue.listen(
      (event) {
        setState(() {
          _actualWeightController.text = event.snapshot.value.toString();
        });
      },
    );
  }

  Future<void> _initializePermissions() async {
    await Permission.bluetooth.request();
    await Permission.camera.request();
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
  final TextEditingController _cornController = TextEditingController();
  final TextEditingController _beansController = TextEditingController();
  final _passwordController = TextEditingController();
  final _actualVegetableController = TextEditingController();
  final TextEditingController _actualWeightController = TextEditingController();

  DatabaseReference currentWeight =
      FirebaseDatabase.instance.ref().child('weight');

  final _actualCornController = TextEditingController();
  final _actualBeansController = TextEditingController();
  final _estimatedOutputController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  // Add these variables to control password visibility
  bool _isPasswordVisible = false; // To control password visibility
  bool _isNewPasswordVisible = false; // For new password visibility
  bool _isConfirmPasswordVisible = false; // For confirm password visibility
  bool _isEditing = false;
  final firestoreService = DatabaseService();

  // Function to pick an image from the gallery

  Future<void> _pickImage() async {
    // Request storage permission
    final permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      // Pick an image from the gallery
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _saveImageLocally(_image!);
      }
    } else if (permissionStatus.isDenied) {
      // Show a snackbar if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permission denied. Please grant access to photos."),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (permissionStatus.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied
      openAppSettings();
    }
  }

  Future<void> _saveImageLocally(File image) async {
    // Your implementation to save the image locally
  }

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

  void _checkTemperatureAndNotify() {
    DatabaseReference currentTemp =
        FirebaseDatabase.instance.ref().child('currentTemp');

    currentTemp.once().then((event) {
      if (event.snapshot.value != null) {
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
            'vibration': true,
          });
        }
      }
    });
  }

  // Toggle Edit Mode

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (!_isEditing) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      userDoc.get().then((docSnapshot) async {
        if (docSnapshot.exists) {
          if (_nameController.text != docSnapshot.data()?['name'] ||
              _emailController.text != docSnapshot.data()?['email'] ||
              _birthdayController.text != docSnapshot.data()?['birthday']) {
            firestoreService.update(
              _nameController.text,
              _emailController.text,
              _birthdayController.text,
              null,
              context,
            );
          }

          if (_passwordController.text.isNotEmpty ||
              _newPasswordController.text.isNotEmpty ||
              _confirmPasswordController.text.isNotEmpty) {
            try {
              // Reauthenticate the user with the current password
              AuthCredential credential = EmailAuthProvider.credential(
                email: user.email!,
                password: _passwordController.text,
              );
              await user.reauthenticateWithCredential(credential);

              if (_passwordController.text.isEmpty ||
                  _newPasswordController.text.isEmpty ||
                  _confirmPasswordController.text.isEmpty) {
                setState(() {
                  _isEditing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Password fields cannot be empty."),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (_newPasswordController.text ==
                  _confirmPasswordController.text) {
                firestoreService.update(
                  _nameController.text,
                  _emailController.text,
                  _birthdayController.text,
                  _newPasswordController.text,
                  context,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Passwords do not match."),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {
                  _isEditing = true;
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Current password is incorrect.",
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {
                _isEditing = true;
              });
            }
          }
        }
      });
    }
  }

  final List<Widget> _navigationItem = [
    Icon(Icons.dashboard),
    Icon(Icons.agriculture),
    Icon(Icons.person),
    StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('userNotifications')
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final notifications = snapshot.data!;
          final activeNotifications = notifications
              .where(
                  (notification) => notification['notificationStatus'] == true)
              .toList();
          return Stack(
            children: [
              Icon(Icons.notifications),
              if (activeNotifications.isNotEmpty)
                Positioned(
                  right: 0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${activeNotifications.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        } else {
          return Icon(Icons.notifications);
        }
      },
    )
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
            _buildEditableProfileField(
                "Name", _nameController, Icons.person, _isEditing),
            SizedBox(height: 20),
            _buildEditableProfileField(
                "Email", _emailController, Icons.email, _isEditing),
            SizedBox(height: 20),
            _buildEditableProfileField(
              "Birthday",
              _birthdayController,
              Icons.calendar_today,
              false,
            ),

            if (_isEditing) // Show only when editing
              ElevatedButton.icon(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.black,
                ),
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
                "Password",
                _passwordController,
                Icons.lock,
                _isEditing,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
              ),
              SizedBox(height: 10),
              _buildEditableProfileField(
                  "New Password",
                  _newPasswordController,
                  Icons.lock,
                  isPassword: true,
                  isPasswordVisible: _isNewPasswordVisible,
                  _isEditing),
              SizedBox(height: 10),
              _buildEditableProfileField("Confirm Password",
                  _confirmPasswordController, Icons.lock, _isEditing,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible),
            ],

            // Edit Button
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: Colors.black,
                  ),
                  label: Text(_isEditing ? "Save Changes" : "Edit Profile"),
                  onPressed: _toggleEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8B144),
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
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

  Widget _buildEditableProfileField(String label,
      TextEditingController controller, IconData icon, bool isEditing,
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
                enabled: isEditing, // Enable editing when in edit mode
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

  Widget _buildGenerateFeedPage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.4;
    final containerHeight = containerWidth * 0.3;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Generate Feeds',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Waste Vegetable Content'),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 8),
                Container(
                  width:
                      175, // Adjust the width to accommodate the text and unit
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                          LengthLimitingTextInputFormatter(
                              8), // Set text limit to 8
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: const Color(0xFFD8B144),
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            double wasteVegetableContent = double.parse(value);
                            double totalContent =
                                wasteVegetableContent / 0.2450;
                            double cornContent = totalContent * 0.59;
                            double vegetableContent = totalContent * 0.2450;
                            double beansContent = totalContent * 0.2450;
                            _cornController.text =
                                cornContent.toStringAsFixed(2);
                            _actualVegetableController.text =
                                vegetableContent.toStringAsFixed(2);
                            _beansController.text =
                                beansContent.toStringAsFixed(2);
                            double estimatedOutput = (wasteVegetableContent +
                                    cornContent +
                                    beansContent) *
                                0.95;
                            _estimatedOutputController.text =
                                estimatedOutput.toStringAsFixed(2);
                            double estimatedTime =
                                (wasteVegetableContent / 10) * 16;
                            _estimatedTimeController.text =
                                estimatedTime.toStringAsFixed(
                                    0); // Estimated time in seconds
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Grams',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Ingredients'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _cornController,
                        decoration: InputDecoration(
                          labelText: 'Carbs',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          suffixText: 'Grams',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFFD8B144),
                              width: 2.0,
                            ),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _beansController,
                        decoration: InputDecoration(
                          labelText: 'Protein',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          suffixText: 'Grams',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFFD8B144),
                              width: 2.0,
                            ),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _estimatedOutputController,
                        decoration: InputDecoration(
                          labelText: 'Estimated Output',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          suffixText: 'Grams',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFFD8B144),
                              width: 2.0,
                            ),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _estimatedTimeController,
                        decoration: InputDecoration(
                          labelText: 'Estimated Time',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          suffixText: 'Seconds',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFFD8B144),
                              width: 2.0,
                            ),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 23),
            Column(
              children: [
                TextField(
                  controller: _actualWeightController,
                  decoration: InputDecoration(
                    labelText: 'Weighing Scale',
                    labelStyle: TextStyle(
                      color: Colors.black54,
                    ),
                    suffixText: 'Grams',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFFD8B144),
                        width: 2.0,
                      ),
                    ),
                  ),
                  readOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Remaining Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<int>(
                    stream: _startButtonText == "OPERATING"
                        ? Stream.periodic(Duration(seconds: 1), (x) => x + 1)
                        : Stream.value(0),
                    builder: (context, snapshot) {
                      if (_startButtonText == "OPERATING") {
                        _elapsedSeconds = snapshot.data ?? 0;
                      }
                      final totalSeconds =
                          int.tryParse(_estimatedTimeController.text) ?? 0;
                      final remainingSeconds = totalSeconds - _elapsedSeconds;
                      if (remainingSeconds <= 0 ||
                          _startButtonText != "OPERATING") {
                        _elapsedSeconds = 0;
                        if (_startButtonText == "OPERATING") {
                          FirebaseDatabase.instance
                              .ref()
                              .child('relayState')
                              .set(false);
                          setState(() {
                            _startButtonText = "START";
                            _startButtonColor =
                                const Color.fromARGB(255, 67, 238, 72);
                          });
                        }
                        return Text(
                          '00:00',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        );
                      }
                      final minutes =
                          (remainingSeconds ~/ 60).toString().padLeft(2, '0');
                      final seconds =
                          (remainingSeconds % 60).toString().padLeft(2, '0');
                      return Text(
                        '$minutes:$seconds',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth * 0.95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (_startButtonText == "START" ||
                            _startButtonText == null)
                        ? () {
                            setState(() {
                              // Change the start button text to "STARTING"
                              _startButtonText = "STARTING";
                              _startButtonColor = Colors.white;
                              // Update the machine status to true
                              FirebaseDatabase.instance
                                  .ref()
                                  .child('relayState')
                                  .set(true);
                            });
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() {
                                // Change the background color to white and text to "OPERATING" after delay
                                _startButtonColor = Colors.white;
                                _startButtonText = "OPERATING";
                                _elapsedSeconds = 0; // Reset elapsed seconds
                              });
                            });
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "No Operation Performed. Please fill in the fields."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
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
                              FirebaseDatabase.instance
                                  .ref()
                                  .child('relayState')
                                  .set(false);
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

  Widget _buildHomePage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.4;

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
// 3D Model Viewer
            Container(
              height: 300,
              child: const ModelViewer(
                src: "lib/images/fudlek.glb",
                alt: "A 3D model of an astronaut",
                ar: true,
                autoRotate: true,
                cameraControls: true,
                cameraOrbit: "0deg 75deg 2%", // Set 5% zoom
              ),
            ),
            const SizedBox(height: 30),
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
                              color: double.parse(realTimeStorage) < 30
                                  ? Colors.red
                                  : (double.parse(realTimeStorage) < 60
                                      ? Colors.yellow
                                      : (double.parse(realTimeStorage) <= 75
                                          ? Colors.orange
                                          : Colors.green)),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TemperaturePage()),
                      );
                    },
                    child: Container(
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
                    final activeNotifications = notifications
                        .where((notification) =>
                            notification['notificationStatus'] == true)
                        .toList();
                    if (activeNotifications.isEmpty) {
                      return Text('No notifications found.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: activeNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = activeNotifications[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Card(
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
                                              .update({
                                            'notificationStatus': false
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
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
                    expandedHeight: 120.0,
                    floating: true,
                    snap: true,
                    pinned: false,
                    flexibleSpace: ClipPath(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(),
                        child: FlexibleSpaceBar(
                          titlePadding: EdgeInsets.only(top: 20.0),
                          centerTitle: true,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Image.asset(
                                  'lib/images/bradingLogo.png',
                                  width: 250,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.connect_without_contact),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController
                                          _textfieldMachineID =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('machine I.D'),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                        content: TextField(
                                          controller: _textfieldMachineID,
                                          decoration: InputDecoration(
                                              hintText: "00012"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              String machineID =
                                                  _textfieldMachineID.text
                                                      .trim();
                                              if (machineID.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Machine ID cannot be empty."),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                                return;
                                              }
                                              DocumentReference machineRef =
                                                  FirebaseFirestore.instance
                                                      .collection('Machines')
                                                      .doc(machineID);
                                              DocumentSnapshot snapshot =
                                                  await machineRef.get();
                                              if (snapshot.exists) {
                                                await machineRef
                                                    .collection('Machines')
                                                    .doc('MachineStatus')
                                                    .set({
                                                  'MachineStatus': false
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Machine Disconnected."),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Machine ID does not exist."),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text('Disconnect'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              String machineID =
                                                  _textfieldMachineID.text
                                                      .trim();
                                              if (machineID.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Machine ID cannot be empty."),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                                return;
                                              }
                                              DocumentReference machineRef =
                                                  FirebaseFirestore.instance
                                                      .collection('Machines')
                                                      .doc(machineID);
                                              DocumentSnapshot snapshot =
                                                  await machineRef.get();
                                              if (snapshot.exists) {
                                                DocumentReference
                                                    machineStatusRef =
                                                    machineRef
                                                        .collection('Status')
                                                        .doc('MachineStatus');
                                                DocumentSnapshot
                                                    statusSnapshot =
                                                    await machineStatusRef
                                                        .get();
                                                if (statusSnapshot.exists &&
                                                    statusSnapshot[
                                                            'MachineStatus'] ==
                                                        true) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Machine is in use."),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ),
                                                  );
                                                } else {
                                                  await machineStatusRef.set(
                                                      {'MachineStatus': true});
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          Text("Connected."),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Machine ID does not exist."),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Connect'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _page == 0
                        ? _buildHomePage(context)
                        : _page == 2
                            ? _buildUserProfilePage(context)
                            : _page == 3
                                ? _buildNotificationsPage(context)
                                : _page == 1
                                    ? _buildGenerateFeedPage(context)
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
              return Lottie.asset('images/Progress.json');
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
