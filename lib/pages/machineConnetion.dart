import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MachineConnectionPage extends StatelessWidget {
  final TextEditingController textfieldMachineID = TextEditingController();
  final TextEditingController changePasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machine Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            bool isConnected = true;

            void fetchConnectionStatus() {
              String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              if (uid.isNotEmpty) {
                CollectionReference<Map<String, dynamic>> userRef =
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('isConnected');

                userRef.snapshots().listen((snapshot) {
                  if (snapshot.docs.isNotEmpty) {
                    setState(() {
                      isConnected =
                          snapshot.docs.first.data()['isConnected'] ?? false;
                    });
                  }
                });
              }
            }

            fetchConnectionStatus();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Machine I.D',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: textfieldMachineID,
                  decoration: InputDecoration(
                    hintText: "Enter Machine ID",
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isConnected, // Lock the text field when connected
                ),
                SizedBox(height: 16),
                Text(
                  'Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isConnected, // Lock the text field when connected
                ),
                if (isConnected) ...[
                  SizedBox(height: 16),
                  Text(
                    'Change Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: changePasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Enter New Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Confirm Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirm New Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String machineID = textfieldMachineID.text.trim();
                        if (machineID.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Machine ID cannot be empty."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        DocumentReference machineRef = FirebaseFirestore
                            .instance
                            .collection('Machines')
                            .doc(machineID);
                        DocumentSnapshot snapshot = await machineRef.get();
                        if (snapshot.exists) {
                          DocumentReference machineStatusRef = machineRef
                              .collection('Status')
                              .doc('MachineStatus');
                          // Check machine status without storing the snapshot
                          await machineStatusRef.get();
                          if (isConnected) {
                            await machineStatusRef
                                .set({'MachineStatus': false});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Machine Disconnected."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            setState(() {
                              isConnected = false;
                            });
                          } else {
                            await machineStatusRef.set({'MachineStatus': true});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Machine Connected."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            setState(() {
                              isConnected = true;
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Machine ID does not exist."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Text(isConnected ? 'Disconnect' : 'Connect'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
