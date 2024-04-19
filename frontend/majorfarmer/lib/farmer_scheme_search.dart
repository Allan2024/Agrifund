import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class FarmerSchemeSearch extends StatefulWidget {
  @override
  _FarmerSchemeSearchState createState() => _FarmerSchemeSearchState();
}

class _FarmerSchemeSearchState extends State<FarmerSchemeSearch> {
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  List<dynamic> recommendedSchemes = [];
  List<String> suggestedKeywords = [];
  List<String> selectedKeywords = []; // New list to store selected keywords
  String translatedHowWeWork =
      'Our site recommends schemes to farmers based on their profile. Farmers can check their eligibility for a particular scheme.';
  String translatedAboutUs =
      'We are a team dedicated to helping farmers find suitable schemes for their needs. Our mission is to empower farmers by providing access to valuable resources and support.';
  String translatedContactUs = 'Contact Us';
  bool aboutUsTranslated = false;
  bool contactUsTranslated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Scheme Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        getSuggestedKeywords(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter keywords...',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      performSearch();
                    },
                    child: Text('Search'),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Suggested Keywords:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: [
                    ...suggestedKeywords.map((keyword) {
                      return GestureDetector(
                        onTap: () {
                          addKeywordToSearch(keyword);
                        },
                        child: Chip(label: Text(keyword)),
                      );
                    }).toList(),
                    ...selectedKeywords.map((keyword) {
                      return GestureDetector(
                        onTap: () {
                          removeKeywordFromSearch(keyword);
                        },
                        child: Chip(
                          label: Text(keyword),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
            recommendedSchemes.isNotEmpty
                ? Container(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: recommendedSchemes.length,
                      itemBuilder: (context, index) {
                        return isValidScheme(recommendedSchemes[index])
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title:
                                        Text(recommendedSchemes[index]['name']),
                                    subtitle: Text(recommendedSchemes[index]
                                        ['description']),
                                    onTap: () {
                                      _openLink(
                                          recommendedSchemes[index]['link']);
                                    },
                                  ),
                                ),
                              )
                            : SizedBox();
                      },
                    ),
                  )
                : SizedBox(),
            _buildSection(
              title: 'How Our Site Works',
              content: translatedHowWeWork,
              imageUrl:
                  'https://images.unsplash.com/photo-1505471768190-275e2ad7b3f9?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGZhcm1lcnN8ZW58MHx8MHx8fDA%3D',
            ),
            _buildAboutUsSection(),
            _buildContactUsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required String content,
      required String imageUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                flex: 1,
                child: Image.network(
                  imageUrl,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutUsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Us',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                translatedAboutUs,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactUsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translatedContactUs,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  sendMessage();
                },
                child: Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void performSearch() async {
    String searchTerm = searchController.text;
    String url =
        'http://127.0.0.1:5000/get_recommendations?user_input=$searchTerm';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> schemes = data['recommended_schemes'];

        // Filter out any empty or incomplete schemes
        schemes = schemes.where((scheme) => isValidScheme(scheme)).toList();

        setState(() {
          recommendedSchemes = schemes;
        });
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }

    // Fetch suggested keywords based on the user input
    getSuggestedKeywords(searchTerm);
  }

  bool isValidScheme(Map<String, dynamic> scheme) {
    return scheme.containsKey('name') &&
        scheme.containsKey('description') &&
        scheme.containsKey('link');
  }

  void getSuggestedKeywords(String input) async {
    String url =
        'http://127.0.0.1:5000/get_suggested_keywords?input=$input';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          suggestedKeywords = List<String>.from(data['suggested_keywords']);
        });
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void sendMessage() {
    String name = nameController.text;
    String email = emailController.text;
    String message = messageController.text;
    // Implement sending message functionality, e.g., using email or a messaging service
  }

  void _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void addKeywordToSearch(String keyword) {
    // Add the selected keyword to the search input
    setState(() {
      searchController.text = '';
    });
    // Add the selected keyword to the list of selected keywords
    selectedKeywords.add(keyword);
    // Clear suggested keywords list
    setState(() {
      suggestedKeywords = [];
    });
  }

  void removeKeywordFromSearch(String keyword) {
    // Remove the selected keyword from the list of selected keywords
    selectedKeywords.remove(keyword);
    // Clear search input
    searchController.clear();
    // Re-populate search input with selected keywords
    selectedKeywords.forEach((keyword) {
      searchController.text += '$keyword ';
    });
    // Fetch suggested keywords based on the updated search input
    getSuggestedKeywords(searchController.text);
  }
}

void main() {
  runApp(MaterialApp(
    home: FarmerSchemeSearch(),
  ));
}
