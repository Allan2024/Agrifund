import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'profile_view.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _canRegister = false;

  String selectedState = 'Select State';
  String selectedOccupation = '';

  List<String> states = [
    'Select State',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Lakshadweep',
    'Delhi',
    'Puducherry',
  ];

  List<String> occupations = ['Farmer', 'Fisherman'];

  void registerProfile(BuildContext context) async {
    String name = nameController.text;
    String password = passwordController.text;

    if (selectedState == 'Select State' || selectedOccupation.isEmpty) {
      print('Please select valid values for State and Occupation');
      return;
    }

    String url = 'http://127.0.0.1:5000/register_profile';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name': name,
          'state': selectedState,
          'occupation': selectedOccupation,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        print('Registration successful');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileView(username: name),
          ),
        );
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _updateCanRegister() {
    // Update _canRegister based on input validation logic
    _canRegister = nameController.text.isNotEmpty &&
        selectedState != 'Select State' &&
        selectedOccupation.isNotEmpty &&
        passwordController.text.length >= 8; // Minimum password length validation

    setState(() {}); // Trigger rebuild to update button color and text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Registration', style: TextStyle(color: Colors.white)), // Text color adjustment (optional)
        centerTitle: true,
        backgroundColor: Colors.green, // Change to your desired color (e.g., orange, blue)
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Email/Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      onChanged: (text) => _updateCanRegister(), // Call _updateCanRegister on name change
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: selectedState,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedState = newValue;
                            _updateCanRegister(); // Call _updateCanRegister on state selection
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      items: states.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Occupation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: occupations.map((String occupation) {
                        return Row(
                          children: [
                            Radio<String>(
                              value: occupation,
                              groupValue: selectedOccupation,
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    selectedOccupation = value;
                                  });
                                }
                              },
                            ),
                            Text(
                              occupation,
                              style: TextStyle(
                                color: selectedOccupation == occupation ? Colors.blue : Colors.black,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      obscureText: true,
                      onChanged: (text) => _updateCanRegister(),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _canRegister ? () => registerProfile(context) : null,
                      child: _canRegister
                          ? Text('Register') // Text for enabled state
                          : Text('Fill all fields'), // Text for disabled state
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canRegister ? Colors.blue : Colors.grey, // Button color based on state
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,  // Restrict width for better placement
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Login',
                            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                          Icon(
                            Icons.arrow_right_alt,
                            color: Colors.blue,
                            size: 16.0,
                          ),
                        ],
                      ),
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
