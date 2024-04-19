import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'profile_view.dart';
import 'profile_page.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = true; // Flag to track password visibility
  String? _usernameError; // State variable to store error message

  InputBorder _getErrorBorder(String? errorText) {
    if (errorText == null) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      );
    } else {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      );
    }
  }

  String? _validateUsername(String username) {
    if (username.length < 6) {
      return 'Username must be at least 6 characters long.';
    }
    // Add more validation rules as needed
    return null; // No errors
  }

  void loginUser(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;

    String url = 'http://127.0.0.1:5000/custom_login';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'name': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success', style: TextStyle(color: Colors.black)),
              content: Text('Login successful!',
                  style: TextStyle(color: Colors.black)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileView(username: username),
                      ),
                    );
                  },
                  child: Text('OK', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error', style: TextStyle(color: Colors.black)),
              content: Text('Invalid username or password. Please try again.',
                  style: TextStyle(color: Colors.black)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login',
            style: TextStyle(
                color: Colors.white)), // Text color adjustment (optional)
        centerTitle: true,
        backgroundColor:
            Colors.green, // Change to your desired color (e.g., orange, blue)
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: Colors.white,
            child: SizedBox(
              width: 300.0,
              height: 300.0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 300.0,
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: _getErrorBorder(
                              _usernameError), // Set border based on error state
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.black),
                          errorText: _usernameError?.isNotEmpty ?? false
                              ? _usernameError
                              : null, // Display error only if not empty
                          suffixIcon: usernameController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () => setState(() {
                                    usernameController.text = ''; // Clear text
                                    _usernameError =
                                        null; // Reset error state on clear
                                  }),
                                )
                              : null, // Add clear icon if text entered
                        ),
                        onChanged: (text) {
                          // Update error state and trigger rebuild
                          setState(() {
                            _usernameError = _validateUsername(text);
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.black),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Use appropriate icon based on visibility state
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _showPassword,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        loginUser(context);
                      },
                      child:
                          Text('Login', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Emphasize on press
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      },
                      icon: Icon(Icons.person_add,
                          size: 16.0, color: Colors.blue), // Add icon and color
                      label: Text('Create a new account',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
