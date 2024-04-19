import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile.dart';
import 'eligibility_checker.dart';
import 'eligibility.dart';

class ProfileView extends StatefulWidget {
  final String username;

  ProfileView({required this.username});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Future<Map<String, dynamic>> fetchUserData() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/get_user_data?username=${Uri.encodeComponent(widget.username)}'),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user data');
    }
  }

  void navigateToEditProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfile(username: widget.username)),
    );

    // If updated data is not null, update the UI
    if (updatedData != null) {
      setState(() {});
    }
  }
  int _selectedIndex = 0; // To track the currently selected bottom navigation bar item

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
        // No action required as this is the Profile page
          break;
        case 1:
          navigateToEditProfile();
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EligibilityChecker()),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EligibilityPage(username: widget.username)),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.green, // Adjust app bar color if needed
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserData(),
          builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              Map<String, dynamic> userData = snapshot.data ?? {};

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          subtitle: Text(
                            userData['name'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'State',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          subtitle: Text(
                            userData['state'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Occupation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          subtitle: Text(
                            userData['occupation'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Gender',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          subtitle: Text(
                            userData['gender'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Age',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          subtitle: Text(
                            userData['age'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Has Ownership',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          subtitle: Text(
                            userData['hasOwnership'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          subtitle: Text(
                            userData['income'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        /*ElevatedButton(
                          onPressed: () {
                            navigateToEditProfile();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
                          ),
                          child: Text('Edit Profile'),
                        ),*/
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
        backgroundColor: Colors.grey.shade200, // Adjust background color for better contrast
        bottomNavigationBar: SafeArea(
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Edit Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Eligibility Check',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified),
                label: 'Eligibility',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.red, // Light color for selected item
            unselectedItemColor: Colors.grey.shade600, // Light color for unselected items
            backgroundColor: Colors.green,
            elevation: 8.0, // Optional elevation
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
