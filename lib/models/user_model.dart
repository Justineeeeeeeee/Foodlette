import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final database = FirebaseFirestore.instance;

// Create User
  create(dynamic email, dynamic password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      database.collection('users').doc(uid).set({
        'name': 'Set your name',
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> update(String name, String email, String birthday,
      String? newPassword, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.update({
      'name': name,
      'email': email,
      'birthday': birthday,
    });
    if (newPassword != null && newPassword.isNotEmpty) {
      await user.updatePassword(newPassword);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating Password."),
          duration: Duration(seconds: 2),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile updated successfully."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  read() {
    try {
      database.collection('users').doc().update({
        'name': 'Jane Doe',
        'email': 'consultajustine820',
      });
    } catch (e) {
      print(e.toString());
    }
  }

  delete() {
    try {
      database.collection('users').doc('AEH7yKyAPRGIhl19gWDJ').delete();
    } catch (e) {
      print(e.toString());
    }
  }

  updateOnOff({required bool machineStatus}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await database.collection('users').doc(user.uid).update({
          'machineStatus': machineStatus,
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
