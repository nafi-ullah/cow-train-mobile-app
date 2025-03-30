import 'dart:convert';
import 'package:cowtrain/screens/HomeScreen.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:cowtrain/screens/componentscreen/ImageViewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CowInfoScreen extends StatefulWidget {
  final Map<String, dynamic> cowData;

  const CowInfoScreen({required this.cowData, Key? key}) : super(key: key);

  @override
  State<CowInfoScreen> createState() => _CowInfoScreenState();
}

class _CowInfoScreenState extends State<CowInfoScreen> {
  Map<String, dynamic>? _cowInfo;
  List<dynamic> _weightPredictions = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Use the cattle_id from the passed cowData to fetch the detailed info.
    fetchCowInfo(widget.cowData['cattle_id']);
  }

  void _showEditDialog() {
    final formKey = GlobalKey<FormState>();
    Map<String, dynamic> updatedData = Map.from(_cowInfo!);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Cattle Info"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: updatedData['name'],
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (val) => updatedData['name'] = val,
                  ),
                  TextFormField(
                    initialValue: updatedData['age'].toString(),
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => updatedData['age'] = int.tryParse(val) ?? 0,
                  ),
                  TextFormField(
                    initialValue: updatedData['teeth_number'].toString(),
                    decoration: InputDecoration(labelText: 'Teeth Number'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => updatedData['teeth_number'] = int.tryParse(val) ?? 0,
                  ),
                  TextFormField(
                    initialValue: updatedData['foods'],
                    decoration: InputDecoration(labelText: 'Foods'),
                    onChanged: (val) => updatedData['foods'] = val,
                  ),
                  TextFormField(
                    initialValue: updatedData['color'],
                    decoration: InputDecoration(labelText: 'Color'),
                    onChanged: (val) => updatedData['color'] = val,
                  ),
                  TextFormField(
                    initialValue: updatedData['price'].toString(),
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => updatedData['price'] = double.tryParse(val) ?? 0,
                  ),
                  DropdownButtonFormField<String>(
                    value: updatedData['gender'] == 'Male' || updatedData['gender'] == 'Female'
                        ? updatedData['gender']
                        : null,
                    decoration: InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female']
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        updatedData['gender'] = val;
                      }
                    },
                  ),

                  TextFormField(
                    initialValue: updatedData['description'],
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (val) => updatedData['description'] = val,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                final url = "http://13.233.130.128:8000/cattle-update/${widget.cowData['cattle_id']}";
                final response = await http.put(
                  Uri.parse(url),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode(updatedData),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  fetchCowInfo(widget.cowData['cattle_id']); // Refresh UI with new data
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Cattle info updated")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Update failed")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _generateAndDownloadReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    final url = "http://13.233.130.128:8000/generate-cattle-report/${widget.cowData['cattle_id']}";
    try {
      final response = await http.get(Uri.parse(url));
      Navigator.pop(context); // remove loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pdfUrl = data['pdf_url'];

        if (pdfUrl != null) {
          // You can use url_launcher to open or download
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Report ready. Opening PDF...")),
          );
          // Launch URL (requires `url_launcher`)
          await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No PDF URL returned.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate report")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred while generating report")),
      );
    }
  }



  Future<void> fetchCowInfo(String cattleId) async {
    final url = "http://13.233.130.128:8000/cattle/$cattleId/info";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cowInfo = data;
          _weightPredictions = data['weight_predictions'] != null
              ? List.from(data['weight_predictions'] as List<dynamic>)
              : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<bool> _confirmDelete(dynamic prediction) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Weight Prediction"),
          content: const Text("Do you really want to delete this weight prediction?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final url = "http://13.233.130.128:8000/weight-prediction/${prediction['weight_predict_id']}";
                final response = await http.delete(Uri.parse(url));
                if (response.statusCode == 200) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete the prediction.")),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBrown),
        SizedBox(width: AppTheme.spacingM),
        Text(
          "$label: ",
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDetailDescription(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryBrown),
        SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyLarge,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor, // Set the default background color here
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }


    if (_hasError || _cowInfo == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: Text("Error loading cow information.")),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _cowInfo!['name'],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cattle Details", style: AppTheme.headingMedium),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: AppTheme.primaryBrown),
                                onPressed: () => _showEditDialog(),
                              ),
                              IconButton(
                                icon: Icon(Icons.download, color: AppTheme.primaryBrown),
                                onPressed: () => _generateAndDownloadReport(),
                              ),
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: AppTheme.spacingM),
                      _buildDetailRow(Icons.pets_outlined, "Name", _cowInfo!['name']),
                      SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        "Age",
                        "${_cowInfo!['age']} years - ${_cowInfo!['gender']}",
                      ),
                      SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(Icons.palette_outlined, "Color", _cowInfo!['color']),
                      SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(Icons.attach_money_outlined, "Price", "RM${_cowInfo!['price']}"),
                      SizedBox(height: AppTheme.spacingS),
                      if (_cowInfo!['description'] != null &&
                          _cowInfo!['description'].toString().isNotEmpty)
                        _buildDetailDescription(
                          Icons.description,
                          "",
                          _cowInfo!['description'],
                        ),
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
                        builder: (context) => HomeScreen(cowData: _cowInfo!),
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
              if (_weightPredictions.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXL),
                    child: Column(
                      children: [
                        Icon(Icons.scale_outlined, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: AppTheme.spacingM),
                        Text(
                          "No weight measurements yet",
                          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._weightPredictions.map((prediction) {
                  return Dismissible(
                    key: Key(prediction['weight_predict_id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await _confirmDelete(prediction);
                    },
                    onDismissed: (direction) {
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
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${prediction['weight'].toStringAsFixed(2)} kg",
                                        style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryBrown),
                                      ),
                                      Text(
                                        prediction['date'],
                                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Side View",
                                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
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
                                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
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
