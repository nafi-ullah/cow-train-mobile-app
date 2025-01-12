import 'dart:io';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cowtrain/screens/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class ResultScreen extends StatefulWidget {
   ResultScreen({super.key, required this.rearImageUrl, required this.sideImageUrl, required this.predictedWeight, required this.gender});

  final String sideImageUrl;
  final String rearImageUrl;
  final double predictedWeight;
  final String gender;
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  double _uploadingPercentage = 0.0;
  double? predictedWeight;



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text("Cow Weight Predict"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

Row(
  children: [

    Column(
      children: [
        Image.network(widget.sideImageUrl,
          width: imageWidth,
          fit: BoxFit.cover,
        ),
        const Text("Side Image"),
      ],
    ),
    Column(
      children: [
        Image.network(widget.rearImageUrl,
          width: imageWidth,
          fit: BoxFit.cover,
        ),
        const Text("Rear Image"),
      ],
    )
  ],
),



              SizedBox(height: 20),
              Text(
                'Gender: ${widget.gender == 'M' ? 'Male' : 'Female'} ',
                style: TextStyle(fontSize: 16, ),
              ),
              SizedBox(height: 20),
                Text(
                  'Predicted Weight: ${widget.predictedWeight.toStringAsFixed(2)} Kg',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

              SizedBox(height: 50),
              ElevatedButton(
                onPressed: (()=>{
                Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                (route) => false, )
                }),
                child: Text("Re-Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
