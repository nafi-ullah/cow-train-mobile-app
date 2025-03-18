import 'package:cowtrain/constants.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/auth/loginscreen.dart';
import 'package:cowtrain/screens/componentscreen/AddCow.dart';
import 'package:cowtrain/screens/componentscreen/Cowinfo.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_services.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> cattleData = [];
  bool isLoading = true;
  bool hasError = false;
  int credit = 0;



  @override
  void initState() {
    super.initState();

    // Delay to ensure context is available
    Future.delayed(Duration.zero, () {
      // final user = Provider.of<UserProvider>(context, listen: false).user;
      // setState(() {
      //   credit = user.credit ?? 0;
      // });
      fetchUserData();
      fetchCattleData();
    });
  }

  void _logout(BuildContext context) {
    final authService = AuthServices();
    authService.logout(context);
  }

  Future<void> fetchUserData() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final url = Uri.parse('$uri/users');
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);

        // Find the current user by matching userId
        final currentUser = users.firstWhere((u) => u['userid'] == user.userid, orElse: () => null);

        if (currentUser != null) {
          // Update the user's credit in the provider
          final newCredit = currentUser['credit'];
          Provider.of<UserProvider>(context, listen: false).updateCredit(newCredit);
          setState(() {
            credit = newCredit;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
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
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchCattleData() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      String userid = user.userid;
      final url = Uri.parse('$uri/cattles/$userid/');
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


  Future<void> fetchall() async {
    try {
      fetchUserData();
      fetchCattleData();
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
    children: [
      Image.asset(
        'assets/images/ipinfralogo.png',
        height: 30, // Adjust size as needed
      ),
      SizedBox(width: 8), // Adds some spacing between the logo and text
      Text(
        'Dashboard',
        style: AppTheme.headingLarge,
      ),
    ],
  ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryBrown, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCattleFormScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            color: AppTheme.lightBrown,
            icon: Icon(Icons.more_vert, color: AppTheme.primaryBrown),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.textSecondary),
                    SizedBox(width: AppTheme.spacingM),
                    Text('Logout', style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchall,
        color: AppTheme.primaryBrown,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(

                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      child: Container(
                        padding: EdgeInsets.all(AppTheme.spacingL),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryBrown, AppTheme.lightBrown],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrown.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Cattle',
                              style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                            ),
                            SizedBox(height: AppTheme.spacingS),
                            Text(
                              '${cattleData.length}',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      child: Container(
                        padding: EdgeInsets.all(AppTheme.spacingL),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryBrown, AppTheme.lightBrown],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrown.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Credit',
                              style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                            ),
                            SizedBox(height: AppTheme.spacingS),
                            Text(
                              '${credit ?? 0}',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Text(
                  'Your Cattle',
                  style: AppTheme.headingMedium,
                ),
              ),
              if (isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXL),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                    ),
                  ),
                )
              else if (hasError)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXL),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: AppTheme.spacingM),
                        Text(
                          "No cattle data available",
                          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cattleData.length,
                  itemBuilder: (context, index) {
                    final cow = cattleData[index];
                    final weightPredictions = cow['weight_predictions'];
                    final hasWeightPredictions = weightPredictions.isNotEmpty;
                    final weightPrediction = hasWeightPredictions ? weightPredictions[0] : null;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                        vertical: AppTheme.spacingM,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CowInfoScreen(cowData: cow),
                            ),
                          );
                        },
                        child: Container(
                          decoration: AppTheme.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasWeightPredictions)
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    weightPrediction['cattle_side_url'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.all(AppTheme.spacingL),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          cow['name'],
                                          style: AppTheme.headingMedium,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppTheme.spacingM,
                                            vertical: AppTheme.spacingS,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.lightGreen.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'RM${cow['price']}',
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.darkGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppTheme.spacingM),
                                    Row(
                                      children: [
                                        _buildInfoChip(Icons.cake_outlined, "${cow['age']}y"),
                                        SizedBox(width: AppTheme.spacingS),
                                        _buildInfoChip(Icons.palette_outlined, cow['color']),
                                        if (hasWeightPredictions) ...[
                                          SizedBox(width: AppTheme.spacingM),
                                          _buildInfoChip(
                                            Icons.scale_outlined,
                                            "${weightPrediction['weight'].toStringAsFixed(0)}kg",
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (hasWeightPredictions) ...[
                                      SizedBox(height: AppTheme.spacingM),
                                      Text(
                                        "Last Updated: ${weightPrediction['date']}",
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
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
              SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightBrown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightBrown.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryBrown,
          ),
          SizedBox(width: AppTheme.spacingXS),
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryBrown,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
