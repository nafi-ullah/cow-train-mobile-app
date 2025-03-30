import 'package:cowtrain/screens/HomeScreen.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:cowtrain/screens/componentscreen/ImageViewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Added for API calls

class CowInfoScreen extends StatefulWidget {
  final Map<String, dynamic> cowData;

  const CowInfoScreen({required this.cowData, Key? key}) : super(key: key);

  @override
  State<CowInfoScreen> createState() => _CowInfoScreenState();
}

class _CowInfoScreenState extends State<CowInfoScreen> {
  late List<dynamic> _weightPredictions;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the weight predictions list
    _weightPredictions =
        List.from(widget.cowData['weight_predictions'] as List<dynamic>);
  }

  // Shows an AlertDialog for delete confirmation and calls delete API if confirmed.
  Future<bool> _confirmDelete(dynamic prediction) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Weight Prediction"),
          content: const Text(
              "Do you really want to delete this weight prediction?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Hit the delete API using the weight prediction id.
                final url =
                    "http://13.233.130.128:8000/weight-prediction/${prediction['id']}";
                final response =
                await http.delete(Uri.parse(url));
                if (response.statusCode == 200) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                        Text("Failed to delete the prediction.")),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.cowData['name'],
          style: AppTheme.headingLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_weightPredictions.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.scale_outlined,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(height: AppTheme.spacingM),
                        Text(
                          "No weight measurements yet",
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._weightPredictions.map((prediction) {
                  return Dismissible(
                    key: Key(prediction['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      // Ask user confirmation and perform delete API call
                      return await _confirmDelete(prediction);
                    },
                    onDismissed: (direction) {
                      // Remove the prediction from the list and re-render.
                      setState(() {
                        _weightPredictions.remove(prediction);
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: AppTheme.spacingM),
                      child: Container(
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weight and Date Header
                            Container(
                              padding: EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: AppTheme.lightBrown.withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${prediction['weight'].toStringAsFixed(2)} kg",
                                        style: AppTheme.headingMedium.copyWith(
                                          color: AppTheme.primaryBrown,
                                        ),
                                      ),
                                      Text(
                                        prediction['date'],
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppTheme.spacingS),
                                ],
                              ),
                            ),
                            // Images Section
                            Padding(
                              padding: EdgeInsets.all(AppTheme.spacingM),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Side View",
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: AppTheme.spacingS),
                                        ImageViewer(
                                            imageUrl:
                                            prediction['cattle_side_url']),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacingM),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rear View",
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: AppTheme.spacingS),
                                        ImageViewer(
                                            imageUrl:
                                            prediction['cattle_rear_url']),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
