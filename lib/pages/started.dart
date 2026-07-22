import 'package:flutter/material.dart';
import 'package:myapp/pages/dashboard/db1.dart';
import 'package:myapp/utils/colors.dart';

class StartedPage extends StatelessWidget {
  const StartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  // Background image
                  // Image.asset('assets/elips.png'),
                  Image.asset(
                    'assets/elips.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Align(
                    alignment: Alignment
                        .center, // Centering the content horizontally and vertically
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 22),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the children vertically within the column
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center the children horizontally within the column
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    offset: const Offset(3, 5),
                                  ),
                                ]),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(44.0),
                                  child: Image.asset(
                                    'assets/started.png',
                                  ),
                                ),
                               const SizedBox(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Welcome to FeelMate',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          'Catch the Vibes—Curated Media That Matches Every Twist and Turn of Your Mood Swings!',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),
                          GestureDetector(
                            onTap: (){
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Db1()),
                              );
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: kPrimaryColor),
                              width: double.infinity,
                              child: const Center(
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
