import 'package:cowtrain/screens/HomeScreen.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:cowtrain/screens/componentscreen/ImageViewer.dart';
import 'package:flutter/material.dart';

class CowInfoScreen extends StatefulWidget {
  final Map<String, dynamic> cowData;

  const CowInfoScreen({required this.cowData, Key? key}) : super(key: key);

  @override
  State<CowInfoScreen> createState() => _CowInfoScreenState();
}

class _CowInfoScreenState extends State<CowInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final weightPredictions = widget.cowData['weight_predictions'] as List<dynamic>;

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



              if (weightPredictions.isEmpty)
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
                ...weightPredictions.map((prediction) {
                  return Padding(
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
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                if (prediction['description'] != null && prediction['description'].toString().isNotEmpty)
                                  _buildDetailDescription(Icons.description, "", prediction['description']),
                              ],
                            ),
                          ),
                          // Images
                          Padding(
                            padding: EdgeInsets.all(AppTheme.spacingM),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Side View",
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppTheme.spacingS),
                                      ImageViewer(imageUrl: prediction['cattle_side_url']),
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppTheme.spacingM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rear View",
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppTheme.spacingS),
                                      ImageViewer(imageUrl: prediction['cattle_rear_url']),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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


