import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
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

          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('currentTemp')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var temperatureData = [snapshot.data!.data()];
              var spots = temperatureData.map((data) {
                return FlSpot(data?['time']?.toDouble() ?? 0.0,
                    data?['temperature']?.toDouble() ?? 0.0);
              }).toList();

              var currentTemperature =
                  temperatureData.last?['temperature'] ?? 0.0;
              var highestTemperature = temperatureData
                  .map((data) => data?['temperature'] ?? 0.0)
                  .reduce((a, b) => a > b ? a : b);
              var lowestTemperature = temperatureData
                  .map((data) => data?['temperature'] ?? 0.0)
                  .reduce((a, b) => a < b ? a : b);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 5,
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Temperature Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Current Temperature: $currentTemperature°C',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Highest Temperature: $highestTemperature°C',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Lowest Temperature: $lowestTemperature°C',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child('currentTemp')
                          .onValue,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data!.snapshot.value == null) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var data = snapshot.data!.snapshot.value;
                        if (data is Map) {
                          var currentTemperature = data['currentTemp'] ?? 0.0;

                          return Text(
                            'Realtime Temperature: $currentTemperature°C',
                            style: TextStyle(fontSize: 16),
                          );
                        } else {
                          return Text(
                            'No valid data available',
                            style: TextStyle(fontSize: 16),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
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
