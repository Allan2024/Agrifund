import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart' as launcher; // Alias to avoid conflict with the launch method

class EligibilityPage extends StatefulWidget {
  final String username;

  EligibilityPage({required this.username});

  @override
  _EligibilityPageState createState() => _EligibilityPageState();
}

class _EligibilityPageState extends State<EligibilityPage> {
  Future<List<dynamic>> fetchProfileRecommendations() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/get_profile_recommendations?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['recommended_schemes'];
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eligibility', style: TextStyle(color: Colors.white)), // Text color adjustment (optional)
        centerTitle: true,
        backgroundColor: Colors.green, // Change to your desired color (e.g., orange, blue)
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProfileRecommendations(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> recommendations = snapshot.data ?? [];

            return ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(recommendations[index]['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recommendations[index]['description']),
                      Text('Age: ${recommendations[index]['age']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _launchURL(recommendations[index]['link']); // Transfer URL to the details button
                    },
                    child: Text('Details'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
