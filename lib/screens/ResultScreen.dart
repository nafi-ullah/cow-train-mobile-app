import 'dart:io';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cowtrain/screens/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultScreen extends StatefulWidget {
  ResultScreen({
    super.key,
    required this.rearImageUrl,
    required this.sideImageUrl,
    required this.predictedWeight,
    required this.gender,
  });

  final String sideImageUrl;
  final String rearImageUrl;
  final double predictedWeight;
  final String gender;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Weight Prediction Result",
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
              // Result Card
              Container(
                decoration: AppTheme.cardDecoration,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBrown.withOpacity(0.1),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.scale_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          SizedBox(width: AppTheme.spacingL),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.predictedWeight.toStringAsFixed(2)} Kg",
                                style: AppTheme.headingLarge.copyWith(
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                              Text(
                                "Predicted Weight",
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Details
                    Padding(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      child: Row(
                        children: [
                          _buildDetailItem(
                            icon: Icons.person_outline,
                            label: "Gender",
                            value: widget.gender == 'M' ? 'Male' : 'Female',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingXL),

              // Photos Section
              Text(
                "Captured Photos",
                style: AppTheme.headingMedium,
              ),
              SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          decoration: AppTheme.cardDecoration,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  widget.sideImageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(AppTheme.spacingM),
                                child: Text(
                                  "Side View",
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          decoration: AppTheme.cardDecoration,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  widget.rearImageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(AppTheme.spacingM),
                                child: Text(
                                  "Rear View",
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingXL),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: AppTheme.secondaryButton,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.refresh),
                      label: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                        child: Text(
                          "Try Again",
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: AppTheme.primaryButton,
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => DashboardScreen()),
                          (route) => false,
                        );
                      },
                      icon: Icon(Icons.check_circle_outline),
                      label: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                        child: Text(
                          "Done",
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.lightBrown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBrown,
            size: 20,
          ),
        ),
        SizedBox(width: AppTheme.spacingM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
