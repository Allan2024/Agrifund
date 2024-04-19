import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EligibilityChecker extends StatefulWidget {
  const EligibilityChecker({Key? key}) : super(key: key);

  @override
  _EligibilityCheckerState createState() => _EligibilityCheckerState();
}

class _EligibilityCheckerState extends State<EligibilityChecker> {
  TextEditingController schemeController = TextEditingController();
  String? selectedState;
  String? selectedPersonalIdentity;
  String? selectedOwnership;
  String? selectedGender;
  String? selectedAge;
  String? selectedOccupation;
  String? selectedCaste;
  Map<String, dynamic> eligibilityChecklist = {};
  bool eligibilityChecked = false;
  List<String> suggestedSchemeNames = [];

  List<String> states = [
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

  List<String> personalIdentityOptions = ['Adhaar', 'No'];

  List<String> ownershipOptions = ['Yes', 'No'];

  List<String> genderOptions = ['Male', 'Female'];

  List<String> ageOptions = ['Below 18', 'Above 18', 'Above 35'];

  List<String> occupationOptions = ['Farmer', 'Fisherman'];

  List<String> casteOptions = ['SC/ST', 'OBC', 'Open'];

  String eligibilityMessage = '';

  @override
  Widget build(BuildContext context) {
    print('Selected age in build: $selectedAge'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Eligibility Checker', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (BuildContext context) {
                    return TextFormField(
                      controller: schemeController,
                      onChanged: (value) async {
                        final response = await http.get(
                          Uri.parse(
                              'http://127.0.0.1:5000/get_scheme_names?query=$value'),
                        );

                        if (response.statusCode == 200) {
                          List<dynamic> schemes =
                              jsonDecode(response.body)['schemes'];
                          setState(() {
                            suggestedSchemeNames = schemes
                                .map((scheme) => scheme.toString())
                                .toList();
                          });
                        } else {
                          print(
                              'Failed to fetch scheme names: ${response.statusCode}');
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Scheme Name',
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  },
                ),
                if (suggestedSchemeNames.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: suggestedSchemeNames.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(
                                  suggestedSchemeNames[index],
                                  style:
                                      TextStyle(color: Colors.deepOrangeAccent),
                                ),
                                onTap: () {
                                  setState(() {
                                    schemeController.text =
                                        suggestedSchemeNames[index];
                                    suggestedSchemeNames.clear();
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedState,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedState = newValue;
                    });
                  },
                  items: states.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select State',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedOwnership,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOwnership = newValue;
                    });
                  },
                  items: ownershipOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Ownership',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedPersonalIdentity,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPersonalIdentity = newValue;
                    });
                  },
                  items: personalIdentityOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Personal Identity',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue;
                    });
                  },
                  items: genderOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Gender',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedAge,
                  onChanged: (String? newValue) {
                    print('Selected age: $newValue'); // Debug print
                    setState(() {
                      selectedAge = newValue;
                    });
                  },
                  items:
                      ageOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Age',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedOccupation,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOccupation = newValue;
                    });
                  },
                  items: occupationOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Occupation',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCaste,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCaste = newValue;
                    });
                  },
                  items: casteOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Caste',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Check if age and caste are selected
                    if (selectedAge == null ||
                        selectedCaste == null ||
                        selectedState == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content:
                                Text("Please select State, Age, and Caste."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    final response = await http.post(
                      Uri.parse('http://127.0.0.1:5000/check_eligibility'),
                      body: {
                        'scheme': schemeController.text,
                        'state': selectedState ?? '',
                        'personalIdentity': selectedPersonalIdentity ?? '',
                        'ownership': selectedOwnership ?? '',
                        'gender': selectedGender ?? '',
                        'age': selectedAge ?? '',
                        'occupation': selectedOccupation ?? '',
                        'caste': selectedCaste ?? '',
                      },
                    );

                    if (response.statusCode == 200) {
                      Map<String, dynamic> data = jsonDecode(response.body);
                      setState(() {
                        eligibilityChecklist = data['eligibility_checklist'];
                        eligibilityMessage = data['message'];
                        eligibilityChecked = true;
                      });
                      _checkEligibilityCriteria(context);
                    } else {
                      print(
                          'Failed to check eligibility: ${response.statusCode}');
                    }
                  },
                  child: Text(
                    'Check Eligibility',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                ),
                SizedBox(height: 20),
                if (eligibilityChecked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eligibility Checklist:',
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: eligibilityChecklist.length,
                        itemBuilder: (BuildContext context, int index) {
                          String key =
                              eligibilityChecklist.keys.elementAt(index);
                          dynamic value = eligibilityChecklist[key];
                          if (value is Map<String, dynamic>) {
                            return ListTile(
                              title: Text(
                                key,
                                style:
                                    TextStyle(color: Colors.deepOrangeAccent),
                              ),
                              subtitle: Text(
                                value['value'].toString(),
                                style:
                                    TextStyle(color: Colors.deepOrangeAccent),
                              ),
                              trailing: value['matched']
                                  ? Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : Icon(Icons.cancel, color: Colors.red),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Eligibility Message: $eligibilityMessage',
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkEligibilityCriteria(BuildContext context) {
    for (String key in eligibilityChecklist.keys) {
      dynamic value = eligibilityChecklist[key];
      if (value is Map<String, dynamic> && !value['matched']) {
        _showEligibilityAlert(context, key, value['value'].toString(),
            value['criteria'].toString());
      }
    }
  }

  void _showEligibilityAlert(BuildContext context, String criterion,
      String suggestedValue, String criteriaValue) {
    String requiredValue = '';

    switch (criterion) {
      case 'Personal Identity':
        requiredValue = 'Adhaar';
        break;
      case 'Ownership':
        requiredValue = 'Yes';
        break;
      case 'Occupation':
        requiredValue = 'Farmer';
        break;
      case 'Caste':
        requiredValue = 'SC/ST';
        break;
      default:
        requiredValue = '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eligibility Alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To be eligible for $criterion :'),
              SizedBox(height: 10),
              Text('Criterion: $criterion'),
              Text('Suggested Value: $suggestedValue'),
              Text('Required Value for Match: $requiredValue'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EligibilityChecker(),
  ));
}
