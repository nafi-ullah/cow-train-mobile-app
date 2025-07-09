import 'dart:io';
import 'package:cowtrain/constants.dart';
import 'package:cowtrain/features/sticker_adjustment_camera.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/ResultScreen.dart';
import 'package:cowtrain/constants/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _capturedFile;
  int? _imageWidth;
  int? _imageHeight;
  double? stickerSize;
  final picker = ImagePicker();
  String opencameralog = '';
  String rearimagelog = '';

  @override
  void initState() {
    super.initState();
    // Initialize cattleId and gender from widget.cowData
    cattleId = widget.cowData['cattle_id'];
    gender = widget.cowData['gender'] == "Male" ? "M" : "F";
  }

  void _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CameraCaptureScreen()),
    );
    setState(() {
      opencameralog = 'file type: ${result['file'].runtimeType} w ${result['width']} h ${ result['height']}';
    });

    if (result is Map && result['file'] is File ) {
      setState(() {
        sideImageFile =  result['file'];//File(result['file'].path);
        // _capturedFile = result['file'];
        _imageWidth = result['width'];
        _imageHeight = result['height'];
        stickerSize = result['sticker'];
      });
      _uploadImage(
         sideImageFile! ,
        isSideImage: true,
      );
    }
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
                  if (isSideImage == true){
                    // _pickImage(ImageSource.gallery, isSideImage: isSideImage);
                     _openCamera();
                  }else{
                    _pickImage(ImageSource.gallery, isSideImage: isSideImage);
                  }

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

        setState(() {
          rearimagelog = 'rear type: ${rearImageFile.runtimeType} ';
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
      // Read the original file as bytes
      final originalBytes = await image.readAsBytes();

      // Decode the image
      final decodedImage = img.decodeImage(originalBytes);
      if (decodedImage == null) {
        print('Failed to decode image');
        return;
      }
      img.Image processedImage = decodedImage;


      if (isSideImage) {
        processedImage = img.copyRotate(processedImage,  angle: -90);
      }else {
        // 📏 Resize to HD if too big
        final w = processedImage.width;
        final h = processedImage.height;

        const maxLandscapeW = 1920;
        const maxLandscapeH = 1440;
        const maxPortraitW = 1440;
        const maxPortraitH = 1920;

        // Determine if resizing is needed
        if (w > maxLandscapeW || h > maxPortraitH) {
          double aspectRatio = w / h;

          int targetW, targetH;

          if (aspectRatio >= 1) {
            // landscape
            targetW = maxLandscapeW;
            targetH = (maxLandscapeW / aspectRatio).round();

            if (targetH > maxLandscapeH) {
              targetH = maxLandscapeH;
              targetW = (maxLandscapeH * aspectRatio).round();
            }
          } else {
            // portrait
            targetH = maxPortraitH;
            targetW = (maxPortraitH * aspectRatio).round();

            if (targetW > maxPortraitW) {
              targetW = maxPortraitW;
              targetH = (maxPortraitW / aspectRatio).round();
            }
          }

          print('Resizing from ${w}x$h → ${targetW}x$targetH');

          processedImage = img.copyResize(
            processedImage,
            width: targetW,
            height: targetH,
            interpolation: img.Interpolation.average,
          );
        } else {
          print('No resizing needed. Original size: ${w}x$h');
        }
      }


      // Encode with 80% quality
      final compressedBytes = img.encodeJpg(processedImage, quality: 80);



      // Save compressed bytes to a temporary file
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      // Upload the compressed file
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          compressedFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
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
        _uploadingPercentage = 0.0;
      });
    } on CloudinaryException catch (e) {
      print(e.message);
      print(e.request);
    } catch (e) {
      print(e);
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
        "description": _descriptionController.text
      });
      print(url);
      print(body);

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        print(response.statusCode);
        print(jsonDecode(response.body));
        final responseData = jsonDecode(response.body);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (response.statusCode == 200) {
          // Handle successful submission

          final remainingCredits = responseData['remaining_credits'] as int;
          final predictedWeightValue = responseData['predicted_weight'];
          print(remainingCredits);
          print(predictedWeightValue);
          // Update UserProvider credit

          userProvider.updateCredit(remainingCredits);



          setState(() {
            predictedWeight = predictedWeightValue;
          });



          // Navigate only if `predictedWeight` is valid
          if (predictedWeight != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  rearImageUrl: rearImageUrl!,
                  sideImageUrl: sideImageUrl!,
                  predictedWeight: predictedWeight!,
                  gender: gender,
                  description: _descriptionController.text
                ),
              ),
            );
          }else{
            if(remainingCredits == 0){
              userProvider.updateCredit(0);
              _showErrorDialog(context, "Please mail to sales@ipinfra.com.my for get credit.");
            }

          }



        } else {
          // Handle other status codes

          _showErrorNoticeDialog(context, "Something went wrong, please try again later. Or check your internet connectivity. ");

          print('Failed to submit images: ${response.statusCode}');
        }

      } catch (e) {

        print('Error submitting images: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
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
                    // Text(
                    //     opencameralog,
                    //   style: AppTheme.bodyMedium,
                    //
                    // ),
                    // Text(
                    //   rearimagelog,
                    //   style: AppTheme.bodyMedium,
                    //
                    // ),
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
                width: double.infinity,
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
                            onPressed: () => _openCamera(), //_showImageSourceDialog(isSideImage: true),
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
                width: double.infinity,
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
              TextFormField(
                controller: _descriptionController,
                decoration: AppTheme.inputDecoration('Description').copyWith(
                  prefixIcon: Icon(Icons.description, color: AppTheme.primaryBrown),
                ),
                style: AppTheme.bodyLarge,
                maxLines: null, // Allows text to expand vertically
                minLines: 2, // Ensures at least 2 lines of space
                keyboardType: TextInputType.multiline, // Enables multiline input
                scrollPhysics: BouncingScrollPhysics(), // Adds a smooth scroll effect
              ),
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

// void _showErrorDialog(BuildContext context, String message) {
//   showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: Text("Problem"),
//       content: Text(message),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(ctx).pop(),
//           child: Text("OK"),
//         ),
//       ],
//     ),
//   );
// }


void _showErrorDialog(BuildContext context, String message) {
  final TextEditingController _creditController = TextEditingController();
  bool _isButtonEnabled = false;

  // Enable button only when the input field is not empty
  void _onTextChanged() {
    _isButtonEnabled = _creditController.text.isNotEmpty;
  }

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text("Low Credit Problem"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            SizedBox(height: 16),
            Text("You can also request credit from the authorities by submitting a request with the desired amount."),
            SizedBox(height: 16),
            TextField(
              controller: _creditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Credit Amount",
                border: OutlineInputBorder(),
                hintText: "Enter amount",
              ),
              onChanged: (value) {
                _onTextChanged();
              },
            ),
          ],
        ),
        actions: [
          // Button for "Send Request"
           TextButton(
            onPressed: () async {
              final user = Provider.of<UserProvider>(context, listen: false).user;
              final requestCredit = int.tryParse(_creditController.text);

              if (requestCredit == null || requestCredit <= 0) {
                Navigator.of(ctx).pop();
                _showErrorDialog(context, "Please enter a valid amount.");
                return;
              }

              try {
                final url = Uri.parse('http://13.233.130.128:8000/credit-request/');

                final client = http.Client();
                final response = await client.post(
                  url,
                  headers: {
                    'accept': 'application/json',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    "user_id": user.userid,
                    "request_credit": requestCredit,
                  }),
                );
                client.close();
                // print(user.userid);
                // print(requestCredit);
                // print('Response status: ${response.statusCode}');
                // print('Response body: ${response.body}');

                if (response.statusCode == 200) {
                  // Handle success (show success dialog or snackbar)
                  Navigator.of(ctx).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Credit request sent successfully")),
                  );
                } else {
                  Navigator.of(ctx).pop();
                  _showErrorDialog(context, "Failed to send credit request.");
                }
              } catch (e) {
                Navigator.of(ctx).pop();
                _showErrorDialog(context, "Error occurred: $e");
              }
            },
            child: Text("Send Request"),
          ),
              // Do not show button if input is empty

          // Close Button
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}


void _showErrorNoticeDialog(BuildContext context, String message) {


  // Enable button only when the input field is not empt
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text("Something Wrong Happened"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            SizedBox(height: 16),


          ],
        ),
        actions: [

          // Close Button
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}
