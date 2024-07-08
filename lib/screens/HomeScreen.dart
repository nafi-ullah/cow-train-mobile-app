import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final cloudinary = CloudinaryPublic('dhqvosimu', 'jhc18w5a', cache: false);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  final picker = ImagePicker();

  Future<void> _pickSideImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        sideImageFile = File(pickedFile.path);
      });
      _uploadImage(sideImageFile!, isSideImage: true);
    } else {
      print('No side image selected.');
    }
  }

  Future<void> _pickRearImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        rearImageFile = File(pickedFile.path);
      });
      _uploadImage(rearImageFile!, isSideImage: false);
    } else {
      print('No rear image selected.');
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

  Future<void> _submitImages() async {
    if (sideImageUrl != null && rearImageUrl != null) {
      final url = Uri.parse('http://ec2-65-2-33-18.ap-south-1.compute.amazonaws.com:8080/predict_weight');
      final body = jsonEncode({
        "gender": "M",
        "side_image_link": sideImageUrl,
        "rear_image_link": rearImageUrl,
      });

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
          });
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
      appBar: AppBar(
        title: Text("Cow Weight Predict"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _pickSideImage,
                child: Text("Pick Side Image"),
              ),
              SizedBox(height: 20),
              sideImageUrl != null
                  ? Image.network(sideImageUrl!)
                  : Text("Image not uploaded."),
              ElevatedButton(
                onPressed: _pickRearImage,
                child: Text("Pick Rear Image "),
              ),
          
              SizedBox(height: 20),
              rearImageUrl != null
                  ? Image.network(rearImageUrl!)
                  : Text("Image not uploaded."),
              if (_uploadingPercentage > 0.0)
                CircularProgressIndicator(value: _uploadingPercentage / 100),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitImages,
                child: Text("Submit"),
              ),
              SizedBox(height: 20),
              if (predictedWeight != null)
                Text(
                  'Predicted Weight: ${predictedWeight?.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
