import 'dart:io';
import 'package:cowtrain/constants.dart';
import 'package:cowtrain/screens/ResultScreen.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final cloudinary = CloudinaryPublic('dhqvosimu', 'jhc18w5a', cache: false);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.cowData});
  final Map<String, dynamic> cowData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? sideImageFile;
  File? rearImageFile;
  String? sideImageUrl;
  String? rearImageUrl;
  double _uploadingPercentage = 0.0;
  double? predictedWeight;
  bool isLoading=false;
  String? _selectedGender;
  late String cattleId;
  late String gender;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize cattleId and gender from widget.cowData
    cattleId = widget.cowData['cattle_id'];
    gender = widget.cowData['gender'] == "male" ? "M" : "F";
  }

  Future<void> _showImageSourceDialog({required bool isSideImage}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Select Image Source',
            style: AppTheme.headingMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: AppTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isSideImage: isSideImage);
                },
              ),
              Divider(
                color: AppTheme.lightBrown.withOpacity(0.3),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isSideImage: isSideImage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, {required bool isSideImage}) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (isSideImage) {
            sideImageFile = File(pickedFile.path);
          } else {
            rearImageFile = File(pickedFile.path);
          }
        });
        _uploadImage(
          isSideImage ? sideImageFile! : rearImageFile!,
          isSideImage: isSideImage,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error picking image. Please try again.',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage(File image, {required bool isSideImage}) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
        onProgress: (count, total) {
          setState(() {
            _uploadingPercentage = (count / total) * 100;
          });
        },
      );

      setState(() {
        if (isSideImage) {
          sideImageUrl = response.secureUrl;
        } else {
          rearImageUrl = response.secureUrl;
        }
        _uploadingPercentage = 0.0; // Reset the upload percentage after the upload is complete
      });
    } on CloudinaryException catch (e) {
      print(e.message);
      print(e.request);
    }
  }

  Future<void> _submitImages(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    if (sideImageUrl != null && rearImageUrl != null) {
      final url = Uri.parse('$uri/predict_weight');
      final body = jsonEncode({
        "cattle_id": cattleId,
        "gender": gender,
        "cattle_side_url": sideImageUrl,
        "cattle_rear_url": rearImageUrl,
      });
      print(url);
      print(body);

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          // Handle successful submission
          print('Images submitted successfully');
          final parsedResponse = jsonDecode(response.body);
          setState(() {
            predictedWeight = parsedResponse['predicted_weight'];
            isLoading = false;
          });

          if (predictedWeight != null  ) {
            print(predictedWeight);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  ResultScreen(rearImageUrl: rearImageUrl!,
                    sideImageUrl: sideImageUrl!,
                    predictedWeight: predictedWeight!,
                    gender: gender,
                  )),
              // Set to false to remove all previous pages
            );
          }
        } else {
          // Handle other status codes
          print('Failed to submit images: ${response.statusCode}');
        }
      } catch (e) {
        print('Error submitting images: $e');
      }
    } else {
      print('Please select both side and rear images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Weight Prediction",
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
              // Instructions
              Container(
                padding: EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.lightBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightBrown.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Take Photos",
                      style: AppTheme.headingMedium,
                    ),
                    SizedBox(height: AppTheme.spacingS),
                    Text(
                      "Please take clear photos from both side and rear view for accurate weight prediction.",
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingXL),

              // Side Image Section
              Text(
                "Side View Photo",
                style: AppTheme.headingMedium,
              ),
              SizedBox(height: AppTheme.spacingM),
              Container(
                decoration: AppTheme.cardDecoration,
                child: Column(
                  children: [
                    if (sideImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          sideImageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      child: Column(
                        children: [
                          if (sideImageUrl == null)
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                          SizedBox(height: AppTheme.spacingM),
                          ElevatedButton.icon(
                            style: AppTheme.primaryButton,
                            onPressed: () => _showImageSourceDialog(isSideImage: true),
                            icon: Icon(Icons.add_a_photo_outlined),
                            label: Text(
                              sideImageUrl == null ? "Take Side Photo" : "Change Photo",
                              style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingL),

              // Rear Image Section
              Text(
                "Rear View Photo",
                style: AppTheme.headingMedium,
              ),
              SizedBox(height: AppTheme.spacingM),
              Container(
                decoration: AppTheme.cardDecoration,
                child: Column(
                  children: [
                    if (rearImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          rearImageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      child: Column(
                        children: [
                          if (rearImageUrl == null)
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                          SizedBox(height: AppTheme.spacingM),
                          ElevatedButton.icon(
                            style: AppTheme.primaryButton,
                            onPressed: () => _showImageSourceDialog(isSideImage: false),
                            icon: Icon(Icons.add_a_photo_outlined),
                            label: Text(
                              rearImageUrl == null ? "Take Rear Photo" : "Change Photo",
                              style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_uploadingPercentage > 0.0) ...[
                SizedBox(height: AppTheme.spacingL),
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        value: _uploadingPercentage / 100,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                      ),
                      SizedBox(height: AppTheme.spacingS),
                      Text(
                        "Uploading... ${_uploadingPercentage.toStringAsFixed(0)}%",
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppTheme.spacingXL),

              // Submit Button
              if (!isLoading && sideImageUrl != null && rearImageUrl != null)
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: AppTheme.primaryButton,
                    onPressed: () => _submitImages(context),
                    icon: Icon(Icons.check_circle_outline),
                    label: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      child: Text(
                        "Predict Weight",
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              if (isLoading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        "Predicting weight...",
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
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
  }
}
