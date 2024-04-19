import 'package:flutter/material.dart';
import 'profile_page.dart';

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container( // Wrap TextButton in a Container
      decoration: BoxDecoration(
        color: Colors.blue, // Adjust color as needed
        borderRadius: BorderRadius.circular(5.0), // Set border radius for rectangle
      ),
      child: TextButton(
        onPressed: () {
          // Handle button press (e.g., navigate to login/register page)
          Navigator.pushNamed(context, '/login'); // Assuming login page route
        },
        child: Text(
          'Login /Register',
          style: TextStyle(fontSize: 18.0, color: Colors.white), // Increase font size and adjust color
        ),
      ),
    );
  }
}