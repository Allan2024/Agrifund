import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  final String username;

  EditProfile({required this.username});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController casteController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController incomeController = TextEditingController();
  TextEditingController hasOwnershipController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  List<String> casteOptions = ['SC/ST', 'Open', 'OBC'];
  List<String> genderOptions = ['Male', 'Female'];
  List<String> ownershipOptions = ['Yes', 'No'];
  List<String> ageOptions = List.generate(191, (index) => (index + 10).toString());

  String? selectedCaste;
  String? selectedGender;
  String? selectedOwnership;
  String? selectedAge;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validateIncome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Income is required';
    }
    int? income = int.tryParse(value);
    if (income == null || income < 1000 || income > 1000000) {
      return 'Income must be between 1000 and 1000000';
    }
    return null;
  }

  void updateProfile(BuildContext context) async {
    String caste = selectedCaste ?? '';
    String gender = selectedGender ?? '';
    String income = incomeController.text;
    String hasOwnership = selectedOwnership ?? '';
    String age = selectedAge ?? '';

    String url = 'http://127.0.0.1:5000/update_profile';

    try {
      final response = await http.post(Uri.parse(url), body: {
        'username': widget.username,
        'caste': caste,
        'gender': gender,
        'income': income,
        'hasOwnership': hasOwnership,
        'age': age,
      });

      if (response.statusCode == 200) {
        print('Profile update successful');

        // Navigate back to ProfileView page and pass updated user data
        Navigator.pop(context, {
          'caste': caste,
          'gender': gender,
          'income': income,
          'hasOwnership': hasOwnership,
          'age': age,
        });
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)), // Text color adjustment (optional)
        centerTitle: true,
        backgroundColor: Colors.green, // Change to your desired color (e.g., orange, blue)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: PhysicalModel(
              elevation: 5.0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              shadowColor: Colors.black,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey, // Assign the GlobalKey to the Form widget
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<String>(
                        value: selectedCaste,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCaste = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Select Caste',
                              style: TextStyle(color: Colors.deepOrangeAccent),
                            ),
                          ),
                          ...casteOptions.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.deepOrangeAccent),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButton<String>(
                        value: selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Select Gender',
                              style: TextStyle(color: Colors.deepOrangeAccent),
                            ),
                          ),
                          ...genderOptions.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.deepOrangeAccent),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: incomeController,
                        keyboardType: TextInputType.number, // Allow only numeric input
                        decoration: InputDecoration(
                          labelText: 'Income (per year)',                          // Specify the label as "Income (per year)"
                          labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrangeAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrangeAccent),
                          ),
                        ),
                        validator: validateIncome,
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Ownership:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: ownershipOptions.map((option) {
                          return Row(
                            children: [
                              Radio<String>(
                                value: option,
                                groupValue: selectedOwnership,
                                onChanged: (value) {
                                  setState(() {
                                    selectedOwnership = value;
                                  });
                                },
                                activeColor: Colors.deepOrangeAccent,
                              ),
                              Text(
                                option,
                                style: TextStyle(color: Colors.deepOrangeAccent),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButton<String>(
                        value: selectedAge,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAge = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Select Age Group',
                              style: TextStyle(color: Colors.deepOrangeAccent),
                            ),
                          ),
                          ...ageOptions.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.deepOrangeAccent),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateProfile(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                        ),
                        child: Text(
                          'Update Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

