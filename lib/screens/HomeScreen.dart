import 'dart:io';
import 'package:cowtrain/screens/ResultScreen.dart';
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
  bool isLoading=false;
  String? _selectedGender;

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

  Future<void> _submitImages(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    if (sideImageUrl != null && rearImageUrl != null) {
      final url = Uri.parse('http://ec2-65-2-33-18.ap-south-1.compute.amazonaws.com:8080/predict_weight');
      final body = jsonEncode({
        "gender": _selectedGender,
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
                      gender: _selectedGender!,
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
      appBar: AppBar(
        title: Text("Cow Weight Predict"),
        backgroundColor: Colors.brown.shade900,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                // The value of the currently selected item
                value: _selectedGender,
                // Hint text shown when no item is selected
                hint: Text('Select Gender'),
                // The items to display in the dropdown menu
                items: [
                  DropdownMenuItem(
                    value: 'M',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'F',
                    child: Text('Female'),
                  ),
                ],
                // This callback is called when the user selects an item
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickSideImage,
                child: Text("Pick Side Image"),
              ),
              SizedBox(height: 20),
              sideImageUrl != null
                  ? Image.network(sideImageUrl!)
                  : Text("Image not uploaded."),
              SizedBox(height: 20),
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
              if (isLoading == false)
              ElevatedButton(
                onPressed: (()=>{
                  _submitImages(context)
                }),
                child: Text("Submit"),
              ),
              if (isLoading == true)
                CircularProgressIndicator(),

              SizedBox(height: 20),
              // if (predictedWeight != null)
              //   Text(
              //     'Predicted Weight: ${predictedWeight?.toStringAsFixed(2)}',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
