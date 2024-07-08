import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

final cloudinary = CloudinaryPublic('dhqvosimu', 'jhc18w5a', cache: false);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imageFile;
  final picker = ImagePicker();
  String? imageUrl;
  double _uploadingPercentage = 0.0;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      _uploadImage(imageFile!);
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage(File image) async {
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
        imageUrl = response.secureUrl;
        _uploadingPercentage = 0.0; // Reset the upload percentage after the upload is complete
      });
    } on CloudinaryException catch (e) {
      print(e.message);
      print(e.request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cow Train"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageFile != null
                ? Image.file(imageFile!)
                : Text("No image selected."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image from Gallery"),
            ),
            SizedBox(height: 20),
            if (_uploadingPercentage > 0.0)
              CircularProgressIndicator(value: _uploadingPercentage / 100),
            SizedBox(height: 20),
            imageUrl != null
                ? Image.network(imageUrl!)
                : Text("Image not uploaded."),
          ],
        ),
      ),
    );
  }
}
