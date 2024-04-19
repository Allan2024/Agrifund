import 'package:flutter/material.dart';
import 'farmer_scheme_search.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'profile_view.dart';
import 'eligibility.dart';
import 'profile_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/profile': (context) => ProfilePage(),
        '/login': (context) => LoginPage(),
        '/profile_view': (context) => ProfileView(username: ''),
        '/eligibility': (context) => EligibilityPage(username: ''),
       // // Pass a default value for username
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText( // Use RichText for styling flexibility
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Farmer',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.orange), // Highlight "Farmer"
              ),
              TextSpan(
                text: ' Scheme Recommendations',
                style: TextStyle(fontSize: 22.0, color: Colors.white),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green, // Set the background color
        actions: [
          LoginButton(),
        ],
      ),
      body: FarmerSchemeSearch(),
    );
  }
}
