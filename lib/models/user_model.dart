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

  update(name, setEmail, setbirthdate, BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await database.collection('users').doc(user.uid).update({
          'name': name,
          'email': setEmail,
          'birthday': setbirthdate,
        });

        // Show dialog if update is successful
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Update Successful'),
              content: Text('User information has been updated successfully.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(e.toString());
    }
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
}
