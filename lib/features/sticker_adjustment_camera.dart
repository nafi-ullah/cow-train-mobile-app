import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
class CameraCaptureScreen extends StatefulWidget {
  @override
  _CameraCaptureScreenState createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  bool _isCapturing = false;
  double pitching = 0.0;
  double? rolling;
  double? cameraAngle;
  double cameraHeight = 135.00; // 1.35 average height of chest
  double stickerSize = 0.00;
  bool _isStickerAvailable = false;
  double logicalStickerSize = 0.00;
  double finlaDistance = 0.00;

  double pitchingPosGl = 0.00;
  double originalAngleGl = 0.00;
  double pitchRadiansGl = 0.00;

  double distanceGl =0.00;
  double distanceInchGl = 0.00;
  double scaledSizeGl = 0.00;


  double baseStickerSizePxGl = 0.00;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    startListeningToSensors();
  }


  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
    final backCam = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      backCam,
      ResolutionPreset.high, // ekhane 1920 h, 1080 h krsi, bt calculatuon sob agyr 3072 r 4096 er moto
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _initializeControllerFuture = _controller.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<ui.Image> _loadSticker() async {
    final byteData = await rootBundle.load('assets/images/sticker.png');
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void startListeningToSensors() {


    accelerometerEventStream().listen((AccelerometerEvent event) {


        double x = event.x;
        double y = event.y;
        double z = event.z;
        double roll = atan2(y, z) * (180 / pi);
        double pitch = atan2(-x, sqrt(y * y + z * z)) * (180 / pi);

        setState(() {
          pitching = pitch;
          rolling = roll;

        });

        print('Pitch: ${pitch.toStringAsFixed(2)}°, Roll: ${roll.toStringAsFixed(2)}°');


    });
  }

  Future<Uint8List> _mergeImages(ui.Image background, ui.Image foreground, double stickerSize ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    double scaledStickerSize = stickerSize;
    if (background.width.toDouble() != 3072.0 ||  background.height.toDouble() != 4096.0) {
      double k = background.width.toDouble() / 3072.0;
      scaledStickerSize = stickerSize * k;
    }

    final size = Size(
      background.width.toDouble(),
      background.height.toDouble(),
    );

    print('Background size is ${background.width} x ${background.height}');
    // Draw camera image
    canvas.drawImage(background, Offset.zero, Paint());

    // Draw sticker at center
    // final double scale = 2;
    final double newWidth = scaledStickerSize;
    final double newHeight = scaledStickerSize;
    final double centerX = (size.width - newWidth) / 2;
    final double centerY = (size.height - newHeight) / 2;

    // Define source and destination rectangles
    final src = Rect.fromLTWH(0, 0, foreground.width.toDouble(), foreground.height.toDouble());
    final dst = Rect.fromLTWH(centerX, centerY, newWidth, newHeight);
    canvas.drawImageRect(foreground, src, dst, Paint());

    final picture = recorder.endRecording();
    final img = await picture.toImage(
        background.width, background.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      scaledSizeGl = scaledStickerSize;
    });
    return byteData!.buffer.asUint8List();
  }

  //-----------###########--------get sticker----#############------------------

  Future<void> _getStricker() async {
    double pitchingPos = pitching.abs();
    double originalAngle = 90 - pitchingPos;
    double pitchRadians = originalAngle * (pi / 180); // here pitching is in degree

    double distance = 135.00 / tan(pitchRadians);
    double distanceInch = distance * 0.393701;


    double baseStickerSizePx = 31500 / distance;

    final cameraWidth = _controller.value.previewSize?.width ?? 0.0;
    final cameraHeightVal = _controller.value.previewSize?.height ?? 0.0;

    double scaledStickerSize = baseStickerSizePx;
    if (cameraWidth != 3072.0 || cameraHeightVal != 4096.0) {
      double k = cameraWidth / 3072.0;
      scaledStickerSize = baseStickerSizePx * k;
    }

    double logicalStickerSizeCal = scaledStickerSize / MediaQuery.of(context).devicePixelRatio;

    print('CamWidth ${cameraWidth} x ${cameraHeightVal} .. Distance ${distanceInch} Sticker Size ${scaledStickerSize}  logicalSize ${logicalStickerSizeCal}');


      setState(() {
        cameraAngle = pitching ;
        _isStickerAvailable = true;
        stickerSize =  baseStickerSizePx;
        logicalStickerSize = logicalStickerSizeCal;
        finlaDistance = distanceInch;
        pitchingPosGl = pitchingPos;
        originalAngleGl = originalAngle;
        pitchRadiansGl = pitchRadians;
        distanceGl = distance;
        baseStickerSizePxGl = baseStickerSizePx;
      });

  }

  Future<void> _takePicture() async {
    if (_isCapturing) return;
    if (!_controller.value.isInitialized) return;

    setState(() => _isCapturing = true);
try {
  final file = await _controller.takePicture();
  final bgBytes = await File(file.path).readAsBytes();
  final bgCodec = await ui.instantiateImageCodec(bgBytes);
  final bgFrame = await bgCodec.getNextFrame();
  final bgImage = bgFrame.image;

  final sticker = await _loadSticker();
  final mergedBytes = await _mergeImages(bgImage, sticker, stickerSize);

  // Save merged image temporarily
  final tempDir = Directory.systemTemp;
  final mergedFile = File('${tempDir.path}/merged_${DateTime
      .now()
      .millisecondsSinceEpoch}.png');
  await mergedFile.writeAsBytes(mergedBytes);

  Navigator.pop(context, {
    'file':  mergedFile,
    'width': bgImage.width,
    'height': bgImage.height,
    'sticker': scaledSizeGl
  });
}finally{
  setState(() => _isCapturing = false);
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            color: Colors.black,
            child: Stack(

              children: [
                Center(child: CameraPreview(_controller)),




                // Sticker overlay in center
                Positioned(
                  left: _isStickerAvailable ==  true ? MediaQuery.of(context).size.width * 0.5 - 30 : 0.0, // MediaQuery.of(context).size.width * 0.5 - 30,
                  top: _isStickerAvailable == true ? MediaQuery.of(context).size.height / 2 - 30 :  0.0, // MediaQuery.of(context).size.height / 2 - 30,
                  child: Container(
                    child: _isStickerAvailable == true ?  Image.asset(
                      'assets/images/sticker.png',
                      width: logicalStickerSize,
                      height: logicalStickerSize,
                    ): Image.asset(
                      'assets/images/footfocus.png',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )  ,
                  ),
                ),




                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _isCapturing
                        ? const CircularProgressIndicator()
                        : FloatingActionButton(
                      onPressed: _isStickerAvailable == true ? _takePicture : _getStricker,
                      child: _isStickerAvailable == true
                          ? const Icon(Icons.camera)
                          : Image.asset(
                        'assets/images/hooficon.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                ),

                // Capture button
                // _isStickerAvailable
                //     ? Align(
                //   alignment: Alignment.bottomRight,
                //     child: Padding(
                //     padding: const EdgeInsets.all(80),
                //     child: Text(
                //       'D: $finlaDistance\n'
                //       'an: $cameraAngle\n'
                //       'pitchingPos: $pitchingPosGl\n'
                //       'originalAngle: $originalAngleGl\n'
                //       'pitchRadians: $pitchRadiansGl\n'
                //       'distance: $distanceGl\n'
                //       'stickerPx: $baseStickerSizePxGl',
                //       style: const TextStyle(fontSize: 16, color: Colors.white),
                //     ),
                //   ),
                // )
                //     : SizedBox.shrink(), // Show nothing if false



                // Back button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
