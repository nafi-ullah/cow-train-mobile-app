import 'package:cowtrain/screens/HomeScreen.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:flutter/material.dart';

class CowInfoScreen extends StatelessWidget {
  final Map<String, dynamic> cowData;

  const CowInfoScreen({required this.cowData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weightPredictions = cowData['weight_predictions'] as List<dynamic>;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          cowData['name'],
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
              // Cow Details Card
              Container(
                decoration: AppTheme.cardDecoration,
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cattle Details",
                        style: AppTheme.headingMedium,
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      _buildDetailRow(Icons.pets_outlined, "Name", cowData['name']),
                      SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(Icons.calendar_today_outlined, "Age", "${cowData['age']} years"),
                      SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(Icons.palette_outlined, "Color", cowData['color']),
                      SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(Icons.attach_money_outlined, "Price", "\$${cowData['price']}"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacingL),

              // Add Weight Button
              Center(
                child: ElevatedButton.icon(
                  style: AppTheme.primaryButton,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(cowData: cowData),
                      ),
                    );
                  },
                  icon: Icon(Icons.add_photo_alternate_outlined),
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                    child: Text(
                      "Add New Weight Measurement",
                      style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacingXL),

              // Weight Predictions Section
              Text(
                "Weight History",
                style: AppTheme.headingMedium,
              ),
              SizedBox(height: AppTheme.spacingM),

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
                            child: Row(
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
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          prediction['cattle_side_url'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
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
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          prediction['cattle_rear_url'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
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
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryBrown,
        ),
        SizedBox(width: AppTheme.spacingM),
        Text(
          "$label: ",
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
