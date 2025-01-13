import 'package:cowtrain/constants.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/auth/loginscreen.dart';
import 'package:cowtrain/screens/componentscreen/AddCow.dart';
import 'package:cowtrain/screens/componentscreen/Cowinfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> cattleData = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    // Fetch the data after the widget is built
    Future.microtask(() => fetchCattleData());
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  Future<void> fetchCattleData() async {
    try {
      // Access the provider using listen: false
      final user = Provider.of<UserProvider>(context, listen: false).user;
      String userid = user.userid;
      final url = Uri.parse('$uri/cattles/$userid/');
      print("In dashboard hitting to ====>");
      print(url);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          cattleData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Cover Image
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/landingscreen.png"),
                      //fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Cow Information Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : hasError
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No data available",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cattleData.length,
                    itemBuilder: (context, index) {
                      final cow = cattleData[index];
                      final weightPredictions = cow['weight_predictions'];
                      final hasWeightPredictions = weightPredictions.isNotEmpty;
                      final weightPrediction = hasWeightPredictions ? weightPredictions[0] : null;

                      return GestureDetector(
                        onTap: () {
                          // Navigate to CowInfoScreen with cow data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CowInfoScreen(cowData: cow),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            child: Column(
                              children: [
                                // Conditionally show ClipRRect if weight_predictions is not empty
                                if (hasWeightPredictions)
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.vertical(top: Radius.circular(20)),
                                    child: Image.network(
                                      weightPrediction['cattle_side_url'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cow['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text("Age: ${cow['age']} years"),
                                      Text("Color: ${cow['color']}"),
                                      Text("Price: \$${cow['price']}"),
                                      // Conditionally show weight and date if weight_predictions is not empty
                                      if (hasWeightPredictions) ...[
                                        Text(
                                            "Weight: ${weightPrediction['weight'].toStringAsFixed(2)} kg"),
                                        Text("Feeding Date: ${weightPrediction['date']}"),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                ),
              ],
            ),
          ),
          Positioned(
          top: 20, // Adjust top position as needed
          right: 20, // Adjust right position as needed
          child: PopupMenuButton<String>(
          icon: Icon(Icons.menu, size: 30, color: Colors.white), // Three-bar icon
          onSelected: (value) {
          if (value == 'logout') {
          _logout(context);
          }
          },
          itemBuilder: (context) => [
          PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
          ),
          ],
          ),
          )
        ],

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCattleFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
