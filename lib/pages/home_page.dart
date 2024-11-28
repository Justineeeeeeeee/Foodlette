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
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.4;
    final containerHeight = containerWidth * 0.3;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // First Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            
                            margin: const EdgeInsets.all(5.0),
                            width: containerWidth,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD8B144),
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: const Offset(
                                    .5,
                                    .5,
                                  ),
                                  blurRadius: 20.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 20.0),
                                  child: Row(
                                  children: [
                                    Icon(
                                    Icons.account_circle, 
                                    size: 40,

                                    ),  // User Icon
                                  SizedBox(width: 8),  // Adds space between the icon and text
                                Text(
                                "USERNAME",  style: TextStyle(
                                  fontFamily: 'RobotoSlab',
                                ),)
                              ,], 
                               
                               ),
                                ),
                               ],
                            ),
                          ),
                          Container(
                            
                            margin: const EdgeInsets.all(5.0),
                            width: containerWidth,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD8B144),
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: const Offset(
                                    .5,
                                    .5,
                                  ),
                                  blurRadius: 20.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 20.0),
                                  child: Row(
                                  children: [
                                    Icon(
                                    Icons.logout, 
                                    color: Color(0xFFC00F0C),
                                    size: 40,

                                    ),  // User Icon
                                  SizedBox(width: 8),  // Adds space between the icon and text
                                Text(
                                "SIGN OUT",  style: TextStyle(
                                  fontFamily: 'RobotoSlab',
                                  color: Color(0xFFC00F0C)
                                ),)
                              ,], 
                               
                               ),
                                ),
                               ],
                            ),
                          ),
                          Container(
                            
                            margin: const EdgeInsets.all(5.0),
                            width: containerWidth,
                            height: containerHeight * 2 ,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD8B144),
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: const Offset(
                                    .5,
                                    .5,
                                  ),
                                  blurRadius: 20.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 5.0,top:5.0),
                                  child: Column(
                                  children: [
                                  SizedBox(width: 8),  // Adds space between the icon and text
                                Text(
                                "HUMIDITY",  style: TextStyle(
                                  fontFamily: 'RobotoSlab',
                                  color: Colors.black,
                                ),
                                ),
                                
                              ], 
                              
                               
                               ),
                               
                                ),
                                
                               ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                         
                        children: [
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            width: screenWidth * 0.55,
                            height: screenWidth * 0.20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD8B144),
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: const Offset(
                                    2.0,
                                    2.0,
                                  ),
                                  blurRadius: 20.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 40.0),
                                  
                               child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                               Icon(
                                    Icons.notifications, 
                                    size: 40,
                                    ),  // User Icon
                                  SizedBox(width: 8),  
                                Text("NOTIFICATIONS", style: TextStyle(
                                  fontFamily: 'RobotoSlab',
                                ),)
                         ], ),),],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            width: screenWidth * 0.55,
                            height: screenWidth * 0.29,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD8B144),
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: const Offset(
                                    2.0,
                                    2.0,
                                  ),
                                  blurRadius: 20.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [Text("Actual Photo")],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Second Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: screenWidth * 0.31,
                        height: screenWidth * 0.31,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFD8B144),
                            width: 3.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: const Offset(
                                2.0,
                                2.0,
                              ),
                              blurRadius: 20.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [Text("Sign Out")],
                        ),
                      ),
                    ),
                  ),
                ),
                // Third Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: screenWidth * 0.31,
                        height: screenWidth * 0.31, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFD8B144),
                            width: 3.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: const Offset(
                                2.0,
                                2.0,
                              ),
                              blurRadius: 20.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [Text("Sign Out")],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom Full-Width Container
                Container(
                  margin: const EdgeInsets.all(10.0),
                  width: screenWidth * 0.95,
                  height: screenWidth * 0.31,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFD8B144),
                      width: 3.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(
                          2.0,
                          2.0,
                        ),
                        blurRadius: 20.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        width: containerWidth,
                        height: containerHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFD8B144),
                            width: 3.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: const Offset(
                                2.0,
                                2.0,
                              ),
                              blurRadius: 20.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [Text("Start")],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        width: containerWidth,
                        height: containerHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFD8B144),
                            width: 3.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: const Offset(
                                2.0,
                                2.0,
                              ),
                              blurRadius: 20.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [Text("Stop")],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
