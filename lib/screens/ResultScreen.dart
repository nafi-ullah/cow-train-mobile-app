import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  File? sideImageFile;
  File? rearImageFile;
  String? sideImageUrl;
  String? rearImageUrl;
  double _uploadingPercentage = 0.0;
  double? predictedWeight;

  final picker = ImagePicker();






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

              SizedBox(height: 20),
              sideImageUrl != null
                  ? Image.network(sideImageUrl!)
                  : Text("Image not uploaded."),


              SizedBox(height: 20),
              rearImageUrl != null
                  ? Image.network(rearImageUrl!)
                  : Text("Image not uploaded."),
              if (_uploadingPercentage > 0.0)
                CircularProgressIndicator(value: _uploadingPercentage / 100),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (()=>{}),
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
